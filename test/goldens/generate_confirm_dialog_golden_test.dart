import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/generate_confirm_dialog.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'generate_confirm_dialog',
    subdirectory: 'sticker_editor',
    builder: (_) => GenerateConfirmDialog(
      aspectRatio: AspectRatioOption.square,
      startSecs: 12.3,
      durationSecs: 2.5,
      onCancel: () {},
      onConfirm: () {},
    ),
  );
}
