import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/image_editor/presentation/pages/image_editor_page.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'image_editor_square_crop',
    subdirectory: 'image_editor',
    builder: (_) => const MaterialApp(
      home: ImageEditorPage(packId: 1, slotIndex: 0, imagePath: ''),
    ),
  );
}
