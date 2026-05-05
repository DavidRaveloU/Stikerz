import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/providers/ads_provider.dart';
import 'package:whaticker/ui/components/banner_ad_widget.dart';

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
      ref.read(bannerAdProvider);
      ref.read(interstitialAdProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adsService = ref.watch(adsServiceProvider);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: keyboardOpen
          ? null
          : BannerAdWidget(
              bannerAd: adsService.bannerAd,
              isLoaded: adsService.isBannerLoaded,
            ),
    );
  }
}
