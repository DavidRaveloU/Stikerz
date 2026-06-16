import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/services/ads_service.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

/// Provider that initializes ads (call this once at app startup)
final initializeAdsProvider = FutureProvider<void>((ref) async {
  if (!AdsConfig.adsEnabled) return;
  final adsService = ref.watch(adsServiceProvider);
  await adsService.initialize();
});

/// Provider that exposes the preloaded banner ad
final bannerAdProvider = Provider<BannerAd?>((ref) {
  return ref.watch(adsServiceProvider).bannerAd;
});

/// Provider that exposes whether banner is loaded
final isBannerLoadedProvider = Provider<bool>((ref) {
  return ref.watch(adsServiceProvider).isBannerLoaded;
});

/// Provider to preload the interstitial ad
final interstitialAdProvider = FutureProvider<void>((ref) async {
  if (!AdsConfig.adsEnabled) return;
  final adsService = ref.watch(adsServiceProvider);
  adsService.loadInterstitialAd();
});
