import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/add_sticker_sheet.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'add_sticker_sheet',
    subdirectory: 'pack_detail',
    builder: (_) => AddStickerSheet(
      onLocal: () {},
      onTikTokUrl: (_) {},
      onInstagramUrl: (_) {},
    ),
  );
}
