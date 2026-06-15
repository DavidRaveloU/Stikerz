import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_3_share_direct.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'onboarding_page_3_share_direct',
    subdirectory: 'onboarding',
    builder: (_) => const TickerMode(
      enabled: false,
      child: OnboardingPage3ShareDirect(showAnimations: false),
    ),
  );
}
