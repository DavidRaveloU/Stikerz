import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/rename_pack_modal.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'rename_pack_modal',
    subdirectory: 'pack_detail',
    builder: (_) => RenamePackModal(
      currentName: 'My Pack',
      currentAuthor: 'David',
      onSave: (name, author) async {},
    ),
  );
}
