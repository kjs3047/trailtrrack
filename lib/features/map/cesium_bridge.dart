/// Dart side of the Flutter ↔ CesiumJS message bridge.
///
/// Mirrors docs/CESIUM_BRIDGE.md. Message *type* strings are the single source
/// of truth shared with the JS side (assets/cesium/app.js and friends).
library;

/// Flutter → CesiumJS message types.
abstract final class CesiumOut {
  static const initializeMap = 'INITIALIZE_MAP';
  static const setSceneMode = 'SET_SCENE_MODE';
  static const setImagery = 'SET_IMAGERY';
  static const setTerrain = 'SET_TERRAIN';
  static const setCurrentLocation = 'SET_CURRENT_LOCATION';
  static const setTrackPoints = 'SET_TRACK_POINTS';
  static const appendTrackPoints = 'APPEND_TRACK_POINTS';
  static const setPhotoMarkers = 'SET_PHOTO_MARKERS';
  static const clear = 'CLEAR';
  static const flyToRoute = 'FLY_TO_ROUTE';
  static const flyToLocation = 'FLY_TO_LOCATION';
  static const setNorthUp = 'SET_NORTH_UP';
  static const zoom = 'ZOOM';
  static const startRouteReplay = 'START_ROUTE_REPLAY';
  static const pauseRouteReplay = 'PAUSE_ROUTE_REPLAY';
  static const seekRouteReplay = 'SEEK_ROUTE_REPLAY';
  static const setReplaySpeed = 'SET_REPLAY_SPEED';
  static const setReplayFollow = 'SET_REPLAY_FOLLOW';
  static const stopRouteReplay = 'STOP_ROUTE_REPLAY';
  static const lookupDem = 'LOOKUP_DEM';
}

/// CesiumJS → Flutter message types.
abstract final class CesiumIn {
  static const bridgeReady = 'BRIDGE_READY';
  static const mapReady = 'MAP_READY';
  static const mapError = 'MAP_ERROR';
  static const photoMarkerSelected = 'PHOTO_MARKER_SELECTED';
  static const trackPointSelected = 'TRACK_POINT_SELECTED';
  static const replayProgress = 'REPLAY_PROGRESS';
  static const replayFinished = 'REPLAY_FINISHED';
  static const demResult = 'DEM_RESULT';
  static const log = 'LOG';
}

/// Cesium scene mode.
enum SceneMode {
  d2('2D'),
  d3('3D');

  const SceneMode(this.wire);
  final String wire;
}

/// Base map imagery kind. `street` = OpenStreetMap (roads + place names);
/// `satellite` = Cesium ion aerial imagery. Both drape over the DEM terrain.
enum MapImagery {
  street('base'), // wire 'base' kept for JS back-compat
  satellite('satellite');

  const MapImagery(this.wire);
  final String wire;

  MapImagery get toggled =>
      this == MapImagery.street ? MapImagery.satellite : MapImagery.street;

  String get label => this == MapImagery.street ? '지도' : '위성';
}

/// A single point sent to the map for rendering. `seg` marks segment breaks so
/// the polyline is not drawn across GPS gaps (spec §6/§11). `t` is an optional
/// epoch-millis timestamp used to time the 3D replay.
class MapPoint {
  const MapPoint({
    required this.lat,
    required this.lon,
    this.alt,
    this.seg = 0,
    this.t,
  });

  final double lat;
  final double lon;
  final double? alt;
  final int seg;
  final int? t;

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
    if (alt != null) 'alt': alt,
    'seg': seg,
    if (t != null) 't': t,
  };
}

/// A photo marker on the map. `count` renders a badge for co-located photos.
class MapPhotoMarker {
  const MapPhotoMarker({
    required this.id,
    required this.lat,
    required this.lon,
    this.alt,
    this.count = 1,
  });

  final String id;
  final double lat;
  final double lon;
  final double? alt;
  final int count;

  Map<String, dynamic> toJson() => {
    'id': id,
    'lat': lat,
    'lon': lon,
    if (alt != null) 'alt': alt,
    'count': count,
  };
}
