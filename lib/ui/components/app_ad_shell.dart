import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/providers/ads_provider.dart';
import 'package:stikerz/core/providers/share_provider.dart';

class AppAdShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppAdShell({super.key, required this.child});

  @override
  ConsumerState<AppAdShell> createState() => _AppAdShellState();
}

class _AppAdShellState extends ConsumerState<AppAdShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interstitialAdProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hasModal = ModalRoute.of(context)?.isCurrent != true;
    final shareResetToken = ref.watch(shareFlowResetProvider);
    final bannerAd = ref.watch(bannerAdProvider);
    final isBannerLoaded = ref.watch(isBannerLoadedProvider);

    // Ocultar banner si: teclado abierto O hay un modal encima
    final shouldHideBanner = keyboardOpen || hasModal;

    if (!AdsConfig.adsEnabled) {
      return Scaffold(body: widget.child);
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: shouldHideBanner
          ? null
          : _GlobalBannerAdSlot(
              key: ValueKey<int>(shareResetToken),
              bannerAd: bannerAd,
              isLoaded: isBannerLoaded,
            ),
    );
  }
}

class _GlobalBannerAdSlot extends StatefulWidget {
  final BannerAd? bannerAd;
  final bool isLoaded;

  const _GlobalBannerAdSlot({
    super.key,
    required this.bannerAd,
    required this.isLoaded,
  });

  @override
  State<_GlobalBannerAdSlot> createState() => _GlobalBannerAdSlotState();
}

class _GlobalBannerAdSlotState extends State<_GlobalBannerAdSlot> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoaded || widget.bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return SafeArea(
      child: SizedBox(
        width: widget.bannerAd!.size.width.toDouble(),
        height: widget.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: widget.bannerAd!),
      ),
    );
  }
}
