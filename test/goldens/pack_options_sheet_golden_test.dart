import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/pack_options_sheet.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'pack_options_sheet',
    subdirectory: 'pack_detail',
    builder: (_) => PackOptionsSheet(onRename: () {}, onDelete: () {}),
  );
}
