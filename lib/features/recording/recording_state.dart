import '../../core/utils/activity_type.dart';
import 'activity_stats.dart';
import 'models/recorded_point.dart';

/// Recording lifecycle states (spec §6).
enum RecordingStatus {
  idle,
  recording,
  paused,
  finishing,
  completed,
  recoveryRequired;

  bool get isActive =>
      this == RecordingStatus.recording || this == RecordingStatus.paused;
}

/// Immutable snapshot of the current recording, exposed to the UI.
class RecordingState {
  const RecordingState({
    this.status = RecordingStatus.idle,
    this.activityId,
    this.activityType = ActivityType.hike,
    this.startedAt,
    this.stats = ActivityStats.empty,
    this.lastPoint,
    this.acceptedCount = 0,
    this.rejectedCount = 0,
    this.currentSegment = 0,
    this.pausedDuration = Duration.zero,
    this.errorMessage,
  });

  final RecordingStatus status;
  final String? activityId;
  final ActivityType activityType;
  final DateTime? startedAt;
  final ActivityStats stats;
  final RecordedPoint? lastPoint;
  final int acceptedCount;
  final int rejectedCount;
  final int currentSegment;
  final Duration pausedDuration;
  final String? errorMessage;

  /// Current elapsed wall-clock, computed live from startedAt.
  Duration elapsed(DateTime now) =>
      startedAt == null ? Duration.zero : now.difference(startedAt!);

  double? get currentSpeed => lastPoint?.speed;
  double? get currentAltitude => lastPoint?.displayAltitude;

  RecordingState copyWith({
    RecordingStatus? status,
    String? activityId,
    ActivityType? activityType,
    DateTime? startedAt,
    ActivityStats? stats,
    RecordedPoint? lastPoint,
    int? acceptedCount,
    int? rejectedCount,
    int? currentSegment,
    Duration? pausedDuration,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecordingState(
      status: status ?? this.status,
      activityId: activityId ?? this.activityId,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      stats: stats ?? this.stats,
      lastPoint: lastPoint ?? this.lastPoint,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      currentSegment: currentSegment ?? this.currentSegment,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
