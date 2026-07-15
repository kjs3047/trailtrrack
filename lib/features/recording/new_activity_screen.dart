import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/location/current_location.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/activity_type.dart';
import '../map/cesium_bridge.dart';
import '../map/cesium_map_controller.dart';
import '../map/cesium_map_view.dart';

/// New-activity screen (mockup _4): pick a workout type, preview the map, and
/// start recording. Starting requests location + notification permission
/// (staged, spec §7), then begins a recording and routes to the live screen.
class NewActivityScreen extends ConsumerStatefulWidget {
  const NewActivityScreen({super.key});

  @override
  ConsumerState<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends ConsumerState<NewActivityScreen> {
  ActivityType _selected = ActivityType.walk;
  final CesiumMapController _map = CesiumMapController();
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    // Center the map on the device's current location once it's ready.
    _map.addMapReadyListener(_onMapReady);
  }

  void _onMapReady(bool terrain) => _goToCurrentLocation();

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    final loc = await getCurrentLocation();
    if (loc == null) return;
    _map.setCurrentLocation(
      lat: loc.latitude,
      lon: loc.longitude,
      alt: loc.altitude,
      follow: true,
      zoomTo: 1200, // explicit locate → zoom in to street level
    );
  }

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final permissions = ref.read(permissionServiceProvider);
      final result = await permissions.ensureLocationForRecording();
      if (!result.isGranted) {
        if (!mounted) return;
        _showPermissionError(result);
        return;
      }
      // Best-effort notification permission for the foreground service.
      await permissions.ensureNotifications();

      final controller = ref.read(recordingControllerProvider);
      await controller.start(_selected);
      if (!mounted) return;
      context.go(Routes.recording);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _showPermissionError(LocationPermissionResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        action: result == LocationPermissionResult.deniedForever
            ? SnackBarAction(
                label: '설정',
                onPressed: ref.read(permissionServiceProvider).openSettings,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 운동')),
      body: Column(
        children: [
          Expanded(
            child: CesiumMapView(
              controller: _map,
              initialSceneMode: SceneMode.d3,
              onLocate: _goToCurrentLocation,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('운동 유형 선택', style: AppTypography.headlineLgMobile),
                  const SizedBox(height: AppTheme.spaceSm),
                  _typeGrid(),
                  const SizedBox(height: AppTheme.spaceMd),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _starting ? null : _start,
                      icon: _starting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text('${_selected.label} 시작'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeGrid() {
    return Wrap(
      spacing: AppTheme.spaceXs,
      runSpacing: AppTheme.spaceXs,
      children: [
        for (final type in ActivityType.values)
          _TypeChip(
            type: type,
            selected: type == _selected,
            onTap: () => setState(() => _selected = type),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ActivityType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 20,
              color: selected ? AppColors.onPrimary : AppColors.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: AppTypography.bodyMd.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
