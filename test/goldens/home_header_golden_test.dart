import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/home/presentation/widgets/home_header.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'home_header',
    subdirectory: 'home',
    builder: (_) => const TickerMode(
      enabled: false,
      child: HomeHeader(),
    ),
  );
}
