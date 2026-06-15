// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/video_picker/presentation/widgets/video_tile.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'video_tile',
    subdirectory: 'video_picker',
    builder: (_) => Material(
      child: VideoTile(
        // Asset is not used because we pass thumbnail/data overrides.
        asset: null,
        isSelected: true,
        formatDuration: (d) => '0:03',
        onTap: () {},
        thumbnailDataOverride: null,
        videoDurationOverride: const Duration(seconds: 3),
      ),
    ),
  );
}
