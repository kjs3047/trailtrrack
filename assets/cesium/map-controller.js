/**
 * map-controller.js — Cesium viewer lifecycle, camera, terrain, imagery, and
 * the live/loaded route polyline.
 *
 * Handles INITIALIZE_MAP, SET_SCENE_MODE, SET_IMAGERY, SET_TERRAIN,
 * SET_CURRENT_LOCATION, SET_TRACK_POINTS, APPEND_TRACK_POINTS, CLEAR,
 * FLY_TO_ROUTE, FLY_TO_LOCATION, SET_NORTH_UP, ZOOM, LOOKUP_DEM.
 */
(function () {
  'use strict';

  var TT = window.TrailTrack;

  // Rendering state (renderer-local only; not authoritative track storage).
  var viewer = null;
  var trackPositions = [];   // flat Cartesian3[] for the active route
  var trackSegments = [];    // array of Cartesian3[] split on segment breaks
  var lastSeg = null;
  var routeEntities = [];     // polyline entities (one per segment)
  var currentLocationEntity = null;
  var startEndEntities = [];

  var SAFETY_ORANGE = window.Cesium
    ? Cesium.Color.fromCssColorString('#f26419')
    : null;

  /* ------------------------------------------------------------------ */
  /* INITIALIZE_MAP                                                       */
  /* ------------------------------------------------------------------ */
  TT.on('INITIALIZE_MAP', function (p) {
    if (!window.Cesium) {
      TT.showError('Cesium 라이브러리를 불러오지 못했습니다');
      TT.send('MAP_ERROR', { message: 'Cesium global missing', fatal: true });
      return;
    }
    try {
      if (p.ionToken) {
        Cesium.Ion.defaultAccessToken = p.ionToken;
      }

      viewer = new Cesium.Viewer('cesiumContainer', {
        // Flutter draws all chrome; disable Cesium's widgets.
        animation: false,
        timeline: false,
        geocoder: false,
        homeButton: false,
        sceneModePicker: false,
        baseLayerPicker: false,
        navigationHelpButton: false,
        fullscreenButton: false,
        selectionIndicator: false,
        infoBox: false,
        creditContainer: document.createElement('div'), // hide credits overlay
        // Start with no base imagery so the Viewer never tries to fetch default
        // ion World Imagery at construction (which needs a token). applyImagery
        // adds the correct layer.
        baseLayer: false,
        // CRITICAL for memory/battery on phones: render only when something
        // changed instead of 60fps continuously. Continuous rendering ballooned
        // the WebView renderer to 200-350MB and the app process past 1GB on a
        // real device, until Android killed the renderer (black map) and the
        // app ANRed. Every mutation handler below calls scene.requestRender().
        requestRenderMode: true,
        maximumRenderTimeChange: Infinity,
        sceneMode: (p.sceneMode === '2D')
          ? Cesium.SceneMode.SCENE2D
          : Cesium.SceneMode.SCENE3D,
      });

      // Trim renderer features/memory we don't need on a phone map.
      var sc = viewer.scene;
      // Light clear color: a stalled/late first render shows a light canvas
      // instead of a black slab.
      sc.backgroundColor = Cesium.Color.fromCssColorString('#e8eaec');
      sc.globe.baseColor = Cesium.Color.fromCssColorString('#dfe3e6');
      sc.globe.depthTestAgainstTerrain = true;
      sc.globe.tileCacheSize = 50;                 // default 100
      sc.globe.maximumScreenSpaceError = 2.5;      // default 2 → fewer tiles
      sc.globe.showGroundAtmosphere = false;
      sc.fog.enabled = false;
      if (sc.skyAtmosphere) sc.skyAtmosphere.show = false;
      if (sc.skyBox) sc.skyBox.show = false;
      if (sc.sun) sc.sun.show = false;
      if (sc.moon) sc.moon.show = false;
      if (sc.postProcessStages && sc.postProcessStages.fxaa) {
        sc.postProcessStages.fxaa.enabled = false;
      }
      sc.highDynamicRange = false;
      TT.viewer = viewer;

      // Helper: schedule a frame in requestRenderMode.
      TT.requestRender = function () {
        try { viewer.scene.requestRender(); } catch (e) { /* noop */ }
      };

      applyImagery(p.imagery || 'base');

      // The map is usable as soon as the viewer + imagery exist. Hide the
      // loading overlay immediately so a slow/failed terrain load never leaves
      // the map covered (terrain is non-fatal, spec §14).
      TT.setLoading(false);
      TT.send('MAP_READY', { terrain: false });

      // Terrain is async; upgrade to terrain once resolved (or leave flat).
      var wantTerrain = p.terrain !== false && !!p.ionToken;
      applyTerrain(wantTerrain).then(function (ok) {
        worldTerrain = ok ? viewer.terrainProvider : worldTerrain;
        if (ok) {
          TT.send('MAP_READY', { terrain: true });
          // Route may have been pushed before terrain finished loading.
          drapeTrackOnTerrain();
        }
      });

      installPickHandler();
    } catch (e) {
      TT.showError('지도 초기화 오류: ' + (e && e.message));
      TT.send('MAP_ERROR', { message: String(e && e.message), fatal: true });
    }
  });

  /* ------------------------------------------------------------------ */
  /* Terrain / imagery                                                   */
  /* ------------------------------------------------------------------ */
  function applyTerrain(enabled) {
    if (!enabled) {
      viewer.scene.terrainProvider = new Cesium.EllipsoidTerrainProvider();
      return Promise.resolve(false);
    }
    // Cesium World Terrain via ion (async factory in modern Cesium).
    return Cesium.createWorldTerrainAsync({
      requestVertexNormals: true,
    }).then(function (tp) {
      viewer.terrainProvider = tp;
      if (TT.requestRender) TT.requestRender();
      return true;
    }).catch(function (e) {
      TT.log('warn', 'terrain load failed, falling back to ellipsoid: ' +
        (e && e.message));
      viewer.scene.terrainProvider = new Cesium.EllipsoidTerrainProvider();
      // Non-fatal: map still works, GPS recording unaffected (spec §14).
      TT.send('MAP_ERROR', { message: 'terrain unavailable', fatal: false });
      return false;
    });
  }

  TT.on('SET_TERRAIN', function (p) {
    if (!viewer) return;
    applyTerrain(!!p.enabled).then(function (ok) {
      TT.send('MAP_READY', { terrain: ok });
    });
  });

  function applyImagery(kind) {
    if (!viewer) return;
    var layers = viewer.imageryLayers;
    layers.removeAll();
    try {
      if (kind === 'satellite') {
        // ion Bing/Sentinel imagery (asset 3 = Bing Aerial). Requires token.
        Cesium.IonImageryProvider.fromAssetId(3).then(function (prov) {
          layers.addImageryProvider(prov);
          TT.requestRender();
        }).catch(function (e) {
          TT.log('warn', 'satellite imagery failed: ' + (e && e.message));
          addStreetImagery(layers);
        });
      } else {
        // "street": OpenStreetMap — roads and place names, works on the 3D
        // globe and drapes over the DEM terrain just like satellite imagery.
        addStreetImagery(layers);
      }
    } catch (e) {
      addStreetImagery(layers);
    }
  }

  // OpenStreetMap raster tiles. Online tile source; imagery is independent of
  // the terrain/DEM layer, so 3D relief still works underneath it.
  function addStreetImagery(layers) {
    layers.addImageryProvider(
      new Cesium.OpenStreetMapImageryProvider({
        url: 'https://tile.openstreetmap.org/',
      })
    );
    if (TT.requestRender) TT.requestRender();
  }

  TT.on('SET_IMAGERY', function (p) { applyImagery(p.imagery || 'base'); });

  /* ------------------------------------------------------------------ */
  /* Scene mode 2D/3D                                                    */
  /* ------------------------------------------------------------------ */
  // World Terrain provider kept so we can swap between it (3D) and a flat
  // ellipsoid (2D) — ground-clamped geometry z-fights against real terrain in
  // the flat 2D projection ("CRT breakup").
  var worldTerrain = null;
  var ellipsoidTerrain = null;

  TT.on('SET_SCENE_MODE', function (p) {
    if (!viewer) return;
    var to2D = p.mode === '2D';
    // No-op if already in the requested mode.
    var already2D = viewer.scene.mode === Cesium.SceneMode.SCENE2D;
    if (to2D === already2D) return;

    // Preserve the look-at CENTER + camera HEIGHT (zoom). Rectangle-based
    // restore distorts badly from tilted 3D views and reset the zoom level.
    var centerCarto = null;
    var camHeight = null;
    try {
      var canvas = viewer.scene.canvas;
      var mid = new Cesium.Cartesian2(
        canvas.clientWidth / 2, canvas.clientHeight / 2);
      var picked = viewer.camera.pickEllipsoid(mid, Cesium.Ellipsoid.WGS84);
      if (picked) centerCarto = Cesium.Cartographic.fromCartesian(picked);
      camHeight = viewer.camera.positionCartographic.height;
    } catch (e) { /* ignore */ }

    if (!ellipsoidTerrain) {
      ellipsoidTerrain = new Cesium.EllipsoidTerrainProvider();
    }

    // Swap terrain BEFORE the morph so the whole animation runs in the correct
    // state. Ground-clamped geometry z-fights against real World Terrain in the
    // flat 2D projection ("CRT breakup"); a flat ellipsoid + no depth-test
    // renders cleanly. Restore World Terrain before morphing back to 3D.
    if (to2D) {
      if (viewer.terrainProvider !== ellipsoidTerrain) {
        worldTerrain = worldTerrain || viewer.terrainProvider;
        viewer.terrainProvider = ellipsoidTerrain;
      }
      viewer.scene.globe.depthTestAgainstTerrain = false;
    } else {
      if (worldTerrain && viewer.terrainProvider !== worldTerrain) {
        viewer.terrainProvider = worldTerrain;
      }
      viewer.scene.globe.depthTestAgainstTerrain = true;
    }

    function onMorphDone() {
      viewer.scene.morphComplete.removeEventListener(onMorphDone);
      // Restore the previous center + zoom (camera height) instantly.
      if (centerCarto && camHeight && isFinite(camHeight)) {
        viewer.camera.setView({
          destination: Cesium.Cartesian3.fromRadians(
            centerCarto.longitude, centerCarto.latitude, camHeight),
        });
      }
      viewer.scene.requestRender();
    }

    viewer.scene.morphComplete.addEventListener(onMorphDone);
    if (to2D) {
      viewer.scene.morphTo2D(0.6);
    } else {
      viewer.scene.morphTo3D(0.6);
    }
  });

  /* ------------------------------------------------------------------ */
  /* Current location marker                                             */
  /* ------------------------------------------------------------------ */
  var lastFollowMs = 0;

  TT.on('SET_CURRENT_LOCATION', function (p) {
    if (!viewer) return;
    var pos = Cesium.Cartesian3.fromDegrees(p.lon, p.lat, p.alt || 0);
    if (!currentLocationEntity) {
      currentLocationEntity = viewer.entities.add({
        position: pos,
        point: {
          pixelSize: 14,
          color: Cesium.Color.fromCssColorString('#154212'),
          outlineColor: Cesium.Color.WHITE,
          outlineWidth: 3,
          // NONE (not CLAMP_TO_GROUND): ground-clamped points vanish in the 2D
          // projection. The position carries GPS altitude and depth-testing is
          // disabled, so the marker stays visible in both 2D and 3D.
          heightReference: Cesium.HeightReference.NONE,
          disableDepthTestDistance: Number.POSITIVE_INFINITY,
        },
      });
    } else {
      currentLocationEntity.position = pos;
    }
    if (p.follow) {
      var now = Date.now();
      var explicit = p.zoomTo != null;
      // Throttle passive recording-follow recentering: a camera flight per GPS
      // fix caused constant re-render + tile churn (memory blow-up on device).
      if (explicit || now - lastFollowMs > 2500) {
        lastFollowMs = now;
        var height;
        if (explicit) {
          height = p.zoomTo; // explicit locate → zoom in
        } else {
          height = 1500;
          try {
            var h = viewer.camera.positionCartographic.height;
            if (h && isFinite(h) && h > 50) height = h;
          } catch (e) { /* use default */ }
        }
        viewer.camera.flyTo({
          destination: Cesium.Cartesian3.fromDegrees(p.lon, p.lat, height),
          duration: 0.8,
        });
      }
    }
    TT.requestRender();
  });

  /* ------------------------------------------------------------------ */
  /* Route polyline (segment-aware — never bridges GPS gaps, spec §6/§11)*/
  /* ------------------------------------------------------------------ */
  function rebuildRouteEntities() {
    routeEntities.forEach(function (e) { viewer.entities.remove(e); });
    routeEntities = [];
    trackSegments.forEach(function (segPositions) {
      if (segPositions.length < 2) return;
      var e = viewer.entities.add({
        polyline: {
          positions: segPositions,
          width: 5,
          material: new Cesium.PolylineOutlineMaterialProperty({
            color: SAFETY_ORANGE,
            outlineColor: Cesium.Color.WHITE,
            outlineWidth: 1,
          }),
        },
      });
      routeEntities.push(e);
    });
    updateStartEndMarkers();
  }

  // Drape the loaded route onto the DEM: sample terrain heights for every
  // track point and redraw the line at surface height (+1.5 m so the
  // depth-tested line doesn't clip into the ground). Raw GPS altitudes float
  // above or sink below the terrain, which looks broken in 3D.
  // NOTE: polyline.clampToGround is deliberately NOT used — GroundPolyline
  // support is missing on some Android WebView GPUs and a failure there stops
  // the whole Cesium render loop ("Rendering has stopped").
  var terrainDrapeSeq = 0;
  function drapeTrackOnTerrain() {
    if (!viewer || !worldTerrain || trackSegments.length === 0) return;
    var seq = ++terrainDrapeSeq;
    var cartos = [];
    trackSegments.forEach(function (seg) {
      seg.forEach(function (c) {
        cartos.push(Cesium.Cartographic.fromCartesian(c));
      });
    });
    Cesium.sampleTerrainMostDetailed(worldTerrain, cartos)
      .then(function (sampled) {
        if (seq !== terrainDrapeSeq || !viewer) return;
        var i = 0;
        trackSegments = trackSegments.map(function (seg) {
          return seg.map(function () {
            var c = sampled[i++];
            var h = (typeof c.height === 'number' && isFinite(c.height))
              ? c.height + 1.5 : 1.5;
            return Cesium.Cartesian3.fromRadians(c.longitude, c.latitude, h);
          });
        });
        trackPositions = [];
        trackSegments.forEach(function (seg) {
          seg.forEach(function (c) { trackPositions.push(c); });
        });
        rebuildRouteEntities();
        TT.requestRender();
      })
      .catch(function () { /* terrain unavailable — keep GPS heights */ });
  }

  // Incremental variant for live recording: sample terrain heights ONLY for the
  // freshly-appended positions and drop them onto the DEM in place, so the live
  // 3D route hugs the ground without re-sampling the whole track every fix.
  // `newCartesians` is the exact array of Cartesian3 objects pushPoints just
  // created and pushed into trackSegments/trackPositions — we replace those
  // same references by identity, so segment/gap structure is untouched.
  function drapeAppendedPoints(newCartesians) {
    if (!viewer || !worldTerrain || !newCartesians ||
        newCartesians.length === 0) {
      return;
    }
    var targets = newCartesians.slice();
    var cartos = targets.map(function (c) {
      return Cesium.Cartographic.fromCartesian(c);
    });
    Cesium.sampleTerrainMostDetailed(worldTerrain, cartos)
      .then(function (sampled) {
        if (!viewer) return;
        var changed = false;
        for (var k = 0; k < targets.length; k++) {
          var carto = sampled[k];
          var h = (typeof carto.height === 'number' && isFinite(carto.height))
            ? carto.height + 1.5 : 1.5;
          var draped = Cesium.Cartesian3.fromRadians(
            carto.longitude, carto.latitude, h);
          var oldRef = targets[k];
          // Swap the reference in whichever segment still holds it.
          for (var s = 0; s < trackSegments.length; s++) {
            var seg = trackSegments[s];
            var idx = seg.indexOf(oldRef);
            if (idx !== -1) { seg[idx] = draped; changed = true; break; }
          }
          var pidx = trackPositions.indexOf(oldRef);
          if (pidx !== -1) trackPositions[pidx] = draped;
        }
        if (!changed) return;
        rebuildRouteEntities();
        TT.requestRender();
      })
      .catch(function () { /* terrain unavailable — keep GPS heights */ });
  }

  function pushPoints(points) {
    var pushed = [];
    points.forEach(function (pt) {
      var seg = (pt.seg == null) ? 0 : pt.seg;
      if (seg !== lastSeg) {
        trackSegments.push([]); // start a new segment (GPS gap boundary)
        lastSeg = seg;
      }
      var c = Cesium.Cartesian3.fromDegrees(pt.lon, pt.lat, pt.alt || 0);
      trackSegments[trackSegments.length - 1].push(c);
      trackPositions.push(c);
      pushed.push(c);
    });
    return pushed;
  }

  TT.on('SET_TRACK_POINTS', function (p) {
    if (!viewer) return;
    trackPositions = [];
    trackSegments = [];
    lastSeg = null;
    pushPoints(p.points || []);
    rebuildRouteEntities();
    drapeTrackOnTerrain();
    // Expose to the route player.
    TT._trackData = p.points || [];
    if (p.fit) flyToRoute(1.5);
    TT.requestRender();
  });

  TT.on('APPEND_TRACK_POINTS', function (p) {
    if (!viewer) return;
    var before = trackSegments.length;
    var lastLenBefore = before > 0
      ? trackSegments[before - 1].length : 0;
    var pushed = pushPoints(p.points || []);
    // Cheap path ONLY when appending to a segment that ALREADY has its own
    // polyline entity (>=2 points before this append) and no new segment was
    // created. Previously a freshly-born segment (1 point) reaching 2 points
    // hijacked the PREVIOUS segment's entity, wiping the older route from the
    // live map (the "쉬었다 걸으면 이전 경로가 사라짐" bug).
    if (trackSegments.length === before && lastLenBefore >= 2 &&
        routeEntities.length > 0) {
      var last = trackSegments[trackSegments.length - 1];
      routeEntities[routeEntities.length - 1].polyline.positions = last;
      // Keep the end marker on the newest point (rebuild path does this too).
      if (startEndEntities.length > 1) {
        startEndEntities[1].position = trackPositions[trackPositions.length - 1];
      }
    } else {
      rebuildRouteEntities();
    }
    // Drop the just-added points onto the DEM so the live 3D route hugs the
    // terrain (in 2D this is a no-op visually). Async + cheap: only the new
    // points are sampled, then the affected polyline is rebuilt on resolve.
    drapeAppendedPoints(pushed);
    (TT._trackData || (TT._trackData = [])).push.apply(
      TT._trackData, p.points || []);
    TT.requestRender();
  });

  TT.on('CLEAR', function () {
    if (!viewer) return;
    routeEntities.forEach(function (e) { viewer.entities.remove(e); });
    startEndEntities.forEach(function (e) { viewer.entities.remove(e); });
    if (currentLocationEntity) viewer.entities.remove(currentLocationEntity);
    routeEntities = [];
    startEndEntities = [];
    currentLocationEntity = null;
    trackPositions = [];
    trackSegments = [];
    lastSeg = null;
    TT._trackData = [];
    TT.requestRender();
  });

  function updateStartEndMarkers() {
    startEndEntities.forEach(function (e) { viewer.entities.remove(e); });
    startEndEntities = [];
    if (trackPositions.length === 0) return;
    startEndEntities.push(viewer.entities.add({
      position: trackPositions[0],
      point: {
        pixelSize: 12,
        color: Cesium.Color.fromCssColorString('#2d5a27'),
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 2,
        heightReference: Cesium.HeightReference.NONE,
        disableDepthTestDistance: Number.POSITIVE_INFINITY,
      },
    }));
    if (trackPositions.length > 1) {
      startEndEntities.push(viewer.entities.add({
        position: trackPositions[trackPositions.length - 1],
        point: {
          pixelSize: 12,
          color: Cesium.Color.fromCssColorString('#ba1a1a'),
          outlineColor: Cesium.Color.WHITE,
          outlineWidth: 2,
          // NONE, not CLAMP_TO_GROUND: ground-clamped points vanish in the 2D
          // projection (no terrain) — that was why the red end marker
          // disappeared in 2D while the green start marker (NONE) stayed. The
          // route drape already lifts trackPositions onto the DEM, so NONE
          // still sits on the terrain in 3D.
          heightReference: Cesium.HeightReference.NONE,
          disableDepthTestDistance: Number.POSITIVE_INFINITY,
        },
      }));
    }
  }

  /* ------------------------------------------------------------------ */
  /* Camera helpers                                                      */
  /* ------------------------------------------------------------------ */
  function flyToRoute(durationSec) {
    if (trackPositions.length === 0) return;
    if (trackPositions.length === 1) {
      viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromRadians(
          Cesium.Cartographic.fromCartesian(trackPositions[0]).longitude,
          Cesium.Cartographic.fromCartesian(trackPositions[0]).latitude,
          2000),
        duration: durationSec || 1.5,
      });
      return;
    }
    var sphere = Cesium.BoundingSphere.fromPoints(trackPositions);
    viewer.camera.flyToBoundingSphere(sphere, {
      duration: durationSec || 1.5,
      offset: new Cesium.HeadingPitchRange(
        0, Cesium.Math.toRadians(-45), sphere.radius * 2.5),
    });
  }

  TT.on('FLY_TO_ROUTE', function (p) { flyToRoute(p && p.durationSec); });

  TT.on('FLY_TO_LOCATION', function (p) {
    if (!viewer) return;
    viewer.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(
        p.lon, p.lat, p.alt || 2000),
      duration: p.durationSec || 1.5,
    });
  });

  TT.on('SET_NORTH_UP', function () {
    if (!viewer) return;
    var cam = viewer.camera;
    if (viewer.scene.mode === Cesium.SceneMode.SCENE2D) {
      // 2D: flyTo with a world-space destination breaks the flat projection
      // (graphic corruption). Instantly reset heading via setView at the same
      // center + zoom.
      var carto = cam.positionCartographic;
      cam.setView({
        destination: Cesium.Cartesian3.fromRadians(
          carto.longitude, carto.latitude, carto.height),
        orientation: {
          heading: 0.0,
          pitch: -Cesium.Math.PI_OVER_TWO,
          roll: 0.0,
        },
      });
    } else {
      // 3D: keep the eye position, animate heading back to north.
      cam.flyTo({
        destination: cam.positionWC.clone(),
        orientation: { heading: 0.0, pitch: cam.pitch, roll: 0.0 },
        duration: 0.5,
      });
    }
    TT.requestRender();
  });

  TT.on('ZOOM', function (p) {
    if (!viewer) return;
    var amount = viewer.camera.positionCartographic.height * 0.4;
    if (p.direction === 'in') viewer.camera.zoomIn(amount);
    else viewer.camera.zoomOut(amount);
    TT.requestRender();
  });

  /* ------------------------------------------------------------------ */
  /* DEM batch lookup (spec §8)                                          */
  /* ------------------------------------------------------------------ */
  TT.on('LOOKUP_DEM', function (p) {
    if (!viewer) {
      TT.send('DEM_RESULT', { requestId: p.requestId, heights: [] });
      return;
    }
    var pts = p.points || [];
    var cartographics = pts.map(function (pt) {
      return Cesium.Cartographic.fromDegrees(pt.lon, pt.lat);
    });
    var provider = viewer.terrainProvider;
    // sampleTerrainMostDetailed needs a real terrain provider; ellipsoid → 0.
    Cesium.sampleTerrainMostDetailed(provider, cartographics)
      .then(function (updated) {
        var heights = updated.map(function (c, i) {
          return {
            lat: pts[i].lat,
            lon: pts[i].lon,
            height: (c.height == null || isNaN(c.height)) ? null : c.height,
          };
        });
        TT.send('DEM_RESULT', { requestId: p.requestId, heights: heights });
      })
      .catch(function (e) {
        TT.log('warn', 'DEM lookup failed: ' + (e && e.message));
        TT.send('DEM_RESULT', {
          requestId: p.requestId,
          heights: pts.map(function () { return null; }),
        });
      });
  });

  /* ------------------------------------------------------------------ */
  /* Pick handler → TRACK_POINT_SELECTED / PHOTO_MARKER_SELECTED         */
  /* ------------------------------------------------------------------ */
  function installPickHandler() {
    var handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);
    handler.setInputAction(function (click) {
      var picked = viewer.scene.pick(click.position);
      if (Cesium.defined(picked) && picked.id) {
        var id = picked.id;
        // Cluster pick: Cesium returns an ARRAY of clustered entities (the
        // "2" badge). Open the first photo — the gallery swipes through all.
        if (Array.isArray(id)) {
          for (var ci = 0; ci < id.length; ci++) {
            if (id[ci].ttPhotoId) {
              TT.send('PHOTO_MARKER_SELECTED', { id: id[ci].ttPhotoId });
              return;
            }
          }
        }
        if (id.ttPhotoId) {
          TT.send('PHOTO_MARKER_SELECTED', { id: id.ttPhotoId });
          return;
        }
      }
      // Fall back to a ground pick → nearest route index.
      var cartesian = viewer.scene.pickPosition(click.position);
      if (Cesium.defined(cartesian) && trackPositions.length) {
        var idx = nearestTrackIndex(cartesian);
        var carto = Cesium.Cartographic.fromCartesian(trackPositions[idx]);
        TT.send('TRACK_POINT_SELECTED', {
          index: idx,
          lat: Cesium.Math.toDegrees(carto.latitude),
          lon: Cesium.Math.toDegrees(carto.longitude),
        });
      }
    }, Cesium.ScreenSpaceEventType.LEFT_CLICK);
  }

  function nearestTrackIndex(cartesian) {
    var best = 0, bestD = Infinity;
    for (var i = 0; i < trackPositions.length; i++) {
      var d = Cesium.Cartesian3.distanceSquared(cartesian, trackPositions[i]);
      if (d < bestD) { bestD = d; best = i; }
    }
    return best;
  }

  // Expose selected internals for the route player.
  TT._map = {
    getViewer: function () { return viewer; },
    getTrackPositions: function () { return trackPositions; },
  };
})();
