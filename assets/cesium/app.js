/**
 * app.js — TrailTrack Cesium bridge core.
 *
 * Owns the JSON message transport between Flutter and CesiumJS (see
 * docs/CESIUM_BRIDGE.md). Renderer modules (map-controller, photo-markers,
 * route-player) register typed handlers here; this file routes inbound
 * messages and sends outbound ones.
 *
 * CesiumJS is a stateless renderer — no track data is persisted here.
 */
(function () {
  'use strict';

  /** @type {Object.<string, Array<function(object):void>>} */
  var handlers = {};

  /**
   * Register a handler for an inbound message type (Flutter → JS). Multiple
   * modules may register for the same type (e.g. both map-controller and
   * route-player handle SET_TRACK_POINTS) — all registered handlers run.
   */
  function on(type, fn) {
    (handlers[type] || (handlers[type] = [])).push(fn);
  }

  /** Route an inbound message to all handlers for its type. Unknown = ignored. */
  function receive(message) {
    try {
      var msg = typeof message === 'string' ? JSON.parse(message) : message;
      var list = handlers[msg && msg.type];
      if (list && list.length) {
        var payload = msg.payload || {};
        for (var i = 0; i < list.length; i++) {
          try {
            list[i](payload);
          } catch (e) {
            log('error', 'handler for ' + msg.type + ' failed: ' + (e && e.message));
          }
        }
      } else {
        log('warn', 'Unhandled message type: ' + (msg && msg.type));
      }
    } catch (e) {
      log('error', 'receive() failed: ' + (e && e.message));
    }
  }

  /** Send a message to Flutter (JS → Flutter). */
  function send(type, payload) {
    var msg = { type: type, payload: payload || {} };
    try {
      if (window.flutter_inappwebview &&
          window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('trailTrackBridge', msg);
      } else {
        // Running in a plain browser (dev/preview) — echo to console.
        // eslint-disable-next-line no-console
        console.log('[bridge→flutter]', JSON.stringify(msg));
      }
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error('send() failed', e);
    }
  }

  /** Diagnostic log passthrough (also surfaced to Flutter in release). */
  function log(level, message) {
    // eslint-disable-next-line no-console
    (console[level] || console.log)('[TrailTrack] ' + message);
    send('LOG', { level: level, message: message });
  }

  /** Show/hide the load and error overlays. */
  function setLoading(visible) {
    var el = document.getElementById('loading');
    if (el) el.classList.toggle('hidden', !visible);
  }

  function showError(message) {
    var el = document.getElementById('error');
    var txt = document.getElementById('error-text');
    if (txt && message) txt.textContent = message;
    if (el) el.classList.remove('hidden');
    setLoading(false);
  }

  /**
   * boot() is called from index.html after all modules load. Modules have
   * already registered their handlers by this point. We simply signal that the
   * bridge is wired; the actual viewer is created on INITIALIZE_MAP.
   */
  function boot() {
    // Expose the inbound entry point for Flutter's evaluateJavascript.
    window.TrailTrack.receive = receive;
    log('info', 'bridge booted');
    // Let Flutter know the page/script layer is ready to receive INITIALIZE_MAP.
    send('BRIDGE_READY', {});
  }

  // Public namespace. Renderer modules attach to this.
  window.TrailTrack = {
    on: on,
    send: send,
    receive: receive, // replaced (same fn) in boot for clarity
    log: log,
    boot: boot,
    setLoading: setLoading,
    showError: showError,
    // Populated by map-controller.js once the viewer exists.
    viewer: null,
  };
})();
