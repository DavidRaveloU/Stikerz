import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/services/ads_service.dart';

/// Provider that exposes a singleton `AdsService` instance.
final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

/// Provider to load the banner ad during startup.
final bannerAdProvider = FutureProvider<void>((ref) async {
  if (!AdsConfig.adsEnabled) return;

  final adsService = ref.watch(adsServiceProvider);
  await adsService.resetBannerAd();
  await adsService.loadBannerAd();
});

/// Provider to preload the interstitial ad.
final interstitialAdProvider = FutureProvider<void>((ref) async {
  if (!AdsConfig.adsEnabled) return;

  final adsService = ref.watch(adsServiceProvider);
  adsService.loadInterstitialAd();
});
