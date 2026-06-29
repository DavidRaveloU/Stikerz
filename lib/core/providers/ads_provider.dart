import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/providers/purchase_provider.dart';
import 'package:stikerz/core/services/ads_service.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

final interstitialAdProvider = FutureProvider<void>((ref) async {
  if (!AdsConfig.adsEnabled) return;
  if (ref.watch(isPremiumProvider)) return;
  final adsService = ref.watch(adsServiceProvider);
  adsService.loadInterstitialAd();
});
