import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/services/ads_service.dart';

/// Provider singleton del servicio de ads
final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

/// Provider para cargar el banner ad al iniciar
final bannerAdProvider = FutureProvider<void>((ref) async {
  final adsService = ref.watch(adsServiceProvider);
  adsService.loadBannerAd();
});

/// Provider para precargar el interstitial ad
final interstitialAdProvider = FutureProvider<void>((ref) async {
  final adsService = ref.watch(adsServiceProvider);
  adsService.loadInterstitialAd();
});
