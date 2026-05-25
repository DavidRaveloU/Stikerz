import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_1_welcome.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'onboarding_page_1_welcome',
    subdirectory: 'onboarding',
    builder: (_) => const TickerMode(
      enabled: false,
      child: OnboardingPage1Welcome(showAnimations: false),
    ),
  );
}
