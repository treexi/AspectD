#!/bin/bash
# Apply AOP patch to Flutter 3.35.7 flutter_tools
# Usage: ./apply_patch.sh [FLUTTER_ROOT]
# Default: uses fvm or `which flutter` to locate SDK

set -e

if [ -n "$1" ]; then
  FLUTTER_ROOT="$1"
else
  # Try fvm first
  if command -v fvm &>/dev/null; then
    FLUTTER_ROOT=$(fvm flutter --version 2>/dev/null | grep -oP '(?<=Framework.*revision ).*' || true)
    FLUTTER_ROOT=$(dirname $(dirname $(fvm which flutter 2>/dev/null || echo ""))) 2>/dev/null || true
  fi
  if [ -z "$FLUTTER_ROOT" ] || [ ! -d "$FLUTTER_ROOT/packages/flutter_tools" ]; then
    FLUTTER_ROOT=$(dirname $(dirname $(which flutter 2>/dev/null || echo "")))
  fi
  if [ -z "$FLUTTER_ROOT" ] || [ ! -d "$FLUTTER_ROOT/packages/flutter_tools" ]; then
    echo "Error: Cannot locate Flutter SDK. Pass FLUTTER_ROOT as argument."
    echo "Usage: $0 /path/to/flutter/sdk"
    exit 1
  fi
fi

TOOLS_DIR="$FLUTTER_ROOT/packages/flutter_tools/lib/src"

if [ ! -d "$TOOLS_DIR" ]; then
  echo "Error: flutter_tools not found at $TOOLS_DIR"
  exit 1
fi

echo "Patching Flutter SDK at: $FLUTTER_ROOT"
echo "Flutter tools dir: $TOOLS_DIR"

# 1. Create aop directory and aspectd.dart
AOP_DIR="$TOOLS_DIR/aop"
mkdir -p "$AOP_DIR"

if [ -f "$AOP_DIR/aspectd.dart" ]; then
  echo "[skip] aspectd.dart already exists"
else
  cat > "$AOP_DIR/aspectd.dart" << 'DART_EOF'
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';
import 'package:package_config/package_config.dart';

import '../artifacts.dart';
import '../base/common.dart';
import '../base/file_system.dart';
import '../dart/package_map.dart';
import '../globals.dart' as globals;

const String frontendServerDartSnapshot = 'frontend_server_aot.dart.snapshot';
const String sYamlConfigName = 'aop_config.yaml';
const String key_flutter_tools_hook = 'flutter_tools_hook';
const String key_project_name = 'project_name';
const String key_exec_path = 'exec_path';
const String beike_aspectd = 'beike_aspectd';
const String inner_path = 'inner';
const String globalPackagesPath = '.dart_tool/package_config.json';

class AspectdHook {
  static Future<Directory?> getPackagePathFromConfig(
      String packageConfigPath, String packageName) async {
    final PackageConfig packageConfig = await loadPackageConfigWithLogging(
      globals.fs.file(packageConfigPath),
      logger: globals.logger,
    );
    if (packageConfig.packages.isNotEmpty) {
      final Iterable<Package> matches = packageConfig.packages.where(
          (Package element) => element.name == packageName);
      if (matches.isEmpty) {
        return null;
      }
      return globals.fs.directory(matches.first.root.toFilePath());
    }
    return null;
  }

  static Future<Directory?> getFlutterFrontendServerDirectory(
      String packagesPath) async {
    final Directory? directory =
        await getPackagePathFromConfig(packagesPath, beike_aspectd);

    if (directory == null) {
      return null;
    }

    return globals.fs.directory(globals.fs.path
        .join(directory.absolute.path, inner_path, 'flutter_frontend_server'));
  }

  static bool configFileExists() {
    final String configYamlPath =
        globals.fs.path.join(globals.fs.currentDirectory.path, sYamlConfigName);

    if (globals.fs.file(configYamlPath).existsSync()) {
      final dynamic yamlInfo =
          loadYaml(globals.fs.file(configYamlPath).readAsStringSync());

      if (yamlInfo == null) {
        return false;
      }

      if (yamlInfo[key_flutter_tools_hook] is! YamlList) {
        return false;
      }

      final YamlList yamlNodes = yamlInfo[key_flutter_tools_hook] as YamlList;

      if (yamlNodes.nodes.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  static Future<void> enableAspectd() async {
    final Directory currentDirectory = globals.fs.currentDirectory;

    final String packagesPath = globals.fs.path
        .join(currentDirectory.absolute.path, globalPackagesPath);

    if (!globals.fs.file(packagesPath).existsSync()) {
      return;
    }

    final Directory? flutterFrontendServerDirectory =
        await getFlutterFrontendServerDirectory(packagesPath);

    if (flutterFrontendServerDirectory == null) {
      return;
    }

    await checkAspectdFlutterFrontendServerSnapshot(
        flutterFrontendServerDirectory);
  }

  static Future<void> checkAspectdFlutterFrontendServerSnapshot(
      Directory flutterFrontendServerDirectory) async {
    final String aspectdFlutterFrontendServerSnapshot = globals.fs.path.join(
        flutterFrontendServerDirectory.absolute.path,
        frontendServerDartSnapshot);
    final String? defaultFlutterFrontendServerSnapshot = globals.artifacts
        ?.getArtifactPath(Artifact.frontendServerSnapshotForEngineDartSdk);
    final File defaultServerFile =
        globals.fs.file(defaultFlutterFrontendServerSnapshot);
    final File aspectdServerFile =
        globals.fs.file(aspectdFlutterFrontendServerSnapshot);

    if (!aspectdServerFile.existsSync()) {
      return;
    }

    if (defaultServerFile.existsSync()) {
      if (md5.convert(defaultServerFile.readAsBytesSync()) ==
          md5.convert(aspectdServerFile.readAsBytesSync())) {
        return;
      }

      globals.fs.file(defaultFlutterFrontendServerSnapshot).deleteSync();
    }

    aspectdServerFile.copySync(defaultFlutterFrontendServerSnapshot!);

    print('[aop]: New frontend server snapshot updated');
  }
}
DART_EOF
  echo "[done] Created aspectd.dart"
fi

# 2-4. Use python3 for reliable patching of Dart source files
export TOOLS_DIR
python3 << 'PYEOF'
import sys, re, os

tools_dir = os.environ.get("TOOLS_DIR", "")
if not tools_dir:
    print("Error: TOOLS_DIR not set")
    sys.exit(1)

# --- Patch compile.dart ---
compile_file = os.path.join(tools_dir, "compile.dart")
with open(compile_file, "r") as f:
    content = f.read()

if "aop/aspectd.dart" not in content:
    # Add import
    content = content.replace(
        "import 'convert.dart';",
        "import 'convert.dart';\nimport 'aop/aspectd.dart';",
        1
    )

    # Add --aop flag in KernelCompiler.compile command list
    # before '--verbosity=error' in the first command list (has mainUri)
    content = content.replace(
        "if (nativeAssets != null) ...<String>['--native-assets', nativeAssets],\n          // See: https://github.com/flutter/flutter/issues/103994\n          '--verbosity=error',\n          ...?extraFrontEndOptions,\n          if (mainUri != null) mainUri else '--native-assets-only',",
        "if (nativeAssets != null) ...<String>['--native-assets', nativeAssets],\n          if (AspectdHook.configFileExists()) ...<String>[\n            '--aop',\n            '1',\n          ],\n          // See: https://github.com/flutter/flutter/issues/103994\n          '--verbosity=error',\n          ...?extraFrontEndOptions,\n          if (mainUri != null) mainUri else '--native-assets-only',",
        1
    )

    # Add --aop flag in DefaultResidentCompiler command list
    # before '--verbosity=error' in the second command list (has unsafePackageSerialization)
    content = content.replace(
        "if (unsafePackageSerialization) '--unsafe-package-serialization',\n          // See: https://github.com/flutter/flutter/issues/103994\n          '--verbosity=error',\n          ...?extraFrontEndOptions,\n        ];",
        "if (unsafePackageSerialization) '--unsafe-package-serialization',\n          if (AspectdHook.configFileExists()) ...<String>[\n            '--aop',\n            '1',\n          ],\n          // See: https://github.com/flutter/flutter/issues/103994\n          '--verbosity=error',\n          ...?extraFrontEndOptions,\n        ];",
        1
    )

    with open(compile_file, "w") as f:
        f.write(content)
    print("[done] Patched compile.dart")
else:
    print("[skip] compile.dart already patched")

# --- Patch common.dart ---
common_file = os.path.join(tools_dir, "build_system", "targets", "common.dart")
with open(common_file, "r") as f:
    content = f.read()

if "aop/aspectd.dart" not in content:
    # Add import
    content = content.replace(
        "import 'native_assets.dart';",
        "import 'native_assets.dart';\nimport '../../aop/aspectd.dart';",
        1
    )

    # Add AspectdHook.enableAspectd() at start of KernelSnapshot.build
    pattern = r'(class KernelSnapshot extends Target \{.*?@override\s*\n\s*Future<void> build\(Environment environment\) async \{)'
    match = re.search(pattern, content, re.DOTALL)
    if match:
        insert_pos = match.end()
        content = content[:insert_pos] + "\n    await AspectdHook.enableAspectd();" + content[insert_pos:]

    with open(common_file, "w") as f:
        f.write(content)
    print("[done] Patched common.dart")
else:
    print("[skip] common.dart already patched")

# --- Patch build_bundle.dart ---
bundle_file = os.path.join(tools_dir, "commands", "build_bundle.dart")
with open(bundle_file, "r") as f:
    content = f.read()

if "aop/aspectd.dart" not in content:
    # Add import
    content = content.replace(
        "import 'build.dart';",
        "import 'build.dart';\nimport '../aop/aspectd.dart';",
        1
    )

    # Add AspectdHook.enableAspectd() at start of runCommand
    content = content.replace(
        "Future<FlutterCommandResult> runCommand() async {",
        "Future<FlutterCommandResult> runCommand() async {\n    await AspectdHook.enableAspectd();\n",
        1
    )

    with open(bundle_file, "w") as f:
        f.write(content)
    print("[done] Patched build_bundle.dart")
else:
    print("[skip] build_bundle.dart already patched")
PYEOF

echo ""
echo "=== Patch applied successfully! ==="
echo "Run 'flutter pub get' in your project to rebuild flutter_tools."
echo ""
