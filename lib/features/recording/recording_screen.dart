import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../map/cesium_bridge.dart';
import '../map/cesium_map_controller.dart';
import '../map/cesium_map_view.dart';
import '../photos/camera_capture_screen.dart';
import '../photos/photo_gallery.dart';
import 'recording_state.dart';

/// Live recording screen (mockup _2): real-time route on the map plus a HUD
/// (time / distance / pace / current speed / altitude / elevation gain) and
/// pause / resume / stop controls. Photo capture lands in M4.
class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  final CesiumMapController _map = CesiumMapController();
  StreamSubscription? _batchSub;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  /// Whether the camera has been zoomed down to the track yet. The follow
  /// camera keeps the CURRENT height, so if MAP_READY fires before the first
  /// accepted GPS fix the view would stay at globe level forever — the first
  /// fix must carry an explicit zoom.
  bool _zoomedToTrack = false;

  @override
  void initState() {
    super.initState();
    // Push the full accepted track whenever the map (re)becomes ready — covers
    // both the initial load and a WebView reload after Android killed the
    // renderer (the JS side loses its state on reload).
    _map.addMapReadyListener(_onMapReady);
    _map.onPhotoMarkerSelected = _onPhotoMarkerSelected;
    // Stream accepted point batches to the map as they arrive (spec §5).
    final controller = ref.read(recordingControllerProvider);
    _batchSub = controller.acceptedBatches.listen((batch) {
      _map.appendTrackPoints(batch.map((p) => p.toMapPoint()).toList());
      final last = batch.last;
      _map.setCurrentLocation(
        lat: last.latitude,
        lon: last.longitude,
        alt: last.displayAltitude,
        follow: true,
        zoomTo: _zoomedToTrack ? null : 1500,
      );
      _zoomedToTrack = true;
    });
    // 1 Hz ticker so the elapsed clock updates even without new fixes.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  void _onMapReady(bool terrain) {
    final controller = ref.read(recordingControllerProvider);
    // Re-push photo markers too — the JS side loses them on a WebView reload.
    final activityId = controller.state.activityId;
    if (activityId != null) _refreshPhotoMarkers(activityId);
    final pts = controller.acceptedPoints;
    if (pts.isEmpty) return;
    _map.setTrackPoints(pts.map((p) => p.toMapPoint()).toList());
    final last = pts.last;
    _map.setCurrentLocation(
      lat: last.latitude,
      lon: last.longitude,
      alt: last.displayAltitude,
      follow: true,
      zoomTo: 1500,
    );
    _zoomedToTrack = true;
  }

  Future<void> _onPhotoMarkerSelected(String photoId) async {
    final activityId = ref.read(recordingControllerProvider).state.activityId;
    if (activityId == null) return;
    final photos = await ref
        .read(photoRepositoryProvider)
        .getPhotos(activityId);
    final index = photos.indexWhere((p) => p.id == photoId);
    if (index < 0 || !mounted) return;
    openGallery(context, photos, index);
  }

  @override
  void dispose() {
    _map.removeMapReadyListener(_onMapReady);
    _batchSub?.cancel();
    _ticker?.cancel();
    _map.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    final controller = ref.read(recordingControllerProvider);
    final id = await controller.stop();
    if (!mounted) return;
    if (id != null) {
      context.go(Routes.activityDetailPath(id));
    } else {
      context.go(Routes.dashboard);
    }
  }

  Future<void> _confirmStop() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('운동 종료'),
        content: const Text('현재 운동을 종료하고 저장할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('종료'),
          ),
        ],
      ),
    );
    if (ok == true) await _stop();
  }

  Future<void> _capturePhoto() async {
    final permissions = ref.read(permissionServiceProvider);
    if (!await permissions.ensureCamera()) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('카메라 권한이 필요합니다')));
      }
      return;
    }
    if (!mounted) return;
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
    if (bytes == null || !mounted) return;

    final controller = ref.read(recordingControllerProvider);
    final state = controller.state;
    final activityId = state.activityId;
    final start = state.startedAt;
    if (activityId == null || start == null) return;

    final takenAt = DateTime.now();
    await ref
        .read(photoCaptureServiceProvider)
        .savePhoto(
          activityId: activityId,
          imageBytes: bytes,
          takenAt: takenAt,
          activityStart: start,
          points: controller.acceptedPoints,
        );
    _refreshPhotoMarkers(activityId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진이 저장되었습니다')));
    }
  }

  void _goToLastPoint() {
    final last = ref.read(recordingControllerProvider).state.lastPoint;
    if (last != null) {
      _map.flyToLocation(last.latitude, last.longitude, alt: 1500);
    } else {
      _map.flyToRoute();
    }
  }

  Future<void> _refreshPhotoMarkers(String activityId) async {
    final photos = await ref
        .read(photoRepositoryProvider)
        .getPhotos(activityId);
    final markers = <MapPhotoMarker>[
      for (final p in photos)
        if (p.latitude != null && p.longitude != null)
          MapPhotoMarker(
            id: p.id,
            lat: p.latitude!,
            lon: p.longitude!,
            alt: p.demAltitude ?? p.gpsAltitude,
          ),
    ];
    _map.setPhotoMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(recordingControllerProvider);
    final state = controller.state;

    // Map fills the screen; a compact stats bar + controls sit at the BOTTOM so
    // the map stays fully visible (the previous layout felt like the screen was
    // covered).
    return PopScope(
      canPop: false, // prevent accidental back-out of an active recording
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CesiumMapView(
                controller: _map,
                initialSceneMode: SceneMode.d3,
                onLocate: _goToLastPoint,
              ),
            ),
            // Bottom panel: compact stats + controls.
            Container(
              color: AppColors.surfaceContainerLowest,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Hud(state: state, now: _now),
                      const SizedBox(height: 12),
                      _Controls(
                        state: state,
                        onPause: controller.pause,
                        onResume: controller.resume,
                        onStop: _confirmStop,
                        onCapture: _capturePhoto,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.state, required this.now});
  final RecordingState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final elapsed = state.elapsed(now) - state.pausedDuration;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HudItem(
                label: '시간',
                value: Formatters.duration(
                  elapsed.isNegative ? Duration.zero : elapsed,
                ),
              ),
              _HudItem(
                label: '거리',
                value: Formatters.distanceKm(state.stats.totalDistanceMeters),
                unit: 'km',
              ),
              _HudItem(
                label: '페이스',
                value: Formatters.pacePerKm(state.stats.averageSpeed),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HudItem(
                label: '현재속도',
                value: Formatters.speedKmh(state.currentSpeed ?? 0),
                unit: 'km/h',
              ),
              _HudItem(
                label: '고도',
                value: Formatters.altitude(state.currentAltitude),
                unit: 'm',
              ),
              _HudItem(
                label: '상승',
                value: state.stats.elevationGain.round().toString(),
                unit: 'm',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HudItem(
                label: '칼로리',
                value: Formatters.calories(state.stats.calories),
                unit: 'kcal',
              ),
              // Keep the row balanced with the two above (3 columns).
              const Spacer(),
              const Spacer(),
            ],
          ),
          if (state.status == RecordingStatus.paused)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '일시정지됨',
                style: TextStyle(color: AppColors.safetyOrange),
              ),
            ),
        ],
      ),
    );
  }
}

class _HudItem extends StatelessWidget {
  const _HudItem({required this.label, required this.value, this.unit});
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Grotesk',
            ),
            children: [
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onCapture,
  });

  final RecordingState state;
  final Future<void> Function() onPause;
  final Future<void> Function() onResume;
  final Future<void> Function() onStop;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    final recording = state.status == RecordingStatus.recording;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Photo capture button.
        _RoundButton(
          icon: Icons.photo_camera_outlined,
          color: AppColors.surfaceContainerHighest,
          iconColor: AppColors.secondary,
          onTap: onCapture,
        ),
        const SizedBox(width: 24),
        // Pause / resume.
        _RoundButton(
          icon: recording ? Icons.pause : Icons.play_arrow,
          color: AppColors.primary,
          iconColor: Colors.white,
          large: true,
          onTap: () => recording ? onPause() : onResume(),
        ),
        const SizedBox(width: 24),
        // Stop.
        _RoundButton(
          icon: Icons.stop,
          color: AppColors.safetyOrange,
          iconColor: Colors.white,
          onTap: onStop,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 72.0 : 56.0;
    return Material(
      color: color,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 2),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: large ? 36 : 26),
        ),
      ),
    );
  }
}
