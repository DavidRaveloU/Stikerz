import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/providers/ads_provider.dart';
import 'package:stikerz/core/providers/purchase_provider.dart';
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
    final shareResetToken = ref.watch(shareFlowResetProvider);
    final isPremium = ref.watch(isPremiumProvider);

    if (!AdsConfig.adsEnabled || isPremium) {
      return Scaffold(body: widget.child);
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _LocalBannerAdSlot(
        key: ValueKey<int>(shareResetToken),
      ),
    );
  }
}

class _LocalBannerAdSlot extends StatefulWidget {
  const _LocalBannerAdSlot({super.key});

  @override
  State<_LocalBannerAdSlot> createState() => _LocalBannerAdSlotState();
}

class _LocalBannerAdSlotState extends State<_LocalBannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    final bannerAd = BannerAd(
      adUnitId: AdsConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );

    _bannerAd = bannerAd;
    await bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return SafeArea(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
