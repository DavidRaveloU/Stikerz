import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/sticker_preview_sheet.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'sticker_preview_sheet',
    subdirectory: 'pack_detail',
    builder: (_) => StickerPreviewSheet(
      webpPath: 'C:/does/not/exist.webp',
      onDelete: () {},
      previewContent: Container(
        color: const Color(0xFF111114),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_rounded,
          color: Color(0xFF8E8E93),
          size: 36,
        ),
      ),
    ),
  );
}
