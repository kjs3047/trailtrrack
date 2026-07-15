import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'cesium_bridge.dart';

/// Imperative controller for a [CesiumMapView].
///
/// Wraps the WebView's [InAppWebViewController] and exposes typed methods that
/// serialise to the JSON bridge (docs/CESIUM_BRIDGE.md). Outbound calls are
/// queued until the JS bridge signals `BRIDGE_READY`, so callers never have to
/// race the WebView load.
class CesiumMapController extends ChangeNotifier {
  InAppWebViewController? _web;
  bool _bridgeReady = false;
  bool _mapReady = false;
  bool _terrainLoaded = false;
  final List<String> _pending = [];

  // Inbound event callbacks. Ready/error are MULTI-listener so that both the
  // CesiumMapView (to hide its loading overlay) and the hosting screen (to push
  // the route / current location) can react — a single-callback field let the
  // screen silently clobber the view's handler, leaving the loading overlay up
  // forever and hiding the map.
  final List<void Function(bool terrainLoaded)> _onMapReady = [];
  final List<void Function(String message, bool fatal)> _onMapError = [];
  void Function(String photoId)? onPhotoMarkerSelected;
  void Function(int index, double lat, double lon)? onTrackPointSelected;
  void Function(ReplayProgress progress)? onReplayProgress;
  void Function()? onReplayFinished;

  /// Register a map-ready listener. If the map is already ready, fires
  /// immediately (so late subscribers on a reused controller still run).
  void addMapReadyListener(void Function(bool terrainLoaded) fn) {
    _onMapReady.add(fn);
    if (_mapReady) fn(_terrainLoaded);
  }

  void removeMapReadyListener(void Function(bool terrainLoaded) fn) =>
      _onMapReady.remove(fn);

  void addMapErrorListener(void Function(String message, bool fatal) fn) =>
      _onMapError.add(fn);

  void removeMapErrorListener(void Function(String message, bool fatal) fn) =>
      _onMapError.remove(fn);

  final Map<String, Completer<List<DemHeight?>>> _demRequests = {};
  int _demSeq = 0;

  bool get bridgeReady => _bridgeReady;
  bool get mapReady => _mapReady;
  bool get terrainLoaded => _terrainLoaded;

  /// Called by [CesiumMapView] once the WebView is created.
  void attach(InAppWebViewController controller) {
    _web = controller;
  }

  /// Called when the WebView is being recreated (e.g. Android killed the
  /// renderer process under memory pressure). Clears bridge/map readiness so
  /// the reloaded page re-initialises cleanly and queued sends don't target a
  /// dead WebView.
  void resetForReload() {
    _web = null;
    _bridgeReady = false;
    _mapReady = false;
    _terrainLoaded = false;
    _pending.clear();
    notifyListeners();
  }

  /// Handles inbound messages (registered as the `trailTrackBridge` JS handler).
  /// The JS side calls `callHandler('trailTrackBridge', message)`.
  dynamic handleBridgeMessage(List<dynamic> args) {
    if (args.isEmpty) return null;
    final raw = args.first;
    final Map<String, dynamic> msg = raw is String
        ? jsonDecode(raw) as Map<String, dynamic>
        : Map<String, dynamic>.from(raw as Map);
    final type = msg['type'] as String?;
    final payload = (msg['payload'] as Map?)?.cast<String, dynamic>() ?? {};

    switch (type) {
      case CesiumIn.bridgeReady:
        _bridgeReady = true;
        _flushPending();
        notifyListeners();
      case CesiumIn.mapReady:
        _mapReady = true;
        _terrainLoaded = payload['terrain'] == true;
        for (final fn in List.of(_onMapReady)) {
          fn(_terrainLoaded);
        }
        notifyListeners();
      case CesiumIn.mapError:
        final message = (payload['message'] ?? 'map error').toString();
        final fatal = payload['fatal'] == true;
        for (final fn in List.of(_onMapError)) {
          fn(message, fatal);
        }
      case CesiumIn.photoMarkerSelected:
        onPhotoMarkerSelected?.call(payload['id'].toString());
      case CesiumIn.trackPointSelected:
        onTrackPointSelected?.call(
          (payload['index'] as num?)?.toInt() ?? 0,
          (payload['lat'] as num?)?.toDouble() ?? 0,
          (payload['lon'] as num?)?.toDouble() ?? 0,
        );
      case CesiumIn.replayProgress:
        onReplayProgress?.call(ReplayProgress.fromJson(payload));
      case CesiumIn.replayFinished:
        onReplayFinished?.call();
      case CesiumIn.demResult:
        _resolveDem(payload);
      case CesiumIn.log:
        if (kDebugMode) {
          debugPrint('[cesium:${payload['level']}] ${payload['message']}');
        }
      default:
        if (kDebugMode) debugPrint('[cesium] unhandled inbound: $type');
    }
    return null;
  }

  /* ----------------------------- outbound ------------------------------- */

  void _send(String type, [Map<String, dynamic>? payload]) {
    final json = jsonEncode({'type': type, 'payload': payload ?? {}});
    // Deliver via window.TrailTrack.receive on the JS side.
    final js =
        'window.TrailTrack && window.TrailTrack.receive('
        '${jsonEncode(json)});';
    if (_bridgeReady && _web != null) {
      _web!.evaluateJavascript(source: js);
    } else {
      _pending.add(js);
    }
  }

  void _flushPending() {
    if (_web == null) return;
    for (final js in _pending) {
      _web!.evaluateJavascript(source: js);
    }
    _pending.clear();
  }

  /// Boot the Cesium viewer. Call once after the map is shown.
  void initializeMap({
    required String? ionToken,
    SceneMode sceneMode = SceneMode.d3,
    MapImagery imagery = MapImagery.street,
    bool terrain = true,
  }) {
    _send(CesiumOut.initializeMap, {
      if (ionToken != null && ionToken.isNotEmpty) 'ionToken': ionToken,
      'sceneMode': sceneMode.wire,
      'imagery': imagery.wire,
      'terrain': terrain,
    });
  }

  void setSceneMode(SceneMode mode) =>
      _send(CesiumOut.setSceneMode, {'mode': mode.wire});

  void setImagery(MapImagery imagery) =>
      _send(CesiumOut.setImagery, {'imagery': imagery.wire});

  void setTerrain(bool enabled) =>
      _send(CesiumOut.setTerrain, {'enabled': enabled});

  void setCurrentLocation({
    required double lat,
    required double lon,
    double? alt,
    double? accuracy,
    double? heading,
    bool follow = false,
    double? zoomTo,
  }) => _send(CesiumOut.setCurrentLocation, {
    'lat': lat,
    'lon': lon,
    if (alt != null) 'alt': alt,
    if (accuracy != null) 'accuracy': accuracy,
    if (heading != null) 'heading': heading,
    'follow': follow,
    // When set, the camera flies to this height (metres). Used by the explicit
    // "current location" button to zoom in. Omitted during passive recording
    // follow so the user's chosen zoom is preserved.
    if (zoomTo != null) 'zoomTo': zoomTo,
  });

  void setTrackPoints(List<MapPoint> points, {bool fit = false}) => _send(
    CesiumOut.setTrackPoints,
    {'points': points.map((p) => p.toJson()).toList(), 'fit': fit},
  );

  void appendTrackPoints(List<MapPoint> points) => _send(
    CesiumOut.appendTrackPoints,
    {'points': points.map((p) => p.toJson()).toList()},
  );

  void setPhotoMarkers(List<MapPhotoMarker> markers) => _send(
    CesiumOut.setPhotoMarkers,
    {'markers': markers.map((m) => m.toJson()).toList()},
  );

  void clear() => _send(CesiumOut.clear);

  void flyToRoute({double? durationSec}) => _send(CesiumOut.flyToRoute, {
    if (durationSec != null) 'durationSec': durationSec,
  });

  void flyToLocation(
    double lat,
    double lon, {
    double? alt,
    double? durationSec,
  }) => _send(CesiumOut.flyToLocation, {
    'lat': lat,
    'lon': lon,
    if (alt != null) 'alt': alt,
    if (durationSec != null) 'durationSec': durationSec,
  });

  void setNorthUp() => _send(CesiumOut.setNorthUp);

  void zoom({required bool zoomIn}) =>
      _send(CesiumOut.zoom, {'direction': zoomIn ? 'in' : 'out'});

  // Replay
  void startReplay({int speed = 1, bool follow = false}) =>
      _send(CesiumOut.startRouteReplay, {'speed': speed, 'follow': follow});
  void pauseReplay() => _send(CesiumOut.pauseRouteReplay);
  void seekReplay(double fraction) =>
      _send(CesiumOut.seekRouteReplay, {'fraction': fraction});
  void setReplaySpeed(int speed) =>
      _send(CesiumOut.setReplaySpeed, {'speed': speed});
  void setReplayFollow(bool follow) =>
      _send(CesiumOut.setReplayFollow, {'follow': follow});
  void stopReplay() => _send(CesiumOut.stopRouteReplay);

  /// Batch DEM height lookup (spec §8). Resolves with one entry per input point;
  /// entries may be null if that sample failed.
  Future<List<DemHeight?>> lookupDem(List<({double lat, double lon})> points) {
    final requestId = 'dem_${_demSeq++}';
    final completer = Completer<List<DemHeight?>>();
    _demRequests[requestId] = completer;
    _send(CesiumOut.lookupDem, {
      'requestId': requestId,
      'points': points.map((p) => {'lat': p.lat, 'lon': p.lon}).toList(),
    });
    // Safety timeout so callers are never stuck if the map died.
    Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        _demRequests.remove(requestId);
        completer.complete(List<DemHeight?>.filled(points.length, null));
      }
    });
    return completer.future;
  }

  void _resolveDem(Map<String, dynamic> payload) {
    final id = payload['requestId']?.toString();
    final completer = id == null ? null : _demRequests.remove(id);
    if (completer == null || completer.isCompleted) return;
    final heights = (payload['heights'] as List?) ?? [];
    completer.complete(
      heights.map<DemHeight?>((h) {
        if (h == null) return null;
        final m = (h as Map).cast<String, dynamic>();
        final height = m['height'];
        if (height == null) return null;
        return DemHeight(
          lat: (m['lat'] as num).toDouble(),
          lon: (m['lon'] as num).toDouble(),
          height: (height as num).toDouble(),
        );
      }).toList(),
    );
  }
}

/// Live replay progress payload.
class ReplayProgress {
  const ReplayProgress({
    required this.fraction,
    required this.speed,
    required this.distance,
    this.lat,
    this.lon,
    this.alt,
  });

  final double fraction;
  final double speed; // m/s
  final double distance; // m
  final double? lat;
  final double? lon;
  final double? alt;

  factory ReplayProgress.fromJson(Map<String, dynamic> j) => ReplayProgress(
    fraction: (j['fraction'] as num?)?.toDouble() ?? 0,
    speed: (j['speed'] as num?)?.toDouble() ?? 0,
    distance: (j['distance'] as num?)?.toDouble() ?? 0,
    lat: (j['lat'] as num?)?.toDouble(),
    lon: (j['lon'] as num?)?.toDouble(),
    alt: (j['alt'] as num?)?.toDouble(),
  );
}

/// A single DEM height sample.
class DemHeight {
  const DemHeight({required this.lat, required this.lon, required this.height});
  final double lat;
  final double lon;
  final double height;
}
