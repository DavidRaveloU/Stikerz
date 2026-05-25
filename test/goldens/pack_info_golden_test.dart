import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/pack_info.dart';

import '../golden_test_config.dart';

StickerPackModel _buildPack() {
  final pack = StickerPackModel()
    ..id = 5
    ..name = 'Demo Pack'
    ..author = 'Tester'
    ..createdAt = DateTime(2024,1,1)
    ..coverImagePath = '';
  // Keep stickers empty for the golden — we only need basic metadata.
  pack.stickers = [];
  return pack;
}

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'pack_info',
    subdirectory: 'pack_detail',
    builder: (_) => Material(child: PackInfo(pack: _buildPack())),
  );
}
