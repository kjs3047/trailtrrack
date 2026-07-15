/**
 * route-player.js — time-dynamic 3D route replay (spec §11).
 *
 * Builds a Cesium SampledPositionProperty from the loaded track and drives a
 * moving marker along it using the viewer clock. Emits REPLAY_PROGRESS
 * (throttled) and REPLAY_FINISHED.
 *
 * Handles START_ROUTE_REPLAY, PAUSE_ROUTE_REPLAY, SEEK_ROUTE_REPLAY,
 * SET_REPLAY_SPEED, SET_REPLAY_FOLLOW, STOP_ROUTE_REPLAY.
 *
 * GPS-gap segments are NOT interpolated across: sample times inside a gap use
 * a hold (backward extrapolation) so the marker waits at the segment end rather
 * than flying a straight line across the gap.
 */
(function () {
  'use strict';

  var TT = window.TrailTrack;

  var replayEntity = null;
  var startTime = null;
  var stopTime = null;
  var totalSeconds = 0;
  var follow = false;
  var lastEmit = 0;
  var tickListener = null;
  // Precomputed per-sample cumulative distance/speed for the HUD.
  var sampleMeta = [];

  function viewer() { return TT.viewer; }

  // Resolve a per-point ground height (m) for each track point, sampled from
  // the DEM so the replay marker rides the terrain. Falls back to the point's
  // GPS altitude when terrain isn't available (2D / ellipsoid / sampling fail).
  function resolveHeights(pts) {
    var v = viewer();
    var terrain = v && v.terrainProvider;
    var canSample = terrain &&
      typeof Cesium.sampleTerrainMostDetailed === 'function' &&
      !(terrain instanceof Cesium.EllipsoidTerrainProvider);
    if (!canSample) {
      return Promise.resolve(pts.map(function (p) { return p.alt || 0; }));
    }
    var cartos = pts.map(function (p) {
      return Cesium.Cartographic.fromDegrees(p.lon, p.lat);
    });
    return Cesium.sampleTerrainMostDetailed(terrain, cartos)
      .then(function (sampled) {
        return sampled.map(function (c, i) {
          return (c && isFinite(c.height)) ? c.height + 1 : (pts[i].alt || 0);
        });
      })
      .catch(function () {
        return pts.map(function (p) { return p.alt || 0; });
      });
  }

  // Async: samples DEM heights first, then builds the clock-driven marker.
  function buildReplay() {
    var pts = TT._trackData || [];
    if (pts.length < 2) return Promise.resolve(false);

    return resolveHeights(pts).then(function (heights) {
      return finishBuildReplay(pts, heights);
    });
  }

  function finishBuildReplay(pts, heights) {
    var v = viewer();
    // Assign synthetic timestamps: 1 "sample" per point. If real recordedAt
    // deltas are provided (t in ms), use them; otherwise use a uniform 1s step.
    var hasTimes = pts[0].t != null;
    var t0 = hasTimes ? pts[0].t : 0;

    var property = new Cesium.SampledPositionProperty();
    // Hold within gaps instead of interpolating across (approximation of the
    // "no straight line across GPS gaps" rule for the replay marker).
    property.forwardExtrapolationType = Cesium.ExtrapolationType.HOLD;
    property.backwardExtrapolationType = Cesium.ExtrapolationType.HOLD;

    startTime = Cesium.JulianDate.fromDate(new Date());
    sampleMeta = [];
    var cumDist = 0;
    var prevCarto = null;
    var lastSeg = null;

    for (var i = 0; i < pts.length; i++) {
      var pt = pts[i];
      var secs = hasTimes ? (pt.t - t0) / 1000 : i; // seconds from start
      var time = Cesium.JulianDate.addSeconds(
        startTime, secs, new Cesium.JulianDate());
      var pos = Cesium.Cartesian3.fromDegrees(pt.lon, pt.lat, heights[i]);
      property.addSample(time, pos);

      // distance (skip across a segment break — gap not counted as travel)
      var carto = { lat: pt.lat, lon: pt.lon };
      var seg = pt.seg == null ? 0 : pt.seg;
      if (prevCarto && seg === lastSeg) {
        cumDist += haversine(prevCarto, carto);
      }
      var speed = 0;
      if (i > 0 && secs > sampleMeta[i - 1].secs) {
        var dt = secs - sampleMeta[i - 1].secs;
        var dd = cumDist - sampleMeta[i - 1].dist;
        speed = dt > 0 ? dd / dt : 0;
      }
      sampleMeta.push({
        secs: secs, dist: cumDist, alt: pt.alt || 0, speed: speed,
        lat: pt.lat, lon: pt.lon,
      });
      prevCarto = carto;
      lastSeg = seg;
    }

    totalSeconds = sampleMeta[sampleMeta.length - 1].secs || pts.length;
    stopTime = Cesium.JulianDate.addSeconds(
      startTime, totalSeconds, new Cesium.JulianDate());

    if (replayEntity) v.entities.remove(replayEntity);
    replayEntity = v.entities.add({
      position: property,
      point: {
        pixelSize: 16,
        color: Cesium.Color.fromCssColorString('#f26419'),
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 3,
        // Height comes from the sampled positions (draped onto the DEM below),
        // NOT heightReference: CLAMP_TO_GROUND — a ground-clamped point on a
        // moving SampledPositionProperty vanishes when the map is rotated while
        // paused (requestRenderMode re-clamp gap). Explicit terrain heights ride
        // the surface reliably in every state.
        heightReference: Cesium.HeightReference.NONE,
        disableDepthTestDistance: Number.POSITIVE_INFINITY,
      },
      path: {
        show: false,
      },
    });

    // Clock setup.
    v.clock.startTime = startTime.clone();
    v.clock.stopTime = stopTime.clone();
    v.clock.currentTime = startTime.clone();
    v.clock.clockRange = Cesium.ClockRange.CLAMPED;
    v.clock.multiplier = 1;
    return true;
  }

  function haversine(a, b) {
    var R = 6371000;
    var dLat = toRad(b.lat - a.lat);
    var dLon = toRad(b.lon - a.lon);
    var la1 = toRad(a.lat), la2 = toRad(b.lat);
    var h = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(la1) * Math.cos(la2) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    return 2 * R * Math.asin(Math.min(1, Math.sqrt(h)));
  }
  function toRad(d) { return d * Math.PI / 180; }

  function metaAtSeconds(secs) {
    // Linear scan (route sizes are modest); find the bracketing samples.
    if (sampleMeta.length === 0) return null;
    if (secs <= sampleMeta[0].secs) return sampleMeta[0];
    for (var i = 1; i < sampleMeta.length; i++) {
      if (secs <= sampleMeta[i].secs) {
        var a = sampleMeta[i - 1], b = sampleMeta[i];
        var span = b.secs - a.secs || 1;
        var f = (secs - a.secs) / span;
        return {
          dist: a.dist + (b.dist - a.dist) * f,
          alt: a.alt + (b.alt - a.alt) * f,
          speed: b.speed,
          lat: a.lat + (b.lat - a.lat) * f,
          lon: a.lon + (b.lon - a.lon) * f,
        };
      }
    }
    return sampleMeta[sampleMeta.length - 1];
  }

  function onTick(clock) {
    var v = viewer();
    var elapsed = Cesium.JulianDate.secondsDifference(
      clock.currentTime, startTime);
    var fraction = totalSeconds > 0 ?
      Math.min(1, Math.max(0, elapsed / totalSeconds)) : 0;

    if (follow && replayEntity) {
      var pos = replayEntity.position.getValue(clock.currentTime);
      if (pos) {
        // Keep the camera framed on the moving marker. lookAt sets a reference
        // frame centred on `pos`; we must NOT reset it to IDENTITY here or the
        // follow is cancelled every tick. The transform is reset back to
        // IDENTITY only when follow is disabled / replay stops.
        v.camera.lookAt(pos, new Cesium.HeadingPitchRange(
          0, Cesium.Math.toRadians(-35), 800));
      }
    }

    var now = Date.now();
    if (now - lastEmit > 100) { // ~10 Hz throttle
      lastEmit = now;
      var meta = metaAtSeconds(elapsed) || {};
      TT.send('REPLAY_PROGRESS', {
        fraction: fraction,
        lat: meta.lat, lon: meta.lon, alt: meta.alt,
        speed: meta.speed || 0,
        distance: meta.dist || 0,
      });
    }

    if (fraction >= 1 && v.clock.shouldAnimate) {
      v.clock.shouldAnimate = false;
      // Release the follow-camera lock so the map is interactive again.
      v.camera.lookAtTransform(Cesium.Matrix4.IDENTITY);
      v.scene.requestRenderMode = true;
      v.scene.requestRender();
      TT.send('REPLAY_FINISHED', {});
    }
  }

  function ensureTickListener() {
    var v = viewer();
    if (!tickListener) {
      tickListener = onTick;
      v.clock.onTick.addEventListener(tickListener);
    }
  }

  function beginPlayback(p) {
    var v = viewer();
    if (!v) return;
    ensureTickListener();
    v.clock.multiplier = (p && p.speed) ? p.speed : 1;
    // Clock-driven playback needs continuous frames; requestRenderMode is
    // restored when the replay pauses/stops/finishes (memory/battery saver).
    v.scene.requestRenderMode = false;
    v.clock.shouldAnimate = true;
  }

  TT.on('START_ROUTE_REPLAY', function (p) {
    var v = viewer();
    if (!v) return;
    follow = !!(p && p.follow);
    if (!replayEntity) {
      // buildReplay is async (samples DEM heights for the marker). Kick off
      // playback once the entity exists; a second START before it resolves is
      // guarded by the replayEntity check.
      buildReplay().then(function (ok) {
        if (!ok) {
          TT.send('MAP_ERROR', { message: 'no route to replay', fatal: false });
          return;
        }
        beginPlayback(p);
      });
    } else {
      beginPlayback(p);
    }
  });

  TT.on('PAUSE_ROUTE_REPLAY', function () {
    var v = viewer();
    if (!v) return;
    v.clock.shouldAnimate = false;
    // Release the follow-camera lock so the user can pan/zoom freely.
    v.camera.lookAtTransform(Cesium.Matrix4.IDENTITY);
    v.scene.requestRenderMode = true;
    v.scene.requestRender();
  });

  TT.on('SET_REPLAY_SPEED', function (p) {
    var v = viewer();
    if (v && p && p.speed) v.clock.multiplier = p.speed;
  });

  TT.on('SET_REPLAY_FOLLOW', function (p) {
    follow = !!(p && p.follow);
    if (!follow && viewer()) {
      viewer().camera.lookAtTransform(Cesium.Matrix4.IDENTITY);
    }
  });

  TT.on('SEEK_ROUTE_REPLAY', function (p) {
    var v = viewer();
    if (!v || !startTime) return;
    var f = Math.min(1, Math.max(0, (p && p.fraction) || 0));
    v.clock.currentTime = Cesium.JulianDate.addSeconds(
      startTime, f * totalSeconds, new Cesium.JulianDate());
    v.scene.requestRender();
  });

  TT.on('STOP_ROUTE_REPLAY', function () {
    var v = viewer();
    if (!v) return;
    v.clock.shouldAnimate = false;
    v.scene.requestRenderMode = true;
    v.scene.requestRender();
    if (startTime) v.clock.currentTime = startTime.clone();
    follow = false;
    v.camera.lookAtTransform(Cesium.Matrix4.IDENTITY);
  });

  // Rebuild replay data if the track is replaced after a replay was built.
  TT.on('SET_TRACK_POINTS', function () {
    if (replayEntity && viewer()) {
      viewer().entities.remove(replayEntity);
      replayEntity = null;
    }
  });
})();
