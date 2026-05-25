import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/video_picker/presentation/widgets/confirm_bar.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'confirm_bar',
    subdirectory: 'video_picker',
    builder: (_) => Material(child: ConfirmBar(onConfirm: () {})),
  );
}
