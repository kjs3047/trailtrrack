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
| `flutter test` | ✅ 66 tests passing |
| Debug APK build | ✅ `build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK build | ✅ `build/app/outputs/flutter-apk/app-release.apk` |

## On-device manual — M1 Cesium acceptance (do before M2)

Install both Debug and Release APKs on a real Android device and verify:

1. App launches to the dashboard; tap the 🌐 (globe) app-bar icon → "Cesium PoC".
2. **Cesium loads** — the globe/map renders (not stuck on the loading spinner).
3. **Local asset load in release** — the release APK renders the map too (this
   proves the vendored Cesium assets are bundled and load from `file://`).
4. **Terrain** — with a valid `CESIUM_ION_TOKEN` in `.env`, 3D terrain relief is
   visible; status text reads "Terrain 로드됨". Without a token it reads
   "Terrain 미로드" and shows flat offline imagery (expected).
5. **2D/3D toggle** — the `2D/3D` control morphs the scene; both render.
6. **Test route** — the Bukhansan sample polyline is drawn in safety-orange with
   start (green) / end (red) markers, and the simulated GPS-gap segment is **not**
   connected by a straight line.
7. **Camera controls** — layers/north-up/zoom/locate buttons respond.
8. **Map touch** — tapping the route shows "선택: 경로 #n …" (TRACK_POINT_SELECTED).
9. **DEM lookup** — tap "DEM 조회"; with a token it reports heights for the route
   points.
10. **Route replay** — tap "경로 재생"; the marker animates along the route.

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
- [ ] 3D replay: play/pause/restart/seek, 1/2/4/8× speed, camera-follow toggle;
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
