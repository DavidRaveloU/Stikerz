import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_model.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/components/pack_card.dart';

import '../golden_test_config.dart';

StickerPackModel _buildPack() {
  final pack = StickerPackModel()
    ..id = 101
    ..name = 'Travel Pack'
    ..author = 'David'
    ..coverImagePath = 'C:/does/not/exist-cover.webp';

  pack.stickers = [
    StickerModel(slotIndex: 0, webpPath: 'C:/does/not/exist-1.webp'),
    StickerModel(slotIndex: 1, webpPath: 'C:/does/not/exist-2.webp'),
    StickerModel(slotIndex: 2, webpPath: 'C:/does/not/exist-3.webp'),
  ];

  return pack;
}

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'pack_card',
    subdirectory: 'home',
    builder: (_) => PackCard(
      pack: _buildPack(),
      onTap: () {},
      onDelete: () {},
      coverPreview: Container(
        color: Colors.blueGrey,
        child: const Center(
          child: Icon(Icons.photo_library_rounded, color: Colors.white54),
        ),
      ),
    ),
  );
}
