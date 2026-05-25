import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/components/create_pack_modal.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'create_pack_modal',
    subdirectory: 'home',
    builder: (_) => const CreatePackModal(),
  );
}
