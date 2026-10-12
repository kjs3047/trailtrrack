# CESIUM_BRIDGE.md — Flutter ↔ CesiumJS message contract

TrailTrack renders all maps with CesiumJS inside a `flutter_inappwebview`
WebView. Flutter owns all GPS/state; CesiumJS is a **stateless renderer** — it
never persists track data (spec §5, §6).

Communication is a **JSON message bridge** in both directions.

## Transport

- **Flutter → JS:** Flutter calls `window.TrailTrack.receive(<json>)` via
  `InAppWebViewController.evaluateJavascript`. A single JS entry point routes on
  `message.type`.
- **JS → Flutter:** JS calls `window.flutter_inappwebview.callHandler('trailTrackBridge', <json>)`.
  Flutter registers one handler named `trailTrackBridge`.

Every message is an object: `{ "type": "<TYPE>", "payload": { ... } }`.
`payload` is optional. Unknown types are ignored (forward compatible).

Batching: track points are sent in batches (`SET_TRACK_POINTS` /
`APPEND_TRACK_POINTS`), never one message per point (spec §5).

## Flutter → CesiumJS

| Type | Payload | Effect |
|------|---------|--------|
| `INITIALIZE_MAP` | `{ ionToken?, sceneMode, imagery, terrain }` | Boot the viewer. `sceneMode`=`"2D"`\|`"3D"`. `imagery`=`"base"`\|`"satellite"`. `terrain`=bool (DEM on/off). Replies `MAP_READY` or `MAP_ERROR`. |
| `SET_SCENE_MODE` | `{ mode }` | `"2D"`\|`"3D"` morph. |
| `SET_IMAGERY` | `{ imagery }` | `"base"`\|`"satellite"`. |
| `SET_TERRAIN` | `{ enabled }` | Toggle DEM terrain provider. |
| `SET_CURRENT_LOCATION` | `{ lat, lon, alt?, accuracy?, heading?, follow? }` | Place/update the "current position" marker; `follow:true` recenters. |
| `SET_TRACK_POINTS` | `{ points:[{lat,lon,alt?,seg?}], fit? }` | Replace the whole route. `seg` = segment index; a change in `seg` breaks the polyline (no interpolation across GPS gaps, spec §6/§11). `fit:true` flies to bounds. |
| `APPEND_TRACK_POINTS` | `{ points:[...] }` | Append to the live route (recording). |
| `SET_PHOTO_MARKERS` | `{ markers:[{id,lat,lon,count,thumb?}] }` | Replace photo markers; `count` renders a badge. |
| `CLEAR` | – | Remove route, markers, current location. |
| `FLY_TO_ROUTE` | `{ durationSec? }` | Fit camera to the full route bounds. |
| `FLY_TO_LOCATION` | `{ lat, lon, alt?, durationSec? }` | Fly to a point. |
| `SET_NORTH_UP` | – | Reset heading to north. |
| `ZOOM` | `{ direction }` | `"in"`\|`"out"`. |
| `START_ROUTE_REPLAY` | `{ speed?, follow? }` | Begin time-dynamic replay of the loaded route. |
| `PAUSE_ROUTE_REPLAY` | – | Pause the clock. |
| `SEEK_ROUTE_REPLAY` | `{ fraction }` | Seek to `0.0..1.0` of the route timeline. |
| `SET_REPLAY_SPEED` | `{ speed }` | Clock multiplier; the replay UI sends `10`\|`50`\|`100`. |
| `SET_REPLAY_FOLLOW` | `{ follow }` | Camera follow on/off. |
| `STOP_ROUTE_REPLAY` | – | Stop and reset to the start. |
| `LOOKUP_DEM` | `{ requestId, points:[{lat,lon}] }` | Batch sample terrain heights; replies `DEM_RESULT`. |

## CesiumJS → Flutter

| Type | Payload | Meaning |
|------|---------|---------|
| `MAP_READY` | `{ terrain }` | Viewer initialised; `terrain`=whether DEM actually loaded. |
| `MAP_ERROR` | `{ message, fatal }` | Init or runtime error. Non-fatal errors keep GPS recording alive (spec §14). |
| `PHOTO_MARKER_SELECTED` | `{ id }` | User tapped a photo marker. |
| `TRACK_POINT_SELECTED` | `{ index, lat, lon }` | User tapped the route. |
| `REPLAY_PROGRESS` | `{ fraction, index, lat, lon, alt, speed, distance }` | Emitted while replaying (throttled ~10 Hz). |
| `REPLAY_FINISHED` | – | Replay reached the end. |
| `DEM_RESULT` | `{ requestId, heights:[{lat,lon,height}\|null] }` | Result of `LOOKUP_DEM`. `null` for a failed sample. |
| `LOG` | `{ level, message }` | Diagnostic passthrough for debugging in release builds. |

## Coordinate & altitude conventions

- `lat`/`lon` are WGS84 degrees. `alt` is metres.
- **GPS altitude and DEM/terrain height use potentially different vertical
  datums** (ellipsoid vs. geoid vs. terrain surface). TrailTrack stores both
  separately and never overwrites GPS altitude with DEM values (spec §8). The
  bridge passes whichever the caller specifies; it performs no datum conversion.

## Error / offline behaviour

- If `ionToken` is missing/invalid, terrain falls back to the ellipsoid and
  imagery falls back to a bundled offline layer where possible; the viewer still
  initialises and emits `MAP_READY { terrain:false }` (spec §14).
- A map failure must never stop GPS recording — Flutter treats `MAP_ERROR` as
  non-fatal for the recording pipeline.
