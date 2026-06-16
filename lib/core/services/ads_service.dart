import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ads_config.dart';

/// Centralized service to manage Google Mobile Ads (Banner + Interstitial)
class AdsService {
  static String get _bannerAdUnitId => AdsConfig.bannerAdUnitId;
  static String get _interstitialAdUnitId => AdsConfig.interstitialAdUnitId;
  static const Duration _interstitialCooldown = Duration(seconds: 45);

  static final AdsService _instance = AdsService._internal();

  factory AdsService() {
    return _instance;
  }

  AdsService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  DateTime? _lastInterstitialShownAt;
  Completer<void>? _bannerLoadCompleter;
  bool _isBannerLoading = false;

  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;

  /// Initializes the Google Mobile Ads SDK and preloads banner.
  Future<void> initialize() async {
    if (!AdsConfig.adsEnabled) {
      if (kDebugMode) debugPrint('Ads disabled');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) debugPrint('MobileAds initialized');
      // Preload banner immediately
      await loadBannerAd();
      // Preload interstitial
      loadInterstitialAd();
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing MobileAds: $e');
    }
  }

  /// Loads a banner ad (only one instance ever exists).
  Future<void> loadBannerAd() async {
    if (!AdsConfig.adsEnabled || _isBannerLoading) return;

    _isBannerLoading = true;

    if (_bannerLoadCompleter != null && !_bannerLoadCompleter!.isCompleted) {
      _isBannerLoading = false;
      return _bannerLoadCompleter!.future;
    }

    _bannerLoadCompleter = Completer<void>();

    // Dispose previous banner if exists
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('✓ Banner Ad loaded');
          _isBannerLoaded = true;
          _isBannerLoading = false;
          if (!_bannerLoadCompleter!.isCompleted) {
            _bannerLoadCompleter!.complete();
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) debugPrint('✗ Banner Ad failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
          _isBannerLoading = false;
          if (!_bannerLoadCompleter!.isCompleted) {
            _bannerLoadCompleter!.complete();
          }
          // Retry after 10 seconds
          Future.delayed(const Duration(seconds: 10), () {
            if (!_isBannerLoaded) {
              loadBannerAd();
            }
          });
        },
        onAdOpened: (ad) {
          if (kDebugMode) debugPrint('→ Banner Ad opened');
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
    return _bannerLoadCompleter!.future;
  }

  /// Reset the current banner (keeps the same instance, just reloads if needed)
  Future<void> resetBannerAd() async {
    if (!AdsConfig.adsEnabled) return;
    await loadBannerAd();
  }

  /// Load interstitial ad
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
          if (kDebugMode)
            debugPrint('✗ Interstitial Ad failed: ${error.message}');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Shows an interstitial ad
  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (!AdsConfig.adsEnabled) {
      onDismissed?.call();
      return;
    }

    final now = DateTime.now();
    if (_lastInterstitialShownAt != null &&
        now.difference(_lastInterstitialShownAt!) < _interstitialCooldown) {
      if (kDebugMode) debugPrint('ℹ️ Interstitial in cooldown');
      onDismissed?.call();
      return;
    }

    if (!_isInterstitialLoaded || _interstitialAd == null) {
      if (kDebugMode) debugPrint('⚠️ Interstitial Ad not ready');
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
          if (kDebugMode) debugPrint('👈 Interstitial Ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode)
            debugPrint('✗ Error showing Interstitial: ${error.message}');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
        },
        onAdClicked: (ad) {
          if (kDebugMode) debugPrint('🛛️ Interstitial Ad clicked');
        },
      );

      await _interstitialAd!.show();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Exception showing Interstitial: $e');
      onDismissed?.call();
    }
  }

  /// Disposes ad resources
  Future<void> dispose() async {
    await _bannerAd?.dispose();
    await _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
    _isBannerLoading = false;
  }
}
