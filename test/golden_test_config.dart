import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/generated_l10n/app_localizations.dart';

void setupGoldenTests() {
  goldenTestDefaultDevices = const [
    Device(name: 'mobile', width: 390, height: 844, devicePixelRatio: 3),
    Device(name: 'large_mobile', width: 430, height: 932, devicePixelRatio: 3),
    Device(name: 'tablet', width: 834, height: 1194, devicePixelRatio: 2),
  ];

  goldenTestSupportedLocales = const [Locale('en'), Locale('es'), Locale('pt')];
  goldenTestSupportedThemes = const [Brightness.light, Brightness.dark];
  goldenTestSupportMultipleDevices = true;

  goldenTestThemeInTests = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7CB342)),
  );

  goldenTestDarkThemeInTests = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7CB342),
      brightness: Brightness.dark,
    ),
  );

  goldenTestLocalizationsDelegates = const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  goldenTestDifferenceTolerance(0.5);
}
