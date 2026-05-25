import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_test/golden_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stikerz/ui/features/settings/presentation/pages/settings_page.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'settings_page',
    subdirectory: 'settings',
    setup: (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Stikerz',
        packageName: 'com.davidravelo.stikerz',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '1',
      );
    },
    builder: (_) => const ProviderScope(child: SettingsPage()),
  );
}
