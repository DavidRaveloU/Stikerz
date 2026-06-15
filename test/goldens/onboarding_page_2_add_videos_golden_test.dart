import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_2_add_videos.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'onboarding_page_2_add_videos',
    subdirectory: 'onboarding',
    builder: (_) => const TickerMode(
      enabled: false,
      child: OnboardingPage2AddVideos(showAnimations: false),
    ),
  );
}
