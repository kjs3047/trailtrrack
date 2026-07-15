/**
 * photo-markers.js — renders photo markers with a per-location count badge.
 *
 * Handles SET_PHOTO_MARKERS. Markers carry `ttPhotoId` so the pick handler in
 * map-controller.js can emit PHOTO_MARKER_SELECTED.
 *
 * Clustering: Cesium's built-in EntityCluster groups nearby markers and shows
 * an aggregate count, which satisfies the "가까운 사진 마커 클러스터링" +
 * "사진 개수 배지" requirement (spec §9) without a custom clusterer.
 */
(function () {
  'use strict';

  var TT = window.TrailTrack;
  var photoDataSource = null;

  function ensureDataSource() {
    var viewer = TT.viewer;
    if (!viewer) return null;
    if (!photoDataSource) {
      photoDataSource = new Cesium.CustomDataSource('trailtrack-photos');
      viewer.dataSources.add(photoDataSource);

      var cluster = photoDataSource.clustering;
      cluster.enabled = true;
      cluster.pixelRange = 45;
      cluster.minimumClusterSize = 2;
      cluster.clusterEvent.addEventListener(function (entities, clusterObj) {
        // The pin image already carries the count badge — showing the default
        // cluster label too printed the number twice (once under the icon).
        clusterObj.label.show = false;
        clusterObj.billboard.show = true;
        clusterObj.billboard.image = pinImage(entities.length);
        clusterObj.billboard.verticalOrigin = Cesium.VerticalOrigin.BOTTOM;
      });
    }
    return photoDataSource;
  }

  // Draw a simple safety-orange rounded pin with an optional count into a canvas
  // and return a data URL (no external image assets needed — fully offline).
  function pinImage(count) {
    var size = 48;
    var canvas = document.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    var ctx = canvas.getContext('2d');
    ctx.fillStyle = '#f26419';
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(size / 2, size / 2 - 4, 15, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
    var cx = size / 2;
    var cy = size / 2 - 4;
    if (count && count > 1) {
      // Show the co-located photo count as a badge (spec §9).
      ctx.fillStyle = '#ffffff';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.font = '700 16px sans-serif';
      ctx.fillText(String(count), cx, cy);
    } else {
      // Simple camera glyph drawn with shapes (emoji rendering on a WebView
      // canvas is unreliable), so a single photo reads as a camera icon.
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(cx - 7, cy - 3, 14, 9);        // body
      ctx.fillRect(cx - 3, cy - 6, 6, 3);          // viewfinder bump
      ctx.fillStyle = '#f26419';
      ctx.beginPath();
      ctx.arc(cx, cy + 1, 3, 0, Math.PI * 2);      // lens
      ctx.fill();
    }
    return canvas.toDataURL();
  }

  // Build one billboard marker. `height` is the absolute altitude (metres) to
  // place it at — we use a DEM-sampled ground height so the pin sits ON the
  // terrain. heightReference stays NONE (an explicit altitude, not clamped):
  //  - CLAMP_TO_GROUND billboards were the bug — with requestRenderMode they
  //    stop recomputing after the first frame, so rotating / going top-down
  //    left them buried at height 0, and in 2D (no terrain) they vanished.
  //  - An explicit height + disableDepthTestDistance renders reliably in 2D,
  //    3D, top-down and while rotating.
  function addMarker(ds, m, height) {
    var entity = ds.entities.add({
      position: Cesium.Cartesian3.fromDegrees(m.lon, m.lat, height),
      billboard: {
        image: pinImage(m.count || 1),
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        heightReference: Cesium.HeightReference.NONE,
        disableDepthTestDistance: Number.POSITIVE_INFINITY,
      },
    });
    entity.ttPhotoId = m.id;
  }

  var markerSeq = 0;

  // Repaint a requestRenderMode=true scene after the marker positions/cluster
  // change. One requestRender can land BEFORE Cesium recomputes the
  // CustomDataSource cluster (leaving stale/floating pins until the next user
  // gesture), so we also request another frame on the next tick.
  function repaint() {
    var v = TT.viewer;
    if (v && v.scene) v.scene.requestRender();
    if (TT.requestRender) TT.requestRender();
    if (typeof requestAnimationFrame === 'function') {
      requestAnimationFrame(function () {
        var vv = TT.viewer;
        if (vv && vv.scene) vv.scene.requestRender();
      });
    }
  }

  TT.on('SET_PHOTO_MARKERS', function (p) {
    var ds = ensureDataSource();
    if (!ds) return;
    ds.entities.removeAll();
    var markers = p.markers || [];
    if (markers.length === 0) { repaint(); return; }

    var seq = ++markerSeq;
    var viewer = TT.viewer;
    var terrain = viewer && viewer.terrainProvider;
    // Sample the DEM so each pin sits ON the ground. verticalOrigin is BOTTOM,
    // so the pin's base rests exactly at the sampled terrain height — no extra
    // offset (a +2 m offset left the pins visibly floating above the surface).
    var canSample = terrain &&
      typeof Cesium.sampleTerrainMostDetailed === 'function' &&
      !(terrain instanceof Cesium.EllipsoidTerrainProvider);

    // 2D / no terrain: GPS altitude is meaningless for draping — draw at 0/GPS
    // immediately (height doesn't affect the flat projection anyway).
    if (!canSample) {
      markers.forEach(function (m) { addMarker(ds, m, (m.alt || 0)); });
      repaint();
      return;
    }

    // 3D: wait for the DEM sample and draw ONCE at the ground height. We do NOT
    // draw at GPS altitude first — that made the pins appear floating until the
    // next user interaction forced a repaint ("떠 있다가 지도 조작하면 붙음").
    var cartos = markers.map(function (m) {
      return Cesium.Cartographic.fromDegrees(m.lon, m.lat);
    });
    Cesium.sampleTerrainMostDetailed(terrain, cartos)
      .then(function (sampled) {
        // A newer SET_PHOTO_MARKERS superseded this one — drop stale result.
        if (seq !== markerSeq) return;
        ds.entities.removeAll();
        markers.forEach(function (m, i) {
          var h = sampled[i] && isFinite(sampled[i].height)
            ? sampled[i].height : (m.alt || 0);
          addMarker(ds, m, h);
        });
        repaint();
      })
      .catch(function () {
        // Terrain sample failed — fall back to GPS altitude so pins still show.
        if (seq !== markerSeq) return;
        ds.entities.removeAll();
        markers.forEach(function (m) { addMarker(ds, m, (m.alt || 0)); });
        repaint();
      });
  });
})();
