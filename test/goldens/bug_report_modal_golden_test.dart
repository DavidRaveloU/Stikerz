import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/bug_report_modal.dart';

import '../golden_test_config.dart';

Future<Map<String, String>> _loadFakeDeviceInfo() async {
  return {
    'Manufacturer': 'Google',
    'Model': 'Pixel 9 Pro XL',
    'Brand': 'google',
    'Device': 'husky',
    'Android Version': '15',
    'SDK': '35',
    'Security Patch': '2026-05-05',
    'App Version': '1.0.0+1',
  };
}

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'bug_report_modal',
    subdirectory: 'settings',
    builder: (_) => BugReportModal(deviceInfoLoader: _loadFakeDeviceInfo),
  );
}
