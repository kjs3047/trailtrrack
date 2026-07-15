# DATABASE

Local persistence uses **Drift + SQLite**. This document is the schema
reference. The schema is implemented in `lib/core/database/` at **M2**; this
file defines the target design agreed for the MVP (spec §12).

> **Status:** design fixed; implementation lands in M2. No sync-engine tables
> are created (spec §12).

## Tables

Only these tables exist (spec §12):

- `activities`
- `track_points`
- `activity_photos`
- `app_settings`
- `backup_history`

### activities

Summary row per workout.

| Column | Type | Notes |
|--------|------|-------|
| id | TEXT PK | UUID |
| title | TEXT | |
| activity_type | TEXT | `walk`/`run`/`hike`/`trail_run`/`cycle` |
| status | TEXT | idle/recording/paused/finishing/completed/recoveryRequired |
| started_at | INTEGER | epoch ms |
| ended_at | INTEGER? | |
| elapsed_seconds | INTEGER | wall clock start→end |
| active_seconds | INTEGER | excludes paused time |
| total_distance_meters | REAL | accepted points only |
| average_speed | REAL | m/s |
| max_speed | REAL | m/s |
| minimum_altitude | REAL | display altitude |
| maximum_altitude | REAL | |
| elevation_gain | REAL | noise-filtered |
| elevation_loss | REAL | noise-filtered |
| memo | TEXT? | |
| representative_photo_id | TEXT? | FK → activity_photos.id (nullable) |
| created_at | INTEGER | |
| updated_at | INTEGER | |

### track_points

One row per GPS sample. FK `activity_id` → `activities.id` (ON DELETE CASCADE).

| Column | Type | Notes |
|--------|------|-------|
| id | TEXT PK | UUID |
| activity_id | TEXT FK | |
| sequence | INTEGER | per-activity monotonic |
| latitude | REAL | |
| longitude | REAL | |
| gps_altitude | REAL? | raw GPS altitude — never overwritten (spec §8) |
| dem_altitude | REAL? | filled by post-hoc DEM batch lookup |
| speed | REAL? | m/s |
| heading | REAL? | degrees |
| accuracy | REAL? | m |
| recorded_at | INTEGER | epoch ms |
| segment_index | INTEGER | increments across GPS dropouts (spec §6) |
| is_accepted | INTEGER | 0/1 — validity filter result; stats use accepted only |

Index: `(activity_id, sequence)`.

### activity_photos

FK `activity_id` → `activities.id` (ON DELETE CASCADE).

| Column | Type | Notes |
|--------|------|-------|
| id | TEXT PK | UUID |
| activity_id | TEXT FK | |
| local_path | TEXT | original |
| thumbnail_path | TEXT | |
| latitude | REAL? | nearest valid GPS fix at capture time |
| longitude | REAL? | |
| gps_altitude | REAL? | |
| dem_altitude | REAL? | |
| taken_at | INTEGER | epoch ms |
| elapsed_seconds | INTEGER | into the activity |
| distance_meters | REAL | cumulative at capture |
| caption | TEXT? | |

Index: `(activity_id)`.

### app_settings

Key/value store (backup retention count, default backup type, last Drive
account, etc.).

### backup_history

One row per successful backup: timestamp, Drive fileId, type (full/light),
size, activity/photo counts.

## Integrity & migrations

- Foreign keys enabled (`PRAGMA foreign_keys = ON`).
- All multi-row writes (recording finalize, restore) run inside a transaction
  (spec §12).
- Drift schema versioning + `MigrationStrategy` from v1; migrations are additive.

## Recovery snapshot (spec §14)

During recording, a lightweight snapshot (activityId, status, last sequence,
started_at, cumulative distance, last position) is written periodically so an
unfinished activity can be recovered after a crash. Stored on the `activities`
row (status = `recoveryRequired` when detected at startup).
