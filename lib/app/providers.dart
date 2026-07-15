import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3.x moved ChangeNotifierProvider to the legacy surface.
import 'package:flutter_riverpod/legacy.dart';

import '../core/config/app_config.dart';
import '../core/database/app_database.dart';
import '../core/location/location_service.dart';
import '../core/permissions/permission_service.dart';
import '../features/backup/backup_service.dart';
import '../features/backup/drive_client.dart';
import '../features/backup/fake_drive_client.dart';
import '../features/backup/google_drive_client.dart';
import '../features/photos/data/photo_repository.dart';
import '../features/photos/gallery_exporter.dart';
import '../features/photos/photo_capture_service.dart';
import '../features/recording/data/activity_repository.dart';
import '../features/recording/recording_controller.dart';
import '../features/settings/settings_repository.dart';

/// App-wide Riverpod providers (spec §4: keep wiring simple).

/// The single Drift database instance for the app's lifetime.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(ref.watch(databaseProvider));
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(ref.watch(databaseProvider));
});

final photoCaptureServiceProvider = Provider<PhotoCaptureService>((ref) {
  return PhotoCaptureService(
    repository: ref.watch(photoRepositoryProvider),
    gallery: const GalleryExporter(),
  );
});

/// Live photo stream for an activity (drives markers + gallery).
final activityPhotosProvider =
    StreamProvider.family<List<ActivityPhotoRow>, String>((ref, id) {
      return ref.watch(photoRepositoryProvider).watchPhotos(id);
    });

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(service.dispose);
  return service;
});

/// The live recording controller (a ChangeNotifier). One per app session.
final recordingControllerProvider = ChangeNotifierProvider<RecordingController>(
  (ref) {
    final controller = RecordingController(
      locationService: ref.watch(locationServiceProvider),
      repository: ref.watch(activityRepositoryProvider),
      settingsRepository: SettingsRepository(ref.watch(databaseProvider)),
    );
    ref.onDispose(controller.dispose);
    return controller;
  },
);

/// Stream of all activities, newest first (drives dashboard + history).
final activitiesStreamProvider = StreamProvider((ref) {
  return ref.watch(activityRepositoryProvider).watchActivities();
});

/// One-shot check for an interrupted recording to offer recovery (spec §14).
final recoverableActivityProvider = FutureProvider((ref) async {
  final rows = await ref
      .watch(activityRepositoryProvider)
      .getRecoverableActivities();
  return rows.isEmpty ? null : rows.first;
});

/// Loads a single activity plus its track points and photos for the detail
/// screen (spec §10.4). Keyed by activity id.
final activityDetailProvider =
    FutureProvider.family<ActivityDetailData?, String>((ref, id) async {
      final repo = ref.watch(activityRepositoryProvider);
      final row = await repo.getActivity(id);
      if (row == null) return null;
      final pointRows = await repo.getTrackPoints(id);
      final points = pointRows.map(repo.rowToPoint).toList();
      final photos = await repo.getPhotos(id);
      return ActivityDetailData(activity: row, points: points, photos: photos);
    });

/// The Drive client. Uses the real Google Drive client when Drive is enabled;
/// otherwise a FakeDriveClient so the backup UI works offline / without OAuth
/// (spec §20). Override this in tests with a FakeDriveClient.
final driveClientProvider = Provider<DriveClient>((ref) {
  if (AppConfig.googleDriveEnabled) {
    // Pass the Web OAuth client id as serverClientId (required on Android by
    // google_sign_in 7.x). If unset, the client surfaces a setup message
    // instead of crashing.
    return GoogleDriveClient(
      serverClientId: AppConfig.hasGoogleServerClientId
          ? AppConfig.googleServerClientId
          : null,
    );
  }
  return FakeDriveClient(signedIn: false);
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    db: ref.watch(databaseProvider),
    repository: ref.watch(activityRepositoryProvider),
  );
});
