import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';

/// Centralized service to manage Google Mobile Ads (Banner + Interstitial)
///
/// AdMob policy considerations:
/// - Do not programmatically click ads
/// - Do not hide ads
/// - Do not use test IDs in production builds
/// - Respect ad load and dispose lifecycle
class AdsService {
  static String get _bannerAdUnitId => AdsConfig.bannerAdUnitId;
  static String get _interstitialAdUnitId => AdsConfig.interstitialAdUnitId;
  static const Duration _interstitialCooldown = Duration(seconds: 45);

  // Singleton instance.
  static final AdsService _instance = AdsService._internal();

  factory AdsService() {
    return _instance;
  }

  AdsService._internal();

  // Internal state.
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  DateTime? _lastInterstitialShownAt;

  // Public state accessors.
  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;

  /// Initializes the Google Mobile Ads SDK.
  Future<void> initialize() async {
    if (!AdsConfig.adsEnabled) {
      if (kDebugMode) {
        debugPrint('Ads disabled: skipping MobileAds initialization');
      }
      return;
    }

    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) debugPrint('MobileAds initialized successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing MobileAds: $e');
    }
  }

  /// Loads a banner ad.
  Future<void> loadBannerAd() async {
    if (!AdsConfig.adsEnabled) {
      _bannerAd = null;
      _isBannerLoaded = false;
      return;
    }

    final loadedCompleter = Completer<void>();

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('✓ Banner Ad loaded');
          _isBannerLoaded = true;
          if (!loadedCompleter.isCompleted) {
            loadedCompleter.complete();
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) debugPrint('✗ Banner Ad failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
          if (!loadedCompleter.isCompleted) {
            loadedCompleter.complete();
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) debugPrint('→ Banner Ad opened (user clicked)');
        },
        onAdClosed: (ad) {
          if (kDebugMode) debugPrint('← Banner Ad closed');
        },
        onAdClicked: (ad) {
          if (kDebugMode) debugPrint('🖱️ Banner Ad clicked');
        },
      ),
    );

    _bannerAd!.load();
    await loadedCompleter.future;
  }

  /// Reset the current banner to avoid reusing the same AdWidget instance
  /// when restarting the share flow.
  Future<void> resetBannerAd() async {
    if (!AdsConfig.adsEnabled) {
      _bannerAd = null;
      _isBannerLoaded = false;
      return;
    }

    await _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  /// Load interstitial ad (only loads; does not show automatically)
  void loadInterstitialAd({VoidCallback? onLoaded}) {
    if (!AdsConfig.adsEnabled) {
      _interstitialAd = null;
      _isInterstitialLoaded = false;
      onLoaded?.call();
      return;
    }

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('✓ Interstitial Ad loaded');
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('✗ Interstitial Ad failed: ${error.message}');
          }
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Shows an interstitial ad with safety checks.
  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (!AdsConfig.adsEnabled) {
      if (kDebugMode) debugPrint('Ads disabled: skipping interstitial');
      onDismissed?.call();
      return;
    }

    final now = DateTime.now();
    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null &&
        now.difference(lastShown) < _interstitialCooldown) {
      if (kDebugMode) {
        debugPrint('ℹ️ Interstitial in cooldown, not showing yet');
      }
      onDismissed?.call();
      return;
    }

    if (!_isInterstitialLoaded || _interstitialAd == null) {
      if (kDebugMode) debugPrint('⚠️ Interstitial Ad is not ready. Loading...');
      loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) debugPrint('📺 Interstitial Ad shown');
          _lastInterstitialShownAt = DateTime.now();
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) debugPrint('👈 Interstitial Ad dismissed by user');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
          // Preload the next ad for future displays.
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            debugPrint('✗ Error showing Interstitial: ${error.message}');
          }
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
        },
        onAdClicked: (ad) {
          if (kDebugMode) {
            debugPrint('🛛️ Interstitial Ad clicked');
          }
        },
      );

      await _interstitialAd!.show();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Exception showing Interstitial: $e');
      onDismissed?.call();
    }
  }

  /// Disposes ad resources and resets local state.
  Future<void> dispose() async {
    if (!AdsConfig.adsEnabled) {
      _bannerAd = null;
      _interstitialAd = null;
      _isBannerLoaded = false;
      _isInterstitialLoaded = false;
      return;
    }

    await _bannerAd?.dispose();
    await _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
  }
}
