import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/providers/purchase_provider.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  static const double adHeight = 105;

  const NativeAdWidget({super.key});

  @override
  ConsumerState<NativeAdWidget> createState() => NativeAdWidgetState();
}

class NativeAdWidgetState extends ConsumerState<NativeAdWidget>
    with SingleTickerProviderStateMixin {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasError = false;
  bool _isPremium = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _loadAd();
  }

  void _onBecamePremium() {
    _isPremium = true;
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
    _hasError = false;
    _fadeController.reset();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant NativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isLoaded && !_hasError) {
      _loadAd();
    }
  }

  void _loadAd() {
    if (!AdsConfig.adsEnabled) {
      if (kDebugMode) debugPrint('Ads disabled, skipping NativeAd');
      return;
    }

    if (ref.read(isPremiumProvider)) {
      if (kDebugMode) debugPrint('Premium user, skipping NativeAd');
      return;
    }

    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    if (_isLoaded && _nativeAd != null) {
      if (kDebugMode) debugPrint('NativeAd already loaded, reusing');
      return;
    }

    if (kDebugMode) debugPrint('Loading NativeAd...');

    _nativeAd = NativeAd(
      adUnitId: AdsConfig.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        cornerRadius: 16.0,
        mainBackgroundColor: const Color(0xFF111114),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: const Color(0xFF5DE0A1),
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFFB5B5BD),
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFFB5B5BD),
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          if (_isPremium) {
            ad.dispose();
            return;
          }
          if (kDebugMode) debugPrint('✓ NativeAd loaded');
          setState(() {
            _nativeAd = ad as NativeAd;
            _isLoaded = true;
            _hasError = false;
          });
          _fadeController.forward();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (_isPremium) return;
          if (kDebugMode) debugPrint('✗ NativeAd failed: ${error.message}');
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _isLoaded = false;
              _hasError = true;
            });
          }
          Future.delayed(const Duration(seconds: 15), () {
            if (mounted && !_isLoaded) {
              if (kDebugMode) debugPrint('Retrying NativeAd...');
              _loadAd();
            }
          });
        },
        onAdClicked: (ad) => debugPrint('🖱️ NativeAd clicked'),
        onAdImpression: (ad) => debugPrint('👁️ NativeAd impression'),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isPremiumProvider, (previous, next) {
      if (next == true && mounted) {
        _onBecamePremium();
      }
    });
    if (!AdsConfig.adsEnabled) {
      return const SizedBox.shrink();
    }

    if (ref.watch(isPremiumProvider)) {
      return const SizedBox.shrink();
    }

    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      return const SizedBox.shrink();
    }

    if (_hasError) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: NativeAdWidget.adHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2E), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: AdWidget(ad: _nativeAd!),
        ),
      ),
    );
  }
}
