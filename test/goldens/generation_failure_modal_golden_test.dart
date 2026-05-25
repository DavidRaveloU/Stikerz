import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/generation_failure_modal.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'generation_failure_modal',
    subdirectory: 'sticker_editor',
    builder: (_) => GenerationFailureModal(
      canRetry: true,
      failedSizeBytes: 650 * 1024,
      onRetryWithBlur: () {},
      onRetryWithReduceFps: () {},
      onRetryWithBlurAndReduceFps: () {},
      onRetryWithTransparency: () {},
      onClose: () {},
    ),
  );
}
