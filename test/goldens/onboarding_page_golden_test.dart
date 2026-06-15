import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/onboarding/presentation/pages/onboarding_page.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'onboarding_page',
    subdirectory: 'onboarding',
    builder: (_) => const ProviderScope(
      child: TickerMode(
        enabled: false,
        child: OnboardingPage(showAnimations: false),
      ),
    ),
  );
}
