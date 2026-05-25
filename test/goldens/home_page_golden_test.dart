import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/home/presentation/pages/home_page.dart';
import 'package:stikerz/ui/features/home/presentation/providers/home_provider.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'home_page_empty',
    subdirectory: 'home',
    builder: (_) => ProviderScope(
      overrides: [
        packsStreamProvider.overrideWith(
          (ref) => Stream<List<StickerPackModel>>.value(const []),
        ),
      ],
      child: const HomePage(),
    ),
  );
}
