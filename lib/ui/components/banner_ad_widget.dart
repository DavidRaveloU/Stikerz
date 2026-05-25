import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

/// Displays a Google Mobile Ads banner placeholder or ad widget.
///
/// Keep this widget near the bottom area of a page layout so the banner has
/// stable space and does not overlap interactive content.
class BannerAdWidget extends StatelessWidget {
  final BannerAd? bannerAd;
  final bool isLoaded;

  const BannerAdWidget({
    super.key,
    required this.bannerAd,
    required this.isLoaded,
  });

  @override
  Widget build(BuildContext context) {
    if (!AdsConfig.adsEnabled) {
      return const SizedBox.shrink();
    }

    if (!isLoaded || bannerAd == null) {
      // Reserve banner height to avoid layout jumps while loading.
      return SizedBox(height: context.responsiveSize(50, tabletSize: 54));
    }

    return Container(
      alignment: Alignment.center,
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: bannerAd!),
    );
  }
}
