import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'cesium_bridge.dart';
import 'cesium_map_controller.dart';
import 'cesium_map_view.dart';

/// M1 CesiumJS proof-of-concept screen.
///
/// Exercises every M1 capability so it can be verified on-device:
///  - local Cesium asset load + World Terrain
///  - 2D/3D toggle (via the shared control overlay)
///  - a sample track polyline (Bukhansan Baegundae course, matching mockup _1)
///  - Fly-to-route + map touch (TRACK_POINT_SELECTED)
///  - a batch DEM height lookup along the route (spec §8)
class CesiumPocScreen extends StatefulWidget {
  const CesiumPocScreen({super.key});

  @override
  State<CesiumPocScreen> createState() => _CesiumPocScreenState();
}

class _CesiumPocScreenState extends State<CesiumPocScreen> {
  final CesiumMapController _controller = CesiumMapController();
  String _status = '지도 초기화 대기';
  String? _lastPick;
  String? _demSummary;

  /// A short sample route near Bukhansan (Seoul). Approximate ridge line —
  /// enough to demonstrate a multi-point polyline over 3D terrain.
  static const List<MapPoint> _sampleRoute = [
    MapPoint(lat: 37.6584, lon: 126.9779, alt: 320, seg: 0),
    MapPoint(lat: 37.6601, lon: 126.9808, alt: 410, seg: 0),
    MapPoint(lat: 37.6620, lon: 126.9835, alt: 520, seg: 0),
    MapPoint(lat: 37.6638, lon: 126.9861, alt: 640, seg: 0),
    MapPoint(lat: 37.6652, lon: 126.9887, alt: 730, seg: 0),
    MapPoint(lat: 37.6669, lon: 126.9902, alt: 810, seg: 0),
    // Simulated GPS gap → new segment (must not be bridged with a line).
    MapPoint(lat: 37.6702, lon: 126.9931, alt: 836, seg: 1),
    MapPoint(lat: 37.6718, lon: 126.9955, alt: 800, seg: 1),
    MapPoint(lat: 37.6731, lon: 126.9978, alt: 700, seg: 1),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addMapReadyListener((terrain) {
      setState(
        () => _status = terrain
            ? '지도 준비됨 · Terrain 로드됨'
            : '지도 준비됨 · Terrain 미로드(토큰 확인)',
      );
      _controller.setTrackPoints(_sampleRoute, fit: true);
    });
    _controller.addMapErrorListener((message, fatal) {
      setState(() => _status = '${fatal ? "오류" : "경고"}: $message');
    });
    _controller.onTrackPointSelected = (index, lat, lon) {
      setState(
        () => _lastPick =
            '경로 #$index (${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})',
      );
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runDemLookup() async {
    setState(() => _demSummary = 'DEM 조회 중…');
    final heights = await _controller.lookupDem(
      _sampleRoute.map((p) => (lat: p.lat, lon: p.lon)).toList(),
    );
    final ok = heights.where((h) => h != null).length;
    final samples = heights
        .take(3)
        .map((h) => h == null ? '–' : h.height.toStringAsFixed(0))
        .join(', ');
    setState(
      () => _demSummary = 'DEM $ok/${heights.length} 성공 · 앞 3개(m): $samples',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cesium PoC (M1)')),
      body: Column(
        children: [
          Expanded(
            child: CesiumMapView(
              controller: _controller,
              initialSceneMode: SceneMode.d3,
              enableTerrain: true,
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (_lastPick != null) ...[
                    const SizedBox(height: 4),
                    Text('선택: $_lastPick'),
                  ],
                  if (_demSummary != null) ...[
                    const SizedBox(height: 4),
                    Text(_demSummary!),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _controller.flyToRoute(durationSec: 1.5),
                        icon: const Icon(Icons.route),
                        label: const Text('경로 보기'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _runDemLookup,
                        icon: const Icon(Icons.terrain),
                        label: const Text('DEM 조회'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _controller.startReplay(speed: 4, follow: true),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('경로 재생'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
