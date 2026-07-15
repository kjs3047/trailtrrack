import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The app's Drift database (see DATABASE.md).
///
/// Holds only the five MVP tables (spec §12): activities, track_points,
/// activity_photos, app_settings, backup_history. Foreign keys are enforced,
/// indexes cover the hot query paths, and the schema is versioned for
/// migrations.
@DriftDatabase(
  tables: [Activities, TrackPoints, ActivityPhotos, AppSettings, BackupHistory],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test constructor with an injectable executor (in-memory NativeDatabase).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Indexes on the hot paths.
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_track_points_activity_seq '
        'ON track_points (activity_id, sequence);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_photos_activity '
        'ON activity_photos (activity_id);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_activities_started '
        'ON activities (started_at);',
      );
    },
    onUpgrade: (m, from, to) async {
      // v1 → v2: add the calories column to activities (spec: calorie estimate).
      if (from < 2) {
        await m.addColumn(activities, activities.calories);
      }
    },
    beforeOpen: (details) async {
      // Enforce foreign keys on every connection (spec §12).
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'trailtrack.sqlite'));
    // Ensure sqlite3 is loadable on Android with the right temp dir.
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    return NativeDatabase.createInBackground(file);
  });
}
