import 'dart:typed_data';

import 'models/backup_models.dart';

/// Abstraction over the Google Drive operations the backup feature needs
/// (spec §13). A real implementation wraps the Drive v3 API; [FakeDriveClient]
/// (in test) provides an in-memory version so backup/restore is testable
/// without network or OAuth (spec §16).
abstract class DriveClient {
  /// Whether the user is currently signed in with Drive access.
  Future<bool> isSignedIn();

  /// Trigger interactive sign-in + Drive authorization. Returns true on success.
  Future<bool> signIn();

  /// Human-readable reason the last [signIn] failed (null on success). Lets the
  /// UI explain setup issues (e.g. OAuth client not configured) instead of a
  /// generic message.
  String? get lastError;

  /// Email of the signed-in Google account, or null when signed out. Shown in
  /// settings next to the 로그인/로그아웃 action.
  String? get accountEmail;

  Future<void> signOut();

  /// Upload a backup ZIP (given as a byte stream + total size for resumable
  /// upload). Returns the created Drive file id. [onProgress] reports 0..1.
  Future<String> uploadBackup({
    required String fileName,
    required Stream<List<int>> data,
    required int totalBytes,
    void Function(double progress)? onProgress,
  });

  /// List the app-created backup files, newest first.
  Future<List<DriveBackupFile>> listBackups();

  /// Download a backup file's bytes by id.
  Future<Uint8List> downloadBackup(String fileId);

  /// Delete a backup file by id (only after explicit user confirmation).
  Future<void> deleteBackup(String fileId);
}
