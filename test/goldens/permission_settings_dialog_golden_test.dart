import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/video_picker/presentation/widgets/permission_settings_dialog.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'permission_settings_dialog',
    subdirectory: 'video_picker',
    builder: (_) => const PermissionSettingsDialog(),
  );
}
