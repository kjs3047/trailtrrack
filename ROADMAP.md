# ROADMAP

Milestone status for the TrailTrack MVP, plus features **explicitly deferred**
out of the MVP (spec §2). Deferred features are recorded here (and any detailed
prior sync designs under `docs/spec/future/`); they are **not** implemented in
MVP code.

## Milestones

| # | Milestone | Status |
|---|-----------|--------|
| M0 | Project skeleton (Flutter, Riverpod, go_router, Drift, theme, dirs, README) | ✅ done |
| M1 | CesiumJS PoC (local asset, WebView bridge, World Terrain, 2D/3D, test route, DEM) | ✅ done (agent-verified; on-device check pending) |
| M2 | GPS + local recording (permissions, foreground service, states, Drift store, stats, screen-off) | ✅ done |
| M3 | Dashboard + detail (list, aggregate stats, charts, detail map, elevation chart) | ✅ done |
| M4 | Photos + 3D replay (camera, GPS link, markers, count, gallery, replay) | ✅ done |
| M5 | Google Drive backup/restore (sign-in, full/light backup, ZIP, retention, upload, list, restore, fake-Drive tests) | ✅ done |
| M6 | Stabilization (error handling, permission denial, GPS/network loss, crash recovery, streaming backup, perf, docs) | ✅ done |

All agent-verifiable checks pass (format, analyze, tests, debug + release APK
builds). Device-only behaviours (real GPS, screen-off recording, camera, real
Google Drive, Cesium visual quality) still require the on-device checklist in
`TEST_PLAN.md` — the agent cannot verify those.

> **Note on the M1 gate:** the original plan paused after M1 for on-device
> approval before M2. The user's directive ("파일을 읽고 끝까지 구현해" — read the
> files and implement to completion) took precedence, so M2–M6 were implemented
> without pausing. The on-device Cesium verification is still recommended and is
> captured in `TEST_PLAN.md`.

## Deferred to post-MVP (spec §2)

These are intentionally **out of scope** for the MVP and must not be built into
MVP code:

### Sync & backup (beyond full backup/restore)
- Multi-device real-time sync
- Incremental / delta sync
- Google Drive Changes API
- Remote file catalog reconstruction
- Field-level conflict-resolution UI
- Tombstone-based deletion propagation
- Automatic background sync
- WorkManager periodic sync
- Resumable-upload session recovery after app restart

Detailed prior designs for the above (incremental sync, tombstones, conflict
merge, appDataFolder) are preserved as reference specs under
`docs/spec/future/` — not deleted, not implemented.

### Product scope
- Sharing records between users
- Self-hosted backend server
- iOS
- Smartwatch
- Heart-rate sensor
- Health Connect
- Fully offline map tiles
- End-to-end backup encryption
- GPX / KML export
- 24-hour automated performance validation

## Improvement ideas surfaced during implementation

(Per spec §20: MVP-exceeding improvements are recorded here, not coded.)

- _None yet._
