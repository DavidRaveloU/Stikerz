import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_4_ads.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'onboarding_page_4_ads',
    subdirectory: 'onboarding',
    builder: (_) => OnboardingPage4Ads(onFinish: () {}, initialSeconds: 0),
  );
}
