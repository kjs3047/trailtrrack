import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'settings_repository.dart';

/// Settings screen (spec §13: backup retention count + default type are here).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _retention = SettingsRepository.defaultRetentionCount;
  String _defaultType = 'full';
  double _bodyWeightKg = SettingsRepository.defaultBodyWeightKg;
  bool _loaded = false;

  /// Signed-in Google account email (null = signed out). Loaded async so the
  /// screen doesn't block on the silent sign-in check.
  String? _googleEmail;
  bool _driveBusy = false;

  SettingsRepository get _repo =>
      SettingsRepository(ref.read(databaseProvider));

  @override
  void initState() {
    super.initState();
    _load();
    _loadGoogleAccount();
  }

  Future<void> _loadGoogleAccount() async {
    final drive = ref.read(driveClientProvider);
    final signedIn = await drive.isSignedIn();
    if (!mounted) return;
    setState(() => _googleEmail = signedIn ? drive.accountEmail : null);
  }

  Future<void> _load() async {
    final retention = await _repo.getBackupRetentionCount();
    final type = await _repo.getDefaultBackupType();
    final weight = await _repo.getBodyWeightKg();
    if (!mounted) return;
    setState(() {
      _retention = retention;
      _defaultType = type;
      _bodyWeightKg = weight;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spaceSm),
              children: [
                Text('프로필', style: AppTypography.labelCaps),
                ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: const Text('몸무게'),
                  subtitle: const Text('칼로리 계산에 사용됩니다'),
                  trailing: Text(
                    '${_bodyWeightKg.toStringAsFixed(_bodyWeightKg % 1 == 0 ? 0 : 1)} kg',
                    style: AppTypography.labelCaps,
                  ),
                  onTap: _editBodyWeight,
                ),
                const Divider(),
                Text('백업', style: AppTypography.labelCaps),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('백업 보관 개수'),
                  subtitle: Text('$_retention개까지 보관'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _retention > 1
                            ? () => _setRetention(_retention - 1)
                            : null,
                      ),
                      Text('$_retention'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _retention < 50
                            ? () => _setRetention(_retention + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('기본 백업 유형'),
                  subtitle: Text(_defaultType == 'full' ? '전체 백업' : '경량 백업'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'full', label: Text('전체')),
                      ButtonSegment(value: 'light', label: Text('경량')),
                    ],
                    selected: {_defaultType},
                    onSelectionChanged: (s) => _setDefaultType(s.first),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Google 계정'),
                  subtitle: Text(_googleEmail ?? '로그인되지 않음'),
                  trailing: TextButton(
                    onPressed: _driveBusy
                        ? null
                        : (_googleEmail == null
                              ? _googleSignIn
                              : _googleSignOut),
                    child: Text(_googleEmail == null ? '로그인' : '로그아웃'),
                  ),
                ),
                const Divider(),
                Text('지도', style: AppTypography.labelCaps),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: const Text('Cesium ion 토큰'),
                  subtitle: Text(
                    AppConfig.hasCesiumIonToken ? '설정됨' : '미설정 (.env 참고)',
                  ),
                ),
                const Divider(),
                const AboutListTile(
                  icon: Icon(Icons.info_outline),
                  applicationName: 'TrailTrack',
                  applicationVersion: '1.0.0 (MVP)',
                ),
              ],
            ),
    );
  }

  Future<void> _setRetention(int value) async {
    setState(() => _retention = value);
    await _repo.setBackupRetentionCount(value);
  }

  Future<void> _setDefaultType(String type) async {
    setState(() => _defaultType = type);
    await _repo.setDefaultBackupType(type);
  }

  Future<void> _googleSignIn() async {
    setState(() => _driveBusy = true);
    final drive = ref.read(driveClientProvider);
    final ok = await drive.signIn();
    if (!mounted) return;
    setState(() {
      _driveBusy = false;
      _googleEmail = ok ? drive.accountEmail : null;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(drive.lastError ?? 'Google 로그인에 실패했습니다'),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _googleSignOut() async {
    setState(() => _driveBusy = true);
    await ref.read(driveClientProvider).signOut();
    if (!mounted) return;
    setState(() {
      _driveBusy = false;
      _googleEmail = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google 계정에서 로그아웃했습니다')));
  }

  Future<void> _editBodyWeight() async {
    final controller = TextEditingController(
      text: _bodyWeightKg.toStringAsFixed(_bodyWeightKg % 1 == 0 ? 0 : 1),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('몸무게 입력'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            suffixText: 'kg',
            hintText: '예: 65',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, double.tryParse(v)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(controller.text)),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (result == null) return;
    // Clamp to a sane human range so a typo can't wreck the estimate.
    final kg = result.clamp(20.0, 300.0);
    setState(() => _bodyWeightKg = kg);
    await _repo.setBodyWeightKg(kg);
  }
}
