import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_repository.dart';
import 'backup_service.dart';
import 'drive_client.dart';
import 'models/backup_models.dart';

/// Orchestrates the Google Drive save/load user flows (spec §13). Kept out of
/// the dashboard widget so the multi-step flow (type pick → estimate →
/// build → upload → retention prompt) is readable in one place.
class BackupFlow {
  BackupFlow(this.ref);

  final WidgetRef ref;

  DriveClient get _drive => ref.read(driveClientProvider);
  BackupService get _backup => ref.read(backupServiceProvider);

  /// Raw error from the last failed build/upload, surfaced to the user —
  /// swallowing it made failures undiagnosable (spec §8: no silent failures).
  String? _lastUploadError;

  /// Full "저장" flow. Returns true if a backup was uploaded.
  Future<bool> runSave(BuildContext context) async {
    // 1) Ensure sign-in.
    if (!await _ensureSignedIn(context)) return false;

    // 2) Pick backup type (default: full — spec §13).
    if (!context.mounted) return false;
    final settings = SettingsRepository(ref.read(databaseProvider));
    final defaultType = BackupType.fromWire(
      await settings.getDefaultBackupType(),
    );
    if (!context.mounted) return false;
    final type = await _pickBackupType(context, defaultType);
    if (type == null) return false;

    // 3) Show estimate (photo count + approx size).
    final est = await _backup.estimate(type);
    if (!context.mounted) return false;
    final proceed = await _confirmEstimate(context, type, est);
    if (proceed != true) return false;
    if (!context.mounted) return false;

    // 4) Build + upload with a progress dialog.
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _buildAndUpload(context, type);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_describeUploadError()),
          duration: const Duration(seconds: 10),
        ),
      );
      return false;
    }

    // 5) Retention check — never auto-delete (spec §13).
    if (context.mounted) await _handleRetention(context, settings);
    messenger.showSnackBar(
      const SnackBar(content: Text('Google Drive 백업이 완료되었습니다')),
    );
    return true;
  }

  /// Full "불러오기" flow. Returns true if a restore ran.
  Future<bool> runLoad(BuildContext context) async {
    if (!await _ensureSignedIn(context)) return false;
    if (!context.mounted) return false;

    // Fetch the backup list behind a spinner (network round-trip).
    final List<DriveBackupFile> backups;
    try {
      backups = await _withProgress(
        context,
        '백업 목록을 불러오는 중…',
        _drive.listBackups,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('백업 목록을 불러오지 못했습니다: $e')),
        );
      }
      return false;
    }
    if (!context.mounted) return false;
    if (backups.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('복원할 백업이 없습니다')));
      return false;
    }

    final selected = await _pickBackup(context, backups);
    if (selected == null) return false;

    // Download to a temp file, behind a spinner while fetching.
    final tmpDir = await getTemporaryDirectory();
    final zipPath = p.join(tmpDir.path, 'restore_${selected.fileId}.zip');
    if (!context.mounted) return false;
    try {
      await _withProgress(context, '백업을 내려받는 중…', () async {
        final bytes = await _drive.downloadBackup(selected.fileId);
        await File(zipPath).writeAsBytes(bytes);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('백업 다운로드 실패: $e')));
      }
      return false;
    }

    // Verify manifest / format version.
    final BackupManifest manifest;
    try {
      manifest = _backup.readManifest(zipPath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('백업 형식 오류: $e')));
      }
      return false;
    }
    if (!manifest.isSupported) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지원하지 않는 백업 버전 (${manifest.formatVersion})')),
        );
      }
      return false;
    }

    if (!context.mounted) return false;
    final mode = await _pickRestoreMode(context, manifest);
    if (mode == null) return false;

    if (mode == RestoreMode.replace) {
      if (!context.mounted) return false;
      final confirmed = await _confirmReplace(context);
      if (confirmed != true) return false;
    }

    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docs.path, 'photos'));
    if (!context.mounted) return false;
    try {
      final result = await _withProgress(
        context,
        '복원하는 중…',
        () => _backup.restoreBackup(
          zipPath: zipPath,
          mode: mode,
          photosDir: photosDir,
        ),
      );

      // Refresh the activities view.
      ref.invalidate(activitiesStreamProvider);

      if (context.mounted) {
        final missing = result.missingPhotoFiles > 0
            ? ' (원본 사진 ${result.missingPhotoFiles}개 없음)'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '복원 완료: 추가 ${result.addedActivities}, '
              '건너뜀 ${result.skippedActivities}$missing',
            ),
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('복원 실패: $e')));
      }
      return false;
    }
  }

  // --- steps -----------------------------------------------------------

  Future<bool> _ensureSignedIn(BuildContext context) async {
    if (await _drive.isSignedIn()) return true;
    final ok = await _drive.signIn();
    if (!ok && context.mounted) {
      final reason = _drive.lastError ?? 'Google 로그인이 필요합니다';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reason), duration: const Duration(seconds: 6)),
      );
    }
    return ok;
  }

  /// Run [task] behind a modal spinner dialog (backup list / download /
  /// restore). The dialog closes in all cases; errors propagate to the caller.
  Future<T> _withProgress<T>(
    BuildContext context,
    String message,
    Future<T> Function() task,
  ) async {
    if (context.mounted) {
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _ProgressDialog(message: message),
        ),
      );
    }
    try {
      return await task();
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<bool> _buildAndUpload(BuildContext context, BackupType type) async {
    final tmpDir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final zipPath = p.join(tmpDir.path, 'workout-backup-$stamp.zip');
    final workDir = Directory(p.join(tmpDir.path, 'backup_work_$stamp'));

    // Progress dialog.
    if (context.mounted) {
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _ProgressDialog(message: '백업을 만드는 중…'),
        ),
      );
    }

    try {
      _lastUploadError = null;
      await _backup.createBackup(
        type: type,
        outputZipPath: zipPath,
        workDir: workDir,
      );
      final zipFile = File(zipPath);
      final fileName = 'workout-backup-$stamp.zip';
      await _drive.uploadBackup(
        fileName: fileName,
        data: zipFile.openRead(),
        totalBytes: zipFile.lengthSync(),
      );
      return true;
    } catch (e, st) {
      _lastUploadError = e.toString();
      debugPrint('[backup] upload failed: $e\n$st');
      return false;
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      // Best-effort cleanup.
      final f = File(zipPath);
      if (f.existsSync()) f.deleteSync();
      if (workDir.existsSync()) workDir.deleteSync(recursive: true);
    }
  }

  Future<void> _handleRetention(
    BuildContext context,
    SettingsRepository settings,
  ) async {
    final keep = await settings.getBackupRetentionCount();
    final backups = await _drive.listBackups();
    final over = BackupService.backupsOverRetention(backups, keep);
    if (over.isEmpty || !context.mounted) return;

    final delete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오래된 백업 정리'),
        content: Text(
          '보관 개수($keep)를 초과한 백업 ${over.length}개가 있습니다. 삭제할까요?\n\n'
          '${over.map((b) => "· ${b.name} (${_fmtSize(b.sizeBytes)})").join('\n')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('유지'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (delete == true) {
      for (final b in over) {
        await _drive.deleteBackup(b.fileId);
      }
    }
  }

  // --- dialogs ---------------------------------------------------------

  Future<BackupType?> _pickBackupType(
    BuildContext context,
    BackupType initial,
  ) {
    return showDialog<BackupType>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('백업 유형 선택'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, BackupType.full),
            child: const ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('전체 백업'),
              subtitle: Text('기록·경로·통계·원본 사진·썸네일 포함'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, BackupType.light),
            child: const ListTile(
              leading: Icon(Icons.description_outlined),
              title: Text('경량 백업'),
              subtitle: Text('사진 파일 제외 (메타데이터만)'),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmEstimate(
    BuildContext context,
    BackupType type,
    ({int photoCount, int estimatedBytes}) est,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == BackupType.full ? '전체 백업' : '경량 백업'),
        content: Text(
          '포함 사진: ${est.photoCount}장\n'
          '예상 용량: ${_fmtSize(est.estimatedBytes)}\n\n'
          'Google Drive에 업로드할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('백업'),
          ),
        ],
      ),
    );
  }

  Future<DriveBackupFile?> _pickBackup(
    BuildContext context,
    List<DriveBackupFile> backups,
  ) {
    return showModalBottomSheet<DriveBackupFile>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                child: Text(
                  '복원할 백업 선택',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'Google Drive에 백업 ${backups.length}개',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: backups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _BackupTile(
                    backup: backups[i],
                    isLatest: i == 0,
                    onTap: () => Navigator.pop(ctx, backups[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<RestoreMode?> _pickRestoreMode(
    BuildContext context,
    BackupManifest manifest,
  ) {
    return showModalBottomSheet<RestoreMode>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
              child: Text(
                '복원 방식 선택',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                '운동 ${manifest.activityCount}개 · 사진 ${manifest.photoCount}장'
                '${manifest.includesPhotos ? "" : " (사진 파일 없음)"}',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _RestoreModeCard(
                    icon: Icons.library_add_outlined,
                    iconColor: AppColors.primary,
                    title: '없는 운동만 추가',
                    subtitle: '기존 로컬 데이터는 그대로 두고, 백업에만 있는 운동을 추가합니다',
                    badge: '권장',
                    onTap: () => Navigator.pop(ctx, RestoreMode.merge),
                  ),
                  const SizedBox(height: 8),
                  _RestoreModeCard(
                    icon: Icons.restore,
                    iconColor: AppColors.error,
                    title: '전체 교체',
                    subtitle: '로컬 데이터를 모두 지우고 백업 내용으로 대체합니다',
                    onTap: () => Navigator.pop(ctx, RestoreMode.replace),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmReplace(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('전체 교체 확인'),
        content: const Text('현재 로컬 데이터가 모두 삭제되고 백업으로 대체됩니다. 계속할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('교체'),
          ),
        ],
      ),
    );
  }

  /// Friendly message for the last upload failure, with the raw error attached
  /// so the exact cause is always visible/diagnosable.
  String _describeUploadError() {
    final raw = _lastUploadError ?? '';
    String hint = '';
    if (raw.contains('accessNotConfigured') ||
        raw.contains('Access Not Configured') ||
        raw.contains('has not been used in project')) {
      hint =
          'Google Cloud Console에서 "Google Drive API"를 사용 설정해야 합니다 '
          '(API 및 서비스 → 라이브러리 → Google Drive API → 사용).\n';
    } else if (raw.contains('SocketException') ||
        raw.contains('Failed host lookup')) {
      hint = '네트워크 연결을 확인해 주세요.\n';
    } else if (raw.contains('insufficient') || raw.contains('403')) {
      hint = '권한 문제일 수 있습니다. 설정에서 로그아웃 후 다시 로그인해 보세요.\n';
    }
    final trimmed = raw.length > 300 ? '${raw.substring(0, 300)}…' : raw;
    final detail = trimmed.isEmpty ? '' : '\n[$trimmed]';
    return '백업 업로드 실패. 로컬 데이터는 유지됩니다.\n$hint$detail';
  }

  static String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  /// Local-time date label (Drive returns UTC — convert or it's off by 9h in
  /// KST). Year is shown only when it differs from the current year.
  static String _fmtDate(DateTime d) {
    final l = d.toLocal();
    final year = l.year == DateTime.now().year ? '' : '${l.year}년 ';
    return '$year${l.month}월 ${l.day}일 '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// Relative label like "3시간 전" for the backup list.
  static String _relative(DateTime d) {
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 30) return '${diff.inDays}일 전';
    return '${diff.inDays ~/ 30}개월 전';
  }
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    // canPop false: a system-back during an operation would dismiss the dialog
    // and make the flow's cleanup pop() close the screen below it instead.
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

/// One backup entry in the restore picker: date-first title, relative time +
/// size subtitle, "최신" badge on the newest.
class _BackupTile extends StatelessWidget {
  const _BackupTile({
    required this.backup,
    required this.isLatest,
    required this.onTap,
  });

  final DriveBackupFile backup;
  final bool isLatest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(
                  Icons.cloud_done_outlined,
                  color: AppColors.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            BackupFlow._fmtDate(backup.createdAt),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (isLatest) const _Badge('최신'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${BackupFlow._relative(backup.createdAt)} · '
                      '${BackupFlow._fmtSize(backup.sizeBytes)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One restore-mode option card (merge / replace).
class _RestoreModeCard extends StatelessWidget {
  const _RestoreModeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (badge != null) _Badge(badge!),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded label ("최신", "권장").
class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onPrimaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
