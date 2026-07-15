import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../map/cesium_bridge.dart';
import '../map/cesium_map_controller.dart';
import '../map/cesium_map_view.dart';
import '../photos/photo_gallery.dart';
import '../photos/photo_storage.dart';
import '../recording/data/activity_repository.dart';
import 'chart_data.dart';
import 'widgets/elevation_chart.dart';
import 'widgets/replay_controls.dart';
import 'widgets/speed_chart.dart';

/// Activity detail screen (mockup _1): full route on the map, stats grid,
/// elevation and speed charts. Photo markers and 3D replay are added in M4.
class ActivityDetailScreen extends ConsumerStatefulWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  final CesiumMapController _map = CesiumMapController();

  @override
  void initState() {
    super.initState();
    _map.addMapReadyListener(_onMapReady);
    _map.onPhotoMarkerSelected = _onPhotoMarkerSelected;
  }

  void _onMapReady(bool terrain) => _pushRouteIfReady();

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _pushRouteIfReady() {
    // No one-shot guard: MAP_READY may fire again after a WebView reload
    // (renderer killed under memory pressure) — the JS state is lost then, so
    // always (re)push. SET_TRACK_POINTS replaces the route; it's idempotent.
    final async = ref.read(activityDetailProvider(widget.activityId));
    final data = async.value;
    if (data == null) return;
    final mapPoints = data.points
        .where((p) => p.isAccepted)
        .map((p) => p.toMapPoint())
        .toList();
    if (mapPoints.isNotEmpty) {
      _map.setTrackPoints(mapPoints, fit: true);
    }
    _pushPhotoMarkers(data);
  }

  void _pushPhotoMarkers(ActivityDetailData data) {
    final markers = <MapPhotoMarker>[
      for (final p in data.photos)
        if (p.latitude != null && p.longitude != null)
          MapPhotoMarker(
            id: p.id,
            lat: p.latitude!,
            lon: p.longitude!,
            alt: p.demAltitude ?? p.gpsAltitude,
          ),
    ];
    if (markers.isNotEmpty) _map.setPhotoMarkers(markers);
  }

  void _onPhotoMarkerSelected(String photoId) {
    final data = ref.read(activityDetailProvider(widget.activityId)).value;
    if (data == null) return;
    final index = data.photos.indexWhere((p) => p.id == photoId);
    if (index >= 0) openGallery(context, data.photos, index);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(activityDetailProvider(widget.activityId));
    // Push the route once data + map are both ready.
    ref.listen(activityDetailProvider(widget.activityId), (_, next) {
      if (next.value != null && _map.mapReady) _pushRouteIfReady();
    });

    // Reached either via push (from a list — has a back stack) or via go (after
    // Stop — no back stack). Show a Home button so there is always a way back to
    // the dashboard.
    final canPop = context.canPop();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: canPop ? '뒤로' : '홈',
          icon: Icon(canPop ? Icons.arrow_back : Icons.home_outlined),
          onPressed: () =>
              canPop ? context.pop() : context.go(Routes.dashboard),
        ),
        title: Text(_title(async.value)),
        actions: [
          // Always offer a direct route home, even when reached via push.
          if (canPop)
            IconButton(
              tooltip: '홈',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => context.go(Routes.dashboard),
            ),
          if (async.value != null)
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 오류: $e')),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('운동을 찾을 수 없습니다'));
          }
          return _content(data);
        },
      ),
    );
  }

  String _title(ActivityDetailData? data) {
    if (data == null) return '운동 상세';
    final a = data.activity;
    return a.title.isNotEmpty ? a.title : '${data.type.label} 운동';
  }

  Widget _content(ActivityDetailData data) {
    final chart = ActivityChartData.fromPoints(data.points);
    // Give the map a tall viewport (~55% of screen height, min 380) — the
    // stats/photos/charts below scroll, so a bigger map is pure upside.
    final mapHeight =
        (MediaQuery.of(context).size.height * 0.55).clamp(380.0, 720.0);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SizedBox(
          height: mapHeight,
          child: CesiumMapView(
            controller: _map,
            initialSceneMode: SceneMode.d3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3D route replay controls (spec §11).
              ReplayControls(controller: _map),
              const SizedBox(height: AppTheme.spaceMd),
              _statsGrid(data.activity),
              if (data.photos.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Text(
                      '사진 ${data.photos.length}',
                      style: AppTypography.labelCaps,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceXs),
                PhotoStrip(photos: data.photos),
              ],
              const SizedBox(height: AppTheme.spaceMd),
              _chartCard(
                title: '거리 대비 고도',
                child: ElevationChart(data: chart),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              _chartCard(
                title: '시간 대비 속도',
                child: SpeedChart(data: chart),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsGrid(ActivityRow a) {
    final tiles = <(String, String, String)>[
      ('총 거리', Formatters.distanceKm(a.totalDistanceMeters), 'km'),
      ('활동 시간', Formatters.duration(Duration(seconds: a.activeSeconds)), ''),
      ('평균 속도', Formatters.speedKmh(a.averageSpeed), 'km/h'),
      ('최고 속도', Formatters.speedKmh(a.maxSpeed), 'km/h'),
      ('누적 상승', a.elevationGain.round().toString(), 'm'),
      ('최고 고도', Formatters.altitude(a.maximumAltitude), 'm'),
      ('칼로리', Formatters.calories(a.calories), 'kcal'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // 2.4 was a hair too flat → the label + value column overflowed by ~5 px.
      childAspectRatio: 2.1,
      crossAxisSpacing: AppTheme.spaceSm,
      mainAxisSpacing: AppTheme.spaceSm,
      children: [
        for (final t in tiles) _StatTile(label: t.$1, value: t.$2, unit: t.$3),
      ],
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.labelCaps),
            const SizedBox(height: AppTheme.spaceSm),
            SizedBox(height: 180, child: child),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('운동 삭제'),
        content: const Text('이 운동 기록을 삭제할까요? 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Remove DB rows (cascades track points + photo rows) and the photo
      // files on disk so nothing is orphaned.
      await ref
          .read(activityRepositoryProvider)
          .deleteActivity(widget.activityId);
      await const PhotoStorage().deleteActivityPhotos(widget.activityId);
      if (mounted) context.go(Routes.dashboard);
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
