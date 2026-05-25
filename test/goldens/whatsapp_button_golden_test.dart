import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/whatsapp_button.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'whatsapp_button',
    subdirectory: 'pack_detail',
    builder: (_) {
      // Build a minimal pack for the button.
      final pack = testPack();
      return Material(child: WhatsAppButton(pack: pack));
    },
  );
}

StickerPackModel testPack() {
  final pack = StickerPackModel()
    ..id = 1
    ..name = 'Demo'
    ..author = 'Tester'
    ..createdAt = DateTime(2024, 1, 1)
    ..coverImagePath = '';
  pack.stickers = [];
  return pack;
}
