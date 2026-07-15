import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/features/map/cesium_bridge.dart';
import 'package:trailtrack/features/map/cesium_map_controller.dart';

void main() {
  group('MapPoint serialization', () {
    test('includes seg and optional alt/t', () {
      const p = MapPoint(lat: 37.5, lon: 127.0, alt: 300, seg: 2, t: 1000);
      expect(p.toJson(), {
        'lat': 37.5,
        'lon': 127.0,
        'alt': 300,
        'seg': 2,
        't': 1000,
      });
    });

    test('omits alt/t when null', () {
      const p = MapPoint(lat: 1, lon: 2);
      final json = p.toJson();
      expect(json.containsKey('alt'), isFalse);
      expect(json.containsKey('t'), isFalse);
      expect(json['seg'], 0);
    });
  });

  group('MapPhotoMarker serialization', () {
    test('carries id and count', () {
      const m = MapPhotoMarker(id: 'abc', lat: 1, lon: 2, count: 3);
      expect(m.toJson()['id'], 'abc');
      expect(m.toJson()['count'], 3);
    });
  });

  group('CesiumMapController inbound routing', () {
    test('BRIDGE_READY marks bridge ready', () {
      final c = CesiumMapController();
      expect(c.bridgeReady, isFalse);
      c.handleBridgeMessage([
        jsonEncode({'type': CesiumIn.bridgeReady, 'payload': {}}),
      ]);
      expect(c.bridgeReady, isTrue);
    });

    test('MAP_READY reports terrain flag via callback', () {
      final c = CesiumMapController();
      bool? terrain;
      c.addMapReadyListener((t) => terrain = t);
      c.handleBridgeMessage([
        jsonEncode({
          'type': CesiumIn.mapReady,
          'payload': {'terrain': true},
        }),
      ]);
      expect(c.mapReady, isTrue);
      expect(terrain, isTrue);
    });

    test(
      'MAP_READY notifies ALL listeners (regression: single-slot clobber)',
      () {
        final c = CesiumMapController();
        var viewReady = false; // e.g. CesiumMapView hiding its loading overlay
        var screenReady = false; // e.g. detail screen pushing the route
        c.addMapReadyListener((_) => viewReady = true);
        c.addMapReadyListener((_) => screenReady = true);
        c.handleBridgeMessage([
          {
            'type': CesiumIn.mapReady,
            'payload': {'terrain': false},
          },
        ]);
        // Both must fire — the old single-callback field let the second caller
        // silently replace the first, leaving the map covered / route unsent.
        expect(viewReady, isTrue);
        expect(screenReady, isTrue);
      },
    );

    test('addMapReadyListener fires immediately if already ready', () {
      final c = CesiumMapController();
      c.handleBridgeMessage([
        {
          'type': CesiumIn.mapReady,
          'payload': {'terrain': true},
        },
      ]);
      // A late subscriber (screen built after MAP_READY) must still run.
      var late = false;
      c.addMapReadyListener((_) => late = true);
      expect(late, isTrue);
    });

    test('TRACK_POINT_SELECTED forwards index and coords', () {
      final c = CesiumMapController();
      int? idx;
      double? lat;
      c.onTrackPointSelected = (i, la, lo) {
        idx = i;
        lat = la;
      };
      c.handleBridgeMessage([
        {
          'type': CesiumIn.trackPointSelected,
          'payload': {'index': 5, 'lat': 37.1, 'lon': 127.2},
        },
      ]);
      expect(idx, 5);
      expect(lat, 37.1);
    });

    test('accepts both String and Map inbound payloads', () {
      final c = CesiumMapController();
      var errors = 0;
      c.addMapErrorListener((message, fatal) => errors++);
      // Map form
      c.handleBridgeMessage([
        {
          'type': CesiumIn.mapError,
          'payload': {'message': 'x', 'fatal': false},
        },
      ]);
      // String form
      c.handleBridgeMessage([
        jsonEncode({
          'type': CesiumIn.mapError,
          'payload': {'message': 'y', 'fatal': true},
        }),
      ]);
      expect(errors, 2);
    });
  });

  group('Wire enums', () {
    test('scene mode / imagery wire values', () {
      expect(SceneMode.d2.wire, '2D');
      expect(SceneMode.d3.wire, '3D');
      expect(MapImagery.street.wire, 'base');
      expect(MapImagery.satellite.wire, 'satellite');
      expect(MapImagery.street.toggled, MapImagery.satellite);
    });
  });
}
