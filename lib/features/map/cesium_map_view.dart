import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import 'cesium_bridge.dart';
import 'cesium_map_controller.dart';

/// Reusable CesiumJS map widget (spec §5). Hosts the local Cesium runtime in a
/// [InAppWebView], wires the JSON bridge to a [CesiumMapController], and draws
/// the shared map-control overlay (2D/3D, layers, locate, north-up, zoom, fit).
///
/// The widget is deliberately "dumb": it renders and forwards control taps to
/// the controller. Screens own the controller and decide what data to push.
class CesiumMapView extends StatefulWidget {
  const CesiumMapView({
    super.key,
    required this.controller,
    this.initialSceneMode = SceneMode.d3,
    this.initialImagery = MapImagery.satellite,
    this.enableTerrain = true,
    this.showControls = true,
    this.onControlsBuilt,
    this.onLocate,
  });

  final CesiumMapController controller;
  final SceneMode initialSceneMode;
  final MapImagery initialImagery;
  final bool enableTerrain;
  final bool showControls;

  /// Optional hook to inject extra control buttons (e.g. replay).
  final Widget Function(BuildContext context)? onControlsBuilt;

  /// Called when the "current location" control is tapped. The host screen owns
  /// GPS, so it decides what "locate" means (fly to a live fix, or to the
  /// route). If null, the button flies to the loaded route bounds.
  final VoidCallback? onLocate;

  @override
  State<CesiumMapView> createState() => _CesiumMapViewState();
}

class _CesiumMapViewState extends State<CesiumMapView> {
  SceneMode _sceneMode = SceneMode.d3;
  MapImagery _imagery = MapImagery.satellite;
  bool _loading = true;
  String? _error;

  /// Bumped to recreate the WebView when Android kills its renderer process
  /// (low memory) — instead of leaving a dead black surface, the map reloads
  /// and screens re-push their data via the map-ready listeners.
  int _webViewEpoch = 0;

  @override
  void initState() {
    super.initState();
    _sceneMode = widget.initialSceneMode;
    _imagery = widget.initialImagery;
    widget.controller.addMapReadyListener(_onReady);
    widget.controller.addMapErrorListener(_onError);
  }

  void _onReady(bool terrain) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = null;
    });
  }

  void _onError(String message, bool fatal) {
    if (!mounted) return;
    // Only surface fatal errors as a blocking overlay; non-fatal errors
    // (e.g. terrain unavailable) keep the map usable (spec §14).
    if (fatal) setState(() => _error = message);
  }

  @override
  void dispose() {
    widget.controller.removeMapReadyListener(_onReady);
    widget.controller.removeMapErrorListener(_onError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _webView()),
        if (_loading) const Positioned.fill(child: _LoadingOverlay()),
        if (_error != null)
          Positioned.fill(child: _ErrorOverlay(message: _error!)),
        if (widget.showControls && _error == null)
          // SafeArea keeps the control column below the status bar on screens
          // without an AppBar (e.g. the recording screen's full-bleed map).
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 12),
                child: _controls(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _webView() {
    return InAppWebView(
      key: ValueKey('cesium_webview_$_webViewEpoch'),
      // Claim all gestures inside the map bounds. Without this, a map embedded
      // in a scrollable (activity detail) loses drags/pinches to the ListView,
      // so the map can't be panned or zoomed.
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
      initialFile: 'assets/cesium/index.html',
      initialSettings: InAppWebViewSettings(
        // Cesium loads Web Workers and shader/asset files from the local
        // bundle via file:// URLs; these flags are required for that to work.
        allowFileAccess: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        javaScriptEnabled: true,
        // Transparent so the WebView surface isn't a black slab before Cesium
        // paints its first frame (the map's own CSS background shows instead).
        transparentBackground: true,
        supportZoom: false,
        // Cesium manages its own gestures inside the canvas.
        useHybridComposition: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onWebViewCreated: (controller) {
        widget.controller.attach(controller);
        controller.addJavaScriptHandler(
          handlerName: 'trailTrackBridge',
          callback: widget.controller.handleBridgeMessage,
        );
      },
      onLoadStop: (controller, url) {
        // The page's inline boot() calls BRIDGE_READY; when we receive it the
        // controller flushes and we send INITIALIZE_MAP.
        widget.controller.initializeMap(
          ionToken: AppConfig.cesiumIonToken,
          sceneMode: _sceneMode,
          imagery: _imagery,
          terrain: widget.enableTerrain,
        );
      },
      onReceivedError: (controller, request, error) {
        if (!mounted) return;
        // A resource error on the main frame is fatal for map rendering.
        if (request.isForMainFrame ?? false) {
          setState(() => _error = 'WebView 로드 오류: ${error.description}');
        }
      },
      onRenderProcessGone: (controller, detail) async {
        // Android killed the WebView renderer (usually memory pressure). The
        // surface would stay black forever — recreate the WebView instead. The
        // reloaded page re-initialises via onLoadStop → MAP_READY, and hosting
        // screens re-push their route/markers through the map-ready listeners.
        if (!mounted) return;
        widget.controller.resetForReload();
        setState(() {
          _webViewEpoch++;
          _loading = true;
          _error = null;
        });
      },
      onConsoleMessage: (controller, msg) {
        // Console passthrough is handled via the LOG bridge message; this is a
        // secondary sink for uncaught JS errors during development.
        if (kDebugMode) debugPrint('[cesium:console] ${msg.message}');
      },
    );
  }

  Widget _controls() {
    return Column(
      children: [
        // Layer toggle: OSM street ↔ ion satellite. The label shows the mode
        // you'll switch TO.
        _ControlButton(
          icon: _imagery == MapImagery.street
              ? Icons.satellite_alt_outlined
              : Icons.map_outlined,
          tooltip: _imagery == MapImagery.street ? '위성 지도' : '일반 지도',
          onTap: () {
            setState(() => _imagery = _imagery.toggled);
            widget.controller.setImagery(_imagery);
          },
        ),
        _ControlButton(
          label: _sceneMode == SceneMode.d3 ? '3D' : '2D',
          tooltip: '2D/3D 전환',
          onTap: () {
            setState(() {
              _sceneMode = _sceneMode == SceneMode.d3
                  ? SceneMode.d2
                  : SceneMode.d3;
            });
            widget.controller.setSceneMode(_sceneMode);
          },
        ),
        _ControlButton(
          icon: Icons.explore_outlined,
          tooltip: '북쪽 정렬',
          onTap: widget.controller.setNorthUp,
        ),
        _ControlButton(
          icon: Icons.my_location,
          tooltip: '현재 위치',
          onTap: widget.onLocate ?? () => widget.controller.flyToRoute(),
        ),
        _ControlButton(
          icon: Icons.add,
          tooltip: '확대',
          onTap: () => widget.controller.zoom(zoomIn: true),
        ),
        _ControlButton(
          icon: Icons.remove,
          tooltip: '축소',
          onTap: () => widget.controller.zoom(zoomIn: false),
        ),
        if (widget.onControlsBuilt != null) widget.onControlsBuilt!(context),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    this.icon,
    this.label,
    required this.tooltip,
    required this.onTap,
  });

  final IconData? icon;
  final String? label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: AppColors.secondary, size: 22)
                    : Text(
                        label ?? '',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('지도를 불러오는 중…'),
        ],
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_outlined, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
