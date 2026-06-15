import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'sticker_editor_loading',
    subdirectory: 'sticker_editor',
    builder: (_) => const StickerEditorPage(
      packId: 1,
      slotIndex: 0,
      sourceType: 'local',
      videoPath: 'ignored',
      skipVideoInitialization: true,
    ),
  );
}
