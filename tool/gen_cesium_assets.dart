// Regenerates the `assets/cesium/cesium/**` directory list for pubspec.yaml.
//
// Flutter's asset resolver does not recurse into subdirectories: every folder
// under the vendored Cesium runtime must be listed explicitly, or files
// (Workers/, Assets/Textures/...) silently go missing from the bundle — which
// only surfaces at runtime, and most painfully in release builds (spec M1).
//
// Usage:
//   dart run tool/gen_cesium_assets.dart          # prints the YAML block
//   dart run tool/gen_cesium_assets.dart --check   # exit 1 if pubspec is stale
//
// Paste the printed block into pubspec.yaml's `flutter: assets:` section
// (keeping the non-Cesium entries like `.env` and `assets/cesium/`).
import 'dart:io';

const cesiumRoot = 'assets/cesium/cesium';

void main(List<String> args) {
  final root = Directory(cesiumRoot);
  if (!root.existsSync()) {
    stderr.writeln(
      'Cesium runtime not found at $cesiumRoot. '
      'Vendor it first (see README "CesiumJS 런타임 vendoring").',
    );
    exit(2);
  }

  final dirs = <String>{'$cesiumRoot/'};
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is Directory) {
      final rel = entity.path.replaceAll(r'\', '/');
      if (rel.split('/').contains('.omc')) continue; // ignore tooling state
      dirs.add('$rel/');
    }
  }

  final sorted = dirs.toList()..sort();
  final block = sorted.map((d) => '    - $d').join('\n');

  if (args.contains('--check')) {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final missing = sorted.where((d) => !pubspec.contains('- $d')).toList();
    if (missing.isNotEmpty) {
      stderr.writeln(
        'pubspec.yaml is missing ${missing.length} Cesium asset '
        'dirs:\n${missing.join('\n')}',
      );
      exit(1);
    }
    stdout.writeln(
      'pubspec.yaml Cesium assets are up to date '
      '(${sorted.length} dirs).',
    );
    return;
  }

  stdout.writeln(block);
}
