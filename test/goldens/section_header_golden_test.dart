import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/components/section_header.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'section_header',
    subdirectory: 'components',
    builder: (_) => Material(child: SectionHeader('Section Title')),
  );
}
