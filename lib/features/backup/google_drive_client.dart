import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'drive_client.dart';
import 'models/backup_models.dart';

/// Real Google Drive backup client (spec §13). Uses the `drive.file` scope, so
/// the app only sees files it created. Signs in via google_sign_in 7.x and
/// authorizes the Drive scope, then talks to Drive v3.
///
/// Note: initialize() must be called once (with the Android OAuth client set up
/// via the Google Cloud console — see GOOGLE_DRIVE_BACKUP.md). This client is
/// exercised end-to-end only on a real device; the FakeDriveClient covers the
/// backup/restore logic in tests.
class GoogleDriveClient implements DriveClient {
  GoogleDriveClient({this.serverClientId});

  /// Optional server (web) client id for cross-platform token exchange.
  final String? serverClientId;

  static const _scope = 'https://www.googleapis.com/auth/drive.file';
  static const _appFolderName = 'WorkoutTracker';
  static const _backupsFolderName = 'backups';

  final GoogleSignIn _signIn = GoogleSignIn.instance;
  bool _initialized = false;
  GoogleSignInAccount? _account;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _signIn.initialize(serverClientId: serverClientId);
    _initialized = true;
  }

  /// Message when the OAuth Web client id (serverClientId) isn't configured.
  static const _notConfiguredMsg =
      'Google Drive가 아직 설정되지 않았습니다.\n'
      'Google Cloud Console에서 OAuth 클라이언트(Android + Web)를 만들고 '
      'GOOGLE_DRIVE_SERVER_CLIENT_ID를 .env에 넣어야 합니다 '
      '(GOOGLE_DRIVE_BACKUP.md 참고).';

  bool get _configured =>
      serverClientId != null && serverClientId!.trim().isNotEmpty;

  @override
  Future<bool> isSignedIn() async {
    lastError = null;
    if (!_configured) {
      lastError = _notConfiguredMsg;
      return false;
    }
    await _ensureInitialized();
    if (_account != null) return true;
    // Try a silent, non-interactive sign-in. This THROWS on Android when the
    // OAuth client isn't configured (serverClientId missing) — catch it so the
    // backup flow can fall through to signIn() / show a helpful message rather
    // than crashing with an unhandled exception.
    try {
      final future = _signIn.attemptLightweightAuthentication();
      final account = future == null ? null : await future;
      _account = account;
      return account != null;
    } on GoogleSignInException catch (e) {
      lastError = _describeError(e);
      return false;
    } catch (e) {
      lastError = 'Google 로그인 확인 오류: $e';
      return false;
    }
  }

  String _describeError(GoogleSignInException e) {
    if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
      return _notConfiguredMsg;
    }
    return 'Google 로그인 실패: ${e.code.name}'
        '${e.description != null ? " (${e.description})" : ""}';
  }

  /// The last sign-in failure reason, for surfacing to the user (spec §8: no
  /// silent failures). Null when the last attempt succeeded.
  @override
  String? lastError;

  @override
  String? get accountEmail => _account?.email;

  @override
  Future<bool> signIn() async {
    lastError = null;
    if (!_configured) {
      lastError = _notConfiguredMsg;
      return false;
    }
    await _ensureInitialized();
    try {
      if (!_signIn.supportsAuthenticate()) {
        lastError = '이 기기에서 Google 로그인을 지원하지 않습니다';
        return false;
      }
      _account = await _signIn.authenticate(scopeHint: const [_scope]);
      // Authorize the Drive scope up front so uploads have a token.
      await _account!.authorizationClient.authorizeScopes(const [_scope]);
      return true;
    } on GoogleSignInException catch (e) {
      lastError = _describeError(e);
      return false;
    } catch (e) {
      lastError = 'Google 로그인 오류: $e';
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await _signIn.signOut();
    _account = null;
  }

  Future<drive.DriveApi> _api() async {
    final account = _account;
    if (account == null) {
      throw StateError('Not signed in — call signIn() first');
    }
    final authz = await account.authorizationClient.authorizeScopes(const [
      _scope,
    ]);
    final client = authz.authClient(scopes: const [_scope]);
    return drive.DriveApi(client);
  }

  /// Ensure `WorkoutTracker/backups` exists, returning the backups folder id.
  Future<String> _ensureBackupsFolder(drive.DriveApi api) async {
    final rootId = await _ensureFolder(api, _appFolderName, null);
    return _ensureFolder(api, _backupsFolderName, rootId);
  }

  Future<String> _ensureFolder(
    drive.DriveApi api,
    String name,
    String? parentId,
  ) async {
    final q = [
      "mimeType='application/vnd.google-apps.folder'",
      "name='$name'",
      'trashed=false',
      if (parentId != null) "'$parentId' in parents",
    ].join(' and ');
    final existing = await api.files.list(q: q, $fields: 'files(id,name)');
    if (existing.files != null && existing.files!.isNotEmpty) {
      return existing.files!.first.id!;
    }
    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = parentId != null ? [parentId] : null;
    final created = await api.files.create(folder, $fields: 'id');
    return created.id!;
  }

  @override
  Future<String> uploadBackup({
    required String fileName,
    required Stream<List<int>> data,
    required int totalBytes,
    void Function(double progress)? onProgress,
  }) async {
    final api = await _api();
    final folderId = await _ensureBackupsFolder(api);

    final media = drive.Media(data, totalBytes);
    final file = drive.File()
      ..name = fileName
      ..parents = [folderId];

    // googleapis uses a resumable upload automatically for large media.
    final created = await api.files.create(
      file,
      uploadMedia: media,
      $fields: 'id',
    );
    onProgress?.call(1);
    return created.id!;
  }

  @override
  Future<List<DriveBackupFile>> listBackups() async {
    final api = await _api();
    final folderId = await _ensureBackupsFolder(api);
    final result = await api.files.list(
      q: "'$folderId' in parents and trashed=false",
      orderBy: 'createdTime desc',
      $fields: 'files(id,name,size,createdTime)',
    );
    final files = result.files ?? [];
    return [
      for (final f in files)
        DriveBackupFile(
          fileId: f.id!,
          name: f.name ?? 'backup',
          sizeBytes: int.tryParse(f.size ?? '0') ?? 0,
          createdAt: f.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
    ];
  }

  @override
  Future<Uint8List> downloadBackup(String fileId) async {
    final api = await _api();
    final media =
        await api.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final builder = BytesBuilder();
    await for (final chunk in media.stream) {
      builder.add(chunk);
    }
    return builder.toBytes();
  }

  @override
  Future<void> deleteBackup(String fileId) async {
    final api = await _api();
    await api.files.delete(fileId);
  }
}
