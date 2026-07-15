import '../../core/database/app_database.dart';

/// Key/value app settings backed by the `app_settings` table (spec §12).
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _keyBackupRetention = 'backup_retention_count';
  static const _keyDefaultBackupType = 'default_backup_type';
  static const _keyBodyWeightKg = 'body_weight_kg';

  /// Default number of Drive backups to keep (spec §13).
  static const defaultRetentionCount = 5;

  /// Default body weight (kg) used for the calorie estimate until the user sets
  /// their own. A neutral adult average; the estimate scales linearly with it.
  static const defaultBodyWeightKg = 65.0;

  Future<String?> _get(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<int> getBackupRetentionCount() async {
    final v = await _get(_keyBackupRetention);
    return int.tryParse(v ?? '') ?? defaultRetentionCount;
  }

  Future<void> setBackupRetentionCount(int count) =>
      _set(_keyBackupRetention, count.toString());

  /// 'full' | 'light' — default backup type (default: full).
  Future<String> getDefaultBackupType() async {
    return await _get(_keyDefaultBackupType) ?? 'full';
  }

  Future<void> setDefaultBackupType(String type) =>
      _set(_keyDefaultBackupType, type);

  /// User body weight in kg for the calorie estimate.
  Future<double> getBodyWeightKg() async {
    final v = await _get(_keyBodyWeightKg);
    final parsed = double.tryParse(v ?? '');
    return (parsed != null && parsed > 0) ? parsed : defaultBodyWeightKg;
  }

  Future<void> setBodyWeightKg(double kg) =>
      _set(_keyBodyWeightKg, kg.toString());
}
