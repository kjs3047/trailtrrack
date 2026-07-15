# ARCHITECTURE

TrailTrack is a **feature-first** Flutter app. It avoids heavy Clean-Architecture
layering (spec §4): each feature is just the screens, a controller/notifier, and
a repository where one is warranted. Shared cross-cutting services live in
`lib/core`.

```
lib/
  main.dart              # bootstrap: load .env, ProviderScope, run app
  app/
    app.dart             # MaterialApp.router + theme
    router.dart          # go_router routes
  core/
    config/              # AppConfig (.env loader: Cesium token, flags)
    theme/               # AppColors / AppTypography / AppTheme (design system)
    database/            # Drift schema & DAOs            (M2+)
    location/            # GPS collection + foreground svc (M2)
    permissions/         # staged permission requests     (M2)
    utils/               # ActivityType, GPS profiles, math helpers
  features/
    dashboard/           # main dashboard (mockup _3)
    recording/           # new-activity (_4) + live recording (_2)
    activity_detail/     # detail: route, stats, charts, replay (_1)
    map/                 # CesiumMapView + bridge (shared by all map screens)
    photos/              # camera + gallery + markers      (M4)
    backup/              # Google Drive backup/restore      (M5)
    settings/            # settings
assets/cesium/           # CesiumJS runtime + bridge JS (see below)
tool/                    # gen_cesium_assets.dart
docs/                    # CESIUM_BRIDGE.md, spec/future/*
```

## State management

Riverpod (`flutter_riverpod` 3.x) via a root `ProviderScope`. Controllers are
plain `ChangeNotifier`/Notifier objects; providers are added per feature as the
milestones land. The map layer uses an imperative `CesiumMapController`
(a `ChangeNotifier`) rather than a provider, because it wraps a WebView handle
with a request/response lifecycle.

## Responsibility boundaries (spec §4)

| Concern | Owner |
|---------|-------|
| Screens & state | `features/*/…_screen.dart` + controllers |
| GPS collection | `core/location` + Android foreground service (M2) |
| Recording & stats math | `core/utils` + recording controller (M2) |
| Local database | `core/database` (Drift) (M2) |
| Map rendering & comms | `features/map` + `assets/cesium` |
| Photo storage | `features/photos` (M4) |
| Google Drive backup/restore | `features/backup` (M5) |

## The map layer (M1, implemented)

CesiumJS runs inside a `flutter_inappwebview` WebView. The **entire Cesium
runtime is vendored** under `assets/cesium/cesium/` (see README) so the map works
offline and never depends on a CDN.

```
assets/cesium/
  index.html          # sets CESIUM_BASE_URL, loads Cesium.js + module scripts
  styles.css          # canvas + load/error overlay styling
  app.js              # bridge core: receive()/send()/handler registry
  map-controller.js   # viewer lifecycle, terrain, imagery, route, camera, DEM
  photo-markers.js    # photo markers + count badges + clustering
  route-player.js     # time-dynamic 3D route replay
  cesium/…            # vendored CesiumJS Build/Cesium (git-ignored, ~23 MB)
```

Flutter ↔ JS is a JSON message bridge; the full contract is in
`docs/CESIUM_BRIDGE.md`. Dart mirrors it in `features/map/cesium_bridge.dart`
(type constants + payload models) and `features/map/cesium_map_controller.dart`
(typed send/receive). `CesiumMapView` is the single reusable widget used by
every map screen; it hosts the WebView and the shared control overlay
(2D/3D, layers, locate, north-up, zoom).

### Key design rules honoured

- **Cesium is a stateless renderer** — GPS/track data is never persisted in JS
  (spec §5/§6). Flutter pushes points; the map only draws them.
- **GPS gaps are not bridged** — points carry a `seg` index; a segment change
  breaks the polyline and the replay marker holds rather than interpolating
  across the gap (spec §6/§11).
- **Batched track updates** — `SET_TRACK_POINTS` / `APPEND_TRACK_POINTS` send
  arrays, never one message per fix (spec §5).
- **Graceful degradation** — a missing ion token or failed terrain/imagery
  falls back to bundled offline Natural Earth II + the ellipsoid and emits a
  *non-fatal* `MAP_ERROR`; map failures never stop GPS recording (spec §14).
- **Altitude datums kept separate** — the bridge never converts between GPS and
  DEM/terrain heights; both are stored independently (spec §8).

## Configuration & secrets

`AppConfig` loads a bundled `.env` (git-ignored) for the Cesium ion token and
feature flags. No secrets are hard-coded (spec §3). The app boots even when
`.env` is absent.

## Android specifics

- `minSdk 26` (spec §3).
- Permissions: coarse/fine location, foreground-service(+location), notifications,
  camera — **no** `ACCESS_BACKGROUND_LOCATION` (spec §7). Screen-off recording is
  handled by a location foreground service (M2), which does not require it.
- AGP 8.7.3 / Gradle 8.11.1 / Kotlin 2.1.0 (see README for the AGP-9 rationale).

## Recording pipeline (M2, implemented)

GPS fixes flow: Android location foreground service isolate
(`core/location/location_foreground_task.dart`) → `LocationService` on the main
isolate → `RecordingController`, which validates each fix (`GpsValidator`, per
activity-type profile), buffers accepted+rejected points, batch-writes them to
Drift, recomputes `ActivityStats`, and streams accepted batches to the map. A
periodic recovery snapshot lets an interrupted recording be resumed on restart.
The controller depends on a `LocationSource` interface so tests inject a fake
GPS stream.

## Backup pipeline (M5, implemented)

`BackupService` builds a ZIP with a **streaming** writer: track points are paged
out of Drift and written to a gzipped temp file (never all in memory), photo
files are added via file streams, and the manifest records counts + type. The
`DriveClient` interface has a real `GoogleDriveClient` (`drive.file` scope,
resumable upload) and a `FakeDriveClient` for tests. Restore reads the archive,
verifies the manifest/format version, and applies merge (skip existing
activityIds) or replace inside a single transaction. `BackupFlow` drives the
save/load UI (type pick → estimate → build/upload → retention prompt; download →
mode pick → restore).

All milestones M0–M6 are implemented. See `ROADMAP.md` for status and
`TEST_PLAN.md` for verification.
