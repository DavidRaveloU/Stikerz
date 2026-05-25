import 'package:flutter/foundation.dart';

/// AdsConfig centralizes IDs and reading from --dart-define.
///
/// Recommended usage: pass IDs at build time with:
/// `--dart-define=ADMOB_APP_ID=... --dart-define=ADMOB_BANNER_ID=...`
class AdsConfig {
  // Toggle this flag to true to re-enable all ads globally.
  static const bool adsEnabled = true;

  // Public Google test IDs (do not use in production)
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // Placeholders to avoid exposing real IDs in the repo.
  // In release builds these should be replaced via --dart-define.
  static const String _prodAppId = 'ADMOB_APP_ID_PLACEHOLDER';
  static const String _prodBannerId = 'ADMOB_BANNER_ID_PLACEHOLDER';
  static const String _prodInterstitialId = 'ADMOB_INTERSTITIAL_ID_PLACEHOLDER';

  // Values read from --dart-define
  static const String _envAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: '',
  );
  static const String _envBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: '',
  );
  static const String _envInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: '',
  );

  static bool get useTestIds => kDebugMode;

  static String get appId {
    if (useTestIds) return _testAppId;
    if (_envAppId.isNotEmpty) return _envAppId;
    return _prodAppId;
  }

  static String get bannerAdUnitId {
    if (useTestIds) return _testBannerId;
    if (_envBannerId.isNotEmpty) return _envBannerId;
    return _prodBannerId;
  }

  static String get interstitialAdUnitId {
    if (useTestIds) return _testInterstitialId;
    if (_envInterstitialId.isNotEmpty) return _envInterstitialId;
    return _prodInterstitialId;
  }

  /// Debug helper
  static String debugSummary() {
    return 'AdsConfig(useTestIds: $useTestIds, appId: ${appId.isNotEmpty}, banner: ${bannerAdUnitId.isNotEmpty}, interstitial: ${interstitialAdUnitId.isNotEmpty})';
  }
}
