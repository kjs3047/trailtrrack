import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/location/location_source.dart';
import '../../core/utils/activity_type.dart';
import '../settings/settings_repository.dart';
import 'activity_stats.dart';
import 'data/activity_repository.dart';
import 'gps_validator.dart';
import 'models/recorded_point.dart';
import 'recording_state.dart';

/// Orchestrates a live recording (spec §6): consumes GPS fixes, validates them,
/// persists batches to Drift, recomputes stats, and drives the state machine
/// (idle → recording ⇄ paused → finishing → completed).
///
/// Design:
///  - Accepted AND rejected points are stored so originals are preserved
///    (spec §6/§20); stats use accepted points only.
///  - Points are buffered and flushed in batches (time- or size-triggered) to
///    avoid a DB write per fix, and to batch-append to the map (spec §5).
///  - A recovery snapshot is written periodically so a crash mid-recording can
///    be resumed (spec §14).
class RecordingController extends ChangeNotifier {
  RecordingController({
    required LocationSource locationService,
    required ActivityRepository repository,
    SettingsRepository? settingsRepository,
    Uuid? uuid,
  }) : _location = locationService,
       _repo = repository,
       _settings = settingsRepository,
       _uuid = uuid ?? const Uuid();

  final LocationSource _location;
  final ActivityRepository _repo;
  final SettingsRepository? _settings;
  final Uuid _uuid;

  /// Body weight (kg) for the live calorie estimate, loaded at recording start.
  /// Null until loaded / when no settings repo is wired (tests) → calories 0.
  double? _bodyWeightKg;

  RecordingState _state = const RecordingState();
  RecordingState get state => _state;

  /// Accepted points so far (read-only snapshot) — used to geo-tag photos.
  List<RecordedPoint> get acceptedPoints => List.unmodifiable(_accepted);

  GpsValidator? _validator;
  final List<RecordedPoint> _buffer = [];
  final List<String> _bufferIds = [];
  final List<RecordedPoint> _accepted = [];
  int _sequence = 0;

  StreamSubscription<RawFix>? _fixSub;
  StreamSubscription<String>? _errorSub;
  Timer? _flushTimer;
  Timer? _snapshotTimer;
  DateTime? _pauseStartedAt;

  /// Emits batches of newly-accepted points for the map to append.
  final _appendController = StreamController<List<RecordedPoint>>.broadcast();
  Stream<List<RecordedPoint>> get acceptedBatches => _appendController.stream;

  static const _flushInterval = Duration(seconds: 3);
  static const _snapshotInterval = Duration(seconds: 10);
  static const _flushSizeThreshold = 10;

  /// Begin a new recording of [type].
  Future<void> start(ActivityType type) async {
    if (_state.status.isActive) return;
    final id = _uuid.v4();
    final startedAt = DateTime.now();

    _validator = GpsValidator(profile: type.gpsProfile);
    _buffer.clear();
    _bufferIds.clear();
    _accepted.clear();
    _sequence = 0;
    _bodyWeightKg = await _settings?.getBodyWeightKg();

    await _repo.createActivity(id: id, type: type, startedAt: startedAt);

    _state = RecordingState(
      status: RecordingStatus.recording,
      activityId: id,
      activityType: type,
      startedAt: startedAt,
    );
    notifyListeners();

    await _location.start(
      distanceFilterMeters: type.gpsProfile.distanceFilterMeters.round(),
    );

    _fixSub = _location.fixes.listen(_onFix);
    _errorSub = _location.errors.listen((e) {
      _state = _state.copyWith(errorMessage: e);
      notifyListeners();
    });
    _startTimers();
  }

  /// Resume an interrupted recording after an app restart (spec §14). Reloads
  /// stored points, rebuilds the validator/stats, restarts the location
  /// service, and continues appending to the same activity.
  Future<void> resumeExisting(String activityId) async {
    if (_state.status.isActive) return;
    final row = await _repo.getActivity(activityId);
    if (row == null) return;
    final type = ActivityType.fromId(row.activityType);

    final stored = await _repo.getTrackPoints(activityId);
    final points = stored.map(_repo.rowToPoint).toList();
    _accepted
      ..clear()
      ..addAll(points.where((p) => p.isAccepted));
    _buffer.clear();
    _bufferIds.clear();
    _sequence = points.isEmpty ? 0 : points.last.sequence + 1;

    // Rebuild the validator anchored on the last accepted point / segment.
    _validator = GpsValidator(profile: type.gpsProfile);
    if (_accepted.isNotEmpty) _validator!.commit(_accepted.last);
    _bodyWeightKg = await _settings?.getBodyWeightKg();

    const calc = ActivityStatsCalculator();
    final startedAt = DateTime.fromMillisecondsSinceEpoch(row.startedAt);
    final stats = calc.compute(
      points: _accepted,
      startedAt: startedAt,
      endedAt: DateTime.now(),
      pausedDuration: Duration.zero,
      activityType: type,
      bodyWeightKg: _bodyWeightKg,
    );

    _state = RecordingState(
      status: RecordingStatus.recording,
      activityId: activityId,
      activityType: type,
      startedAt: startedAt,
      stats: stats,
      acceptedCount: _accepted.length,
      lastPoint: _accepted.isNotEmpty ? _accepted.last : null,
      currentSegment: _accepted.isNotEmpty ? _accepted.last.segmentIndex : 0,
    );
    notifyListeners();

    await _repo.setStatus(activityId, 'recording');
    await _location.start(
      distanceFilterMeters: type.gpsProfile.distanceFilterMeters.round(),
    );
    _fixSub = _location.fixes.listen(_onFix);
    _errorSub = _location.errors.listen((e) {
      _state = _state.copyWith(errorMessage: e);
      notifyListeners();
    });
    _startTimers();
  }

  /// Finalize an interrupted recording without resuming (spec §14: "저장하고
  /// 종료"). Computes stats from the stored points and marks it completed.
  Future<void> finalizeRecovered(String activityId) async {
    final row = await _repo.getActivity(activityId);
    if (row == null) return;
    final stored = await _repo.getTrackPoints(activityId);
    final points = stored.map(_repo.rowToPoint).toList();
    final accepted = points.where((p) => p.isAccepted).toList();
    const calc = ActivityStatsCalculator();
    final startedAt = DateTime.fromMillisecondsSinceEpoch(row.startedAt);
    final endedAt = accepted.isNotEmpty ? accepted.last.recordedAt : startedAt;
    final stats = calc.compute(
      points: accepted,
      startedAt: startedAt,
      endedAt: endedAt,
      pausedDuration: Duration.zero,
      activityType: ActivityType.fromId(row.activityType),
      bodyWeightKg: await _settings?.getBodyWeightKg(),
    );
    await _repo.finalizeActivity(
      activityId: activityId,
      endedAt: endedAt,
      stats: stats,
    );
  }

  /// Delete an interrupted recording (spec §14: "삭제").
  Future<void> deleteRecovered(String activityId) =>
      _repo.deleteActivity(activityId);

  void _startTimers() {
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
    _snapshotTimer = Timer.periodic(_snapshotInterval, (_) => _writeSnapshot());
  }

  void _stopTimers() {
    _flushTimer?.cancel();
    _snapshotTimer?.cancel();
    _flushTimer = null;
    _snapshotTimer = null;
  }

  void _onFix(RawFix fix) {
    if (_state.status != RecordingStatus.recording) return;
    final validator = _validator;
    if (validator == null) return;

    final result = validator.validate(fix);
    final point = RecordedPoint(
      sequence: _sequence++,
      latitude: fix.latitude,
      longitude: fix.longitude,
      recordedAt: fix.timestamp,
      gpsAltitude: fix.altitude,
      speed: fix.speed,
      heading: fix.heading,
      accuracy: fix.accuracy,
      segmentIndex: result.segmentIndex,
      isAccepted: result.accepted,
    );

    // Store originals regardless of acceptance (spec §6/§20).
    _buffer.add(point);
    _bufferIds.add(_uuid.v4());

    if (result.accepted) {
      validator.commit(point);
      _accepted.add(point);
      _appendController.add([point]);
      _recomputeStats(lastPoint: point);
    } else {
      _state = _state.copyWith(
        rejectedCount: _state.rejectedCount + 1,
        currentSegment: result.segmentIndex,
      );
      notifyListeners();
    }

    if (_buffer.length >= _flushSizeThreshold) {
      _flush();
    }
  }

  void _recomputeStats({RecordedPoint? lastPoint}) {
    const calc = ActivityStatsCalculator();
    final stats = calc.compute(
      points: _accepted,
      startedAt: _state.startedAt,
      endedAt: DateTime.now(),
      activityType: _state.activityType,
      bodyWeightKg: _bodyWeightKg,
      pausedDuration: _state.pausedDuration,
    );
    _state = _state.copyWith(
      stats: stats,
      lastPoint: lastPoint,
      acceptedCount: _accepted.length,
      currentSegment: lastPoint?.segmentIndex ?? _state.currentSegment,
    );
    notifyListeners();
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;
    final id = _state.activityId;
    if (id == null) return;
    final points = List<RecordedPoint>.from(_buffer);
    final ids = List<String>.from(_bufferIds);
    _buffer.clear();
    _bufferIds.clear();
    try {
      await _repo.insertTrackPoints(id, points, ids);
    } catch (e) {
      // Re-buffer on failure so we don't lose points; surface a soft error.
      _buffer.insertAll(0, points);
      _bufferIds.insertAll(0, ids);
      _state = _state.copyWith(errorMessage: '저장 지연: $e');
      notifyListeners();
    }
  }

  Future<void> _writeSnapshot() async {
    final id = _state.activityId;
    final last = _state.lastPoint;
    if (id == null) return;
    await _repo.updateSnapshot(
      activityId: id,
      lastSequence: _sequence - 1,
      distanceMeters: _state.stats.totalDistanceMeters,
      lastLat: last?.latitude,
      lastLon: last?.longitude,
      status: _state.status.name,
    );
  }

  Future<void> pause() async {
    if (_state.status != RecordingStatus.recording) return;
    _pauseStartedAt = DateTime.now();
    _state = _state.copyWith(status: RecordingStatus.paused);
    notifyListeners();
    final id = _state.activityId;
    if (id != null) await _repo.setStatus(id, 'paused');
    await _location.updateNotification(
      title: 'TrailTrack 일시정지',
      text: '기록이 일시정지되었습니다',
    );
  }

  Future<void> resume() async {
    if (_state.status != RecordingStatus.paused) return;
    if (_pauseStartedAt != null) {
      final added = DateTime.now().difference(_pauseStartedAt!);
      _state = _state.copyWith(pausedDuration: _state.pausedDuration + added);
      _pauseStartedAt = null;
    }
    _state = _state.copyWith(status: RecordingStatus.recording);
    notifyListeners();
    final id = _state.activityId;
    if (id != null) await _repo.setStatus(id, 'recording');
    await _location.updateNotification(
      title: 'TrailTrack 기록 중',
      text: '운동 경로를 기록하고 있습니다',
    );
  }

  /// Stop and finalize the recording. Returns the finalized activityId.
  Future<String?> stop() async {
    if (!_state.status.isActive) return _state.activityId;
    final id = _state.activityId;

    // Fold any in-progress pause into the total.
    if (_state.status == RecordingStatus.paused && _pauseStartedAt != null) {
      final added = DateTime.now().difference(_pauseStartedAt!);
      _state = _state.copyWith(pausedDuration: _state.pausedDuration + added);
      _pauseStartedAt = null;
    }

    _state = _state.copyWith(status: RecordingStatus.finishing);
    notifyListeners();

    _stopTimers();
    await _fixSub?.cancel();
    await _errorSub?.cancel();
    await _location.stop();
    await _flush(); // persist remaining buffered points

    final endedAt = DateTime.now();
    const calc = ActivityStatsCalculator();
    final stats = calc.compute(
      points: _accepted,
      startedAt: _state.startedAt,
      endedAt: endedAt,
      pausedDuration: _state.pausedDuration,
      activityType: _state.activityType,
      bodyWeightKg: _bodyWeightKg,
    );

    if (id != null) {
      await _repo.finalizeActivity(
        activityId: id,
        endedAt: endedAt,
        stats: stats,
      );
    }

    _state = _state.copyWith(status: RecordingStatus.completed, stats: stats);
    notifyListeners();
    return id;
  }

  /// Discard the current recording entirely.
  Future<void> discard() async {
    _stopTimers();
    await _fixSub?.cancel();
    await _errorSub?.cancel();
    await _location.stop();
    final id = _state.activityId;
    if (id != null) await _repo.deleteActivity(id);
    _reset();
  }

  void _reset() {
    _validator = null;
    _buffer.clear();
    _bufferIds.clear();
    _accepted.clear();
    _sequence = 0;
    _pauseStartedAt = null;
    _state = const RecordingState();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    _fixSub?.cancel();
    _errorSub?.cancel();
    _appendController.close();
    super.dispose();
  }
}
