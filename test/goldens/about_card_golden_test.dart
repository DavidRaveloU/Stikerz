import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/components/about_card.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'about_card',
    subdirectory: 'settings',
    builder: (_) => const Center(
      child: AboutCard(
        name: 'David Ravelo',
        role: 'Lead Developer & Designer',
        description:
            'Creating fluid and beautiful digital experiences for the world.',
        appName: 'Stikerz',
        version: 'Version 1.0.0+1',
        instagramUrl: 'https://www.instagram.com/hereisdavidr/',
        githubUrl: 'https://github.com/DavidRaveloU',
        emailAddress: 'davidravelo1510@gmail.com',
      ),
    ),
  );
}
