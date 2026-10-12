# TEST_PLAN

Two tiers (spec §16):

1. **Agent-verifiable** — compilation, format, analyze, unit/widget/integration
   tests, APK builds.
2. **On-device manual** — things only a human with a real Android phone can
   confirm (GPS accuracy, screen-off recording, camera, real Google Drive,
   Cesium visual quality, battery, vendor background limits).

The agent must **never** report on-device checks as passed (spec §16, §20).

## Agent-verifiable (automated)

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
dart run tool/gen_cesium_assets.dart --check   # Cesium asset list in sync
flutter build apk --debug
flutter build apk --release
```

### Unit tests (target set — spec §17)

- distance & cumulative distance
- average / max speed
- active time / pause time
- GPS outlier filter (accuracy, duplicate, teleport, per-type max speed)
- elevation gain/loss with noise filter
- backup (de)serialization; full vs. light distinction
- backup retention decision
- same-activityId restore skip
- Cesium bridge message (de)serialization ✅ (`test/unit/cesium_bridge_test.dart`)

### Integration tests (target set — spec §17)

- start → mock GPS in → save route → pause → resume → stop → stats
- photo metadata save
- full backup ZIP / light backup ZIP creation
- large track-point **streaming** backup
- fake-Drive upload → local wipe → fake-Drive download → restore

All unit and integration tests above are implemented. Test files:

- `test/unit/` — geo math, GPS outlier filter, activity stats (distance,
  cumulative distance, avg/max speed, active/pause time, elevation gain/loss),
  formatters, Cesium bridge messages, chart data, dashboard summary, photo
  location matcher, thumbnail generation, backup manifest + serializer.
- `test/integration/` — activity repository (create/insert/finalize/cascade/
  recovery), recording controller (mock GPS → pause → resume → stop → stats,
  outlier handling, discard), backup round trip (create → fake-Drive upload →
  wipe → download → restore, merge skip, light backup, 5000-point streaming
  backup, replace mode, retention).
- `test/widget/` — dashboard smoke test.

## Current automated status

| Check | Result |
|-------|--------|
| `dart format` | ✅ clean |
| `flutter analyze` | ✅ no issues |
| `flutter test` | ✅ 79 tests passing |
| Debug APK build | ✅ `build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK build | ✅ `build/app/outputs/flutter-apk/app-release.apk` |

## On-device manual — Cesium map acceptance (M1)

The M1 developer PoC screen (`/cesium-poc`) is not reachable from the app UI,
so verify the same map behaviour on the real screens instead. Record one short
outdoor activity first (see **Recording (M2)** below) so a detail screen with a
route exists.

Install both Debug and Release APKs on a real Android device and verify:

1. **Cesium loads** — open the activity's detail screen; the map renders (not
   stuck on "지도를 불러오는 중…").
2. **Local asset load in release** — the release APK renders the map too (this
   proves the vendored Cesium assets are bundled and load from `file://`).
3. **Terrain** — with a valid `CESIUM_ION_TOKEN` in `.env` (Settings shows
   "Cesium ion 토큰 · 설정됨"), 3D terrain relief is visible and the route and
   markers sit on the ground surface (not floating or buried). Without a token,
   flat offline imagery is expected.
4. **2D/3D toggle** — the `2D/3D` control morphs the scene; both render.
5. **Route** — the route polyline is drawn with start (green) / end (red)
   markers. For the GPS-gap check, pause for more than 20 s, move ~100 m, then
   resume: the gap is **not** bridged by a straight line.
6. **Camera controls** — 위성/일반 지도, north-up, locate (fit route) and zoom
   buttons respond.
7. **Route replay** — see **Photos & replay (M4)** below.

Record the device model, Android version, and pass/fail per item. Report issues
(especially any release-mode asset/worker load failure) back.

## On-device manual — full MVP flow

Install the Release APK and verify the end-to-end flows (spec §16):

**Recording (M2)**
- [ ] New activity → pick a type → Start requests location + notification
      permission, then begins recording with a persistent notification.
- [ ] Walk outdoors: the route draws live on the map; time/distance/pace/speed/
      altitude/elevation-gain HUD updates.
- [ ] **Screen off**: lock the phone, keep walking, unlock — the route recorded
      while the screen was off (foreground service kept sampling).
- [ ] Pause → resume: paused time is excluded from moving time / average pace.
- [ ] Stop → routes to the detail screen with saved stats.
- [ ] Force-kill the app mid-recording, relaunch → the recovery prompt offers
      계속하기 / 저장하고 종료 / 삭제.

**Dashboard & detail (M3)**
- [ ] Dashboard shows aggregate stats, weekly bar chart, type pie chart, recent
      list.
- [ ] Detail shows the full route, stats grid, elevation & speed charts.

**Photos & replay (M4)**
- [ ] During recording, the camera button captures a photo (camera permission
      requested on first use); a marker appears on the map.
- [ ] Detail shows photo markers with a count badge; tapping opens the gallery.
- [ ] 3D replay: play/pause/restart/seek, 10/50/100× speed (default 50×), camera-follow toggle;
      the readout shows current speed/altitude/cumulative distance.

**Google Drive backup/restore (M5)**
- [ ] Drive save: pick full/light, see the photo count + size estimate, sign in,
      upload succeeds; retention prompt appears (with confirmation) when over the
      keep count.
- [ ] Drive load: pick a backup, choose merge/replace, restore succeeds;
      merge skips existing activities; replace prompts for confirmation.
- [ ] Large backup with photos uploads via resumable upload.

## Deferred long-duration tests (spec §17)

12-hour / 24-hour battery and stability runs are **manual only** and excluded
from automated completion:

- [ ] 12-hour foreground-service recording (screen off) — battery drain, dropped
      fixes, notification persistence.
- [ ] 24-hour app-alive stability.
- [ ] Vendor-specific background restrictions (Samsung/Xiaomi/etc.) with the
      foreground service.
