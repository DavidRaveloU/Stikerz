import 'package:golden_test/golden_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stikerz/ui/features/video_picker/presentation/pages/video_picker_page.dart';

import '../golden_test_config.dart';

Future<PermissionState> _deniedPermission() async => PermissionState.denied;

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'video_picker_permission_denied',
    subdirectory: 'video_picker',
    builder: (_) => VideoPickerPage(permissionStateLoader: _deniedPermission),
  );
}
