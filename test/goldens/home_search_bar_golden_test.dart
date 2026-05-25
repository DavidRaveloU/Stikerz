import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/home/presentation/widgets/home_search_bar.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  final ctrl = TextEditingController(text: '');

  goldenTest(
    name: 'home_search_bar',
    subdirectory: 'home',
    builder: (_) => Material(
      child: HomeSearchBar(controller: ctrl, onChanged: (_) {}),
    ),
  );
}
