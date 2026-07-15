/// Backup format models (spec §13). Kept pure/serializable so backup creation
/// and restore can be unit-tested without Drive or the filesystem.
library;

/// Full backup includes photo files; light backup includes photo metadata only.
enum BackupType {
  full('full'),
  light('light');

  const BackupType(this.wire);
  final String wire;

  static BackupType fromWire(String w) =>
      w == 'light' ? BackupType.light : BackupType.full;

  bool get includesPhotos => this == BackupType.full;
}

/// The `manifest.json` at the root of every backup ZIP.
class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.activityCount,
    required this.trackPointCount,
    required this.photoCount,
    required this.includesPhotos,
  });

  /// Bump when the backup layout changes incompatibly.
  static const currentFormatVersion = 1;

  final int formatVersion;
  final String appVersion;
  final DateTime createdAt;
  final int activityCount;
  final int trackPointCount;
  final int photoCount;
  final bool includesPhotos;

  Map<String, dynamic> toJson() => {
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'activityCount': activityCount,
    'trackPointCount': trackPointCount,
    'photoCount': photoCount,
    'includesPhotos': includesPhotos,
  };

  factory BackupManifest.fromJson(Map<String, dynamic> j) => BackupManifest(
    formatVersion: (j['formatVersion'] as num).toInt(),
    appVersion: j['appVersion']?.toString() ?? 'unknown',
    createdAt:
        DateTime.tryParse(j['createdAt']?.toString() ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    activityCount: (j['activityCount'] as num?)?.toInt() ?? 0,
    trackPointCount: (j['trackPointCount'] as num?)?.toInt() ?? 0,
    photoCount: (j['photoCount'] as num?)?.toInt() ?? 0,
    includesPhotos: j['includesPhotos'] == true,
  );

  /// Whether this app can restore the backup's format version.
  bool get isSupported => formatVersion <= currentFormatVersion;

  BackupType get type => includesPhotos ? BackupType.full : BackupType.light;
}

/// A backup file listed from Drive (or a fake).
class DriveBackupFile {
  const DriveBackupFile({
    required this.fileId,
    required this.name,
    required this.sizeBytes,
    required this.createdAt,
  });

  final String fileId;
  final String name;
  final int sizeBytes;
  final DateTime createdAt;
}

/// How to apply a restore (spec §13).
enum RestoreMode {
  /// Keep local data; add only activityIds not present locally (default).
  merge,

  /// Replace all local data with the backup (requires confirmation).
  replace,
}
