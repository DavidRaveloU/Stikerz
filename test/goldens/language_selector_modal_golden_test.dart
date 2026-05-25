import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/language_selector_modal.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'language_selector_modal',
    subdirectory: 'settings',
    builder: (_) => const ProviderScope(child: LanguageSelectorModal()),
  );
}
