import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_model.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/home/presentation/widgets/pack_list.dart';

import '../golden_test_config.dart';

StickerPackModel _buildPack({
  required int id,
  required String name,
  required String author,
  required int stickerCount,
}) {
  final pack = StickerPackModel()
    ..id = id
    ..name = name
    ..author = author
    ..coverImagePath = '';

  pack.stickers = List.generate(
    stickerCount,
    (index) => StickerModel(
      slotIndex: index,
      webpPath: 'C:/does/not/exist-$id-$index.webp',
    ),
  );

  return pack;
}

void main() {
  setupGoldenTests();

  final packs = [
    _buildPack(id: 1, name: 'Travel Pack', author: 'David', stickerCount: 3),
    _buildPack(id: 2, name: 'Meme Pack', author: 'Pepe', stickerCount: 12),
    _buildPack(id: 3, name: 'Work Pack', author: 'Ana', stickerCount: 30),
  ];

  goldenTest(
    name: 'pack_list',
    subdirectory: 'home',
    builder: (_) => SizedBox.expand(
      child: Scaffold(
        body: PackList(
          packs: packs,
          onPackTap: (pack) {},
          onDelete: (pack) {},
          searchQuery: '',
          totalCount: packs.length,
        ),
      ),
    ),
  );
}
