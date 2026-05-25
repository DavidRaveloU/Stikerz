import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/components/settings_tile.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'settings_tile',
    subdirectory: 'settings',
    builder: (_) => Material(
      child: Column(
        children: const [
          SettingsTile(title: 'Title', subtitle: 'Subtitle', icon: Icons.info_outline),
          SettingsTile(title: 'Danger', subtitle: 'Deletes data', icon: Icons.delete, isDanger: true),
        ],
      ),
    ),
  );
}
