import 'dart:typed_data';

import 'drive_client.dart';
import 'models/backup_models.dart';

/// In-memory [DriveClient] for tests and offline development (spec §16). Stores
/// uploaded backup bytes in a map so the full backup → upload → download →
/// restore round trip can run without network or OAuth.
class FakeDriveClient implements DriveClient {
  FakeDriveClient({bool signedIn = true}) : _signedIn = signedIn;

  bool _signedIn;
  int _seq = 0;
  final Map<String, _FakeFile> _files = {};

  /// Injectable clock so `createdAt` is deterministic in tests.
  DateTime Function() now = () => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String? lastError;

  @override
  String? get accountEmail => _signedIn ? 'fake@example.com' : null;

  @override
  Future<bool> isSignedIn() async => _signedIn;

  @override
  Future<bool> signIn() async {
    _signedIn = true;
    return true;
  }

  @override
  Future<void> signOut() async => _signedIn = false;

  @override
  Future<String> uploadBackup({
    required String fileName,
    required Stream<List<int>> data,
    required int totalBytes,
    void Function(double progress)? onProgress,
  }) async {
    final builder = BytesBuilder();
    var received = 0;
    await for (final chunk in data) {
      builder.add(chunk);
      received += chunk.length;
      onProgress?.call(totalBytes == 0 ? 1 : received / totalBytes);
    }
    final id = 'fake_${_seq++}';
    _files[id] = _FakeFile(
      id: id,
      name: fileName,
      bytes: builder.toBytes(),
      createdAt: now(),
    );
    return id;
  }

  @override
  Future<List<DriveBackupFile>> listBackups() async {
    final list =
        _files.values
            .map(
              (f) => DriveBackupFile(
                fileId: f.id,
                name: f.name,
                sizeBytes: f.bytes.length,
                createdAt: f.createdAt,
              ),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Uint8List> downloadBackup(String fileId) async {
    final file = _files[fileId];
    if (file == null) throw StateError('No such backup: $fileId');
    return file.bytes;
  }

  @override
  Future<void> deleteBackup(String fileId) async {
    _files.remove(fileId);
  }

  int get storedCount => _files.length;
}

class _FakeFile {
  _FakeFile({
    required this.id,
    required this.name,
    required this.bytes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final Uint8List bytes;
  final DateTime createdAt;
}
