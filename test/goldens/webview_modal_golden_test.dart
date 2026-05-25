import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/webview_modal.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'webview_modal',
    subdirectory: 'settings',
    builder: (_) => WebviewModal(
      title: 'Privacy Policy',
      url: 'https://example.com',
      contentOverride: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: const Icon(Icons.language, size: 64, color: Colors.grey),
      ),
    ),
  );
}
