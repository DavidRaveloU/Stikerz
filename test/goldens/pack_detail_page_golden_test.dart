import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/pages/pack_detail_page.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/providers/pack_detail_provider.dart';

import '../golden_test_config.dart';

StickerPackModel _buildFakePack() {
  final pack = StickerPackModel();
  pack.id = 1;
  pack.name = 'My best moments';
  pack.author = 'David Ravelo';
  pack.createdAt = DateTime(2026, 5, 22);
  pack.stickers = [];
  return pack;
}

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'pack_detail_empty',
    subdirectory: 'pack_detail',
    builder: (_) => ProviderScope(
      overrides: [
        packDetailProvider.overrideWith(
          (ref, packId) => Stream.value(_buildFakePack()),
        ),
      ],
      child: PackDetailPage(
        packId: 1,
        heroTag: 'pack_cover_1',
        preloadInterstitialAd: () {},
        heroCoverPreview: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2F3A3F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.photo_library_rounded, color: Colors.white54),
          ),
        ),
      ),
    ),
  );
}
