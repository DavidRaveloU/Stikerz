import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_model.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/sticker_grid.dart';

import '../golden_test_config.dart';

StickerPackModel _buildPack() {
  final pack = StickerPackModel()
    ..id = 77
    ..name = 'Grid Pack'
    ..author = 'David'
    ..coverImagePath = '';

  pack.stickers = [
    StickerModel(slotIndex: 0, webpPath: 'C:/does/not/exist-0.webp'),
    StickerModel(slotIndex: 1, webpPath: 'C:/does/not/exist-1.webp'),
    StickerModel(slotIndex: 2, webpPath: 'C:/does/not/exist-2.webp'),
  ];

  return pack;
}

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'sticker_grid',
    subdirectory: 'pack_detail',
    builder: (_) => Scaffold(
      body: CustomScrollView(
        slivers: [
          StickerGrid(
            pack: _buildPack(),
            onSlotTap: (_) {},
            thumbOverride: Container(
              color: Colors.blueGrey,
              child: const Center(
                child: Icon(Icons.gif_box_rounded, color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
