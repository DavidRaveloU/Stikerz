import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stikerz/core/services/purchase_service.dart';

import '../config/ads_config.dart';

class AdsService {
  static String get _interstitialAdUnitId => AdsConfig.interstitialAdUnitId;
  static const Duration _interstitialCooldown = Duration(seconds: 45);

  static final AdsService _instance = AdsService._internal();

  factory AdsService() {
    return _instance;
  }

  AdsService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  DateTime? _lastInterstitialShownAt;

  bool get isInterstitialLoaded => _isInterstitialLoaded;

  Future<void> initialize() async {
    if (!AdsConfig.adsEnabled) {
      if (kDebugMode) debugPrint('Ads disabled');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) debugPrint('MobileAds initialized');
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing MobileAds: $e');
    }
  }

  void loadInterstitialAd({VoidCallback? onLoaded}) {
    if (!AdsConfig.adsEnabled) {
      _interstitialAd = null;
      _isInterstitialLoaded = false;
      onLoaded?.call();
      return;
    }

    if (PurchaseService().isPremium.value) {
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

  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (!AdsConfig.adsEnabled) {
      onDismissed?.call();
      return;
    }

    if (PurchaseService().isPremium.value) {
      onDismissed?.call();
      return;
    }

    final now = DateTime.now();
    if (_lastInterstitialShownAt != null &&
        now.difference(_lastInterstitialShownAt!) < _interstitialCooldown) {
      onDismissed?.call();
      return;
    }

    if (!_isInterstitialLoaded || _interstitialAd == null) {
      loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _lastInterstitialShownAt = DateTime.now();
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
        },
      );
      await _interstitialAd!.show();
    } catch (e) {
      onDismissed?.call();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
