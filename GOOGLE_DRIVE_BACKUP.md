# GOOGLE_DRIVE_BACKUP

Google Drive is used as a **full backup/restore store**, not a live sync engine
(spec §13). This document defines the backup format and OAuth setup. The
implementation lands at **M5**; the format below is fixed now so tests and the
ZIP writer target a stable spec.

> **Status:** format fixed; implementation in M5. Multi-device sync, delta sync,
> tombstones, conflict merge and background sync are explicitly **out of scope**
> (spec §2; see `ROADMAP.md` / `docs/spec/future/`).

## OAuth

- Scope: `https://www.googleapis.com/auth/drive.file` (app-created files only).
- Sign-in via `google_sign_in`; Drive access via `googleapis` with
  `extension_google_sign_in_as_googleapis_auth`.

### Google Cloud setup (one-time)

1. Create a project in the Google Cloud Console.
2. Enable the **Google Drive API**.
3. Configure the **OAuth consent screen** (External; add your Google account
   under *Test users* while the app is in testing).
4. Create an **OAuth client ID** of type *Android*:
   - Package name: `com.trailtrack.trailtrack`
   - SHA-1 fingerprint of the signing key (see below).
5. **Also create an OAuth client ID of type *Web application*** in the SAME
   project. `google_sign_in` 7.x on Android requires this Web client's ID to be
   passed as `serverClientId`.
6. Copy the **Web** client ID into `.env`:
   ```
   GOOGLE_DRIVE_SERVER_CLIENT_ID=xxxxx.apps.googleusercontent.com
   ```
7. Rebuild the app (the `.env` is bundled as an asset).

> **Both clients are required.** Without the Web client id (`serverClientId`),
> sign-in throws `clientConfigurationError` ("serverClientId must be provided on
> Android"). The app catches this and shows a setup message on screen instead of
> crashing — so if you see that message, complete steps 4–6.

### Getting the SHA-1

The release APK is currently signed with the **debug keystore** (see
`android/app/build.gradle.kts` — `signingConfig = signingConfigs.getByName("debug")`),
so register the **debug keystore's SHA-1**:

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

On this machine the debug SHA-1 is:

```
D6:7A:CA:98:19:03:4D:4F:79:A7:5E:12:C9:71:6F:FA:4D:C1:4A:50
```

If you later add a real release signing config, register that keystore's SHA-1
too. A `google-services.json` is **not** required for `google_sign_in` with the
`drive.file` scope — only the OAuth Android client (package + SHA-1) is.

## Drive layout (user-visible)

```
WorkoutTracker/
  backups/
    workout-backup-{timestamp}.zip
```

## Backup ZIP format

```
manifest.json
activities.json.gz
track_points.json.gz       # streamed — never fully in memory (spec §13)
activity_photos.json
photos/
  originals/
  thumbnails/
```

`manifest.json`:

```json
{
  "formatVersion": 1,
  "appVersion": "1.0.0",
  "createdAt": "<ISO-8601>",
  "activityCount": 0,
  "trackPointCount": 0,
  "photoCount": 0,
  "includesPhotos": true
}
```

- `track_points.json.gz` is written and read with **streaming**
  serialization/parsing; the full point set is never held in memory at once
  (spec §13, §20).

## Backup types

- **Full backup:** activities, track points, stats, original photos + thumbnails.
- **Light backup:** activities, track points, stats, and photo *metadata* only —
  no image files. Restores mark photos as "original missing" in the UI.

Default is **full**; the estimated ZIP size and included photo count are shown
before upload.

## Save flow (spec §13)

1. Freeze local DB state → 2. choose type → 3. show est. photo count/size →
4. build package → 5. **stream** the ZIP → 6. Google sign-in + Drive check →
7. ensure `WorkoutTracker/backups` → 8. upload (resumable for large/photo
backups) → 9. record time + Drive fileId → 10. check retention → 11. **ask**
before deleting old backups → 12. show result.

- Retention default: **5** (configurable in settings). Old backups are **never**
  auto-deleted without explicit confirmation (spec §13, §20).
- Upload failure keeps local data intact and marks the backup failed; the next
  save re-uploads the whole file. Resumable-session recovery across app restarts
  is out of scope (spec §2).

## Restore flow (spec §13)

1. Sign-in + Drive check → 2. list app-created backups → 3. show date/size/
counts/photo-included → 4. pick → 5. download → 6. verify manifest/format
version → 7. show restore counts → 8. choose mode → 9. restore in a SQLite
transaction → 10. show result.

Restore modes:

- **Merge (default):** keep local data, add only activityIds not present
  locally. Existing ids are skipped, local kept.
- **Replace:** wipe local and load the backup. Requires explicit confirmation.

Light-backup restores that lack photo files restore metadata only and flag the
missing originals in the UI.
