import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/ads_service.dart';

typedef ShowInterstitialAd = Future<void> Function({VoidCallback? onDismissed});

/// Screen to display an interstitial ad after generating a sticker.
///
/// Features:
/// - Shows a Google interstitial ad
/// - Requires a short wait (default 5s) before the close button becomes enabled
/// - Skip is available according to AdMob rules
/// - Closes automatically when finished or if user clicks the close button
/// - Invokes `onDismissed` callback when the ad is closed
///
/// AdMob policy considerations:
/// - The ad is not immediately auto-closed
/// - The user may skip according to policy
/// - Avoids fraudulent click behaviors
/// - Respects timing and callbacks
class InterstitialAdScreen extends StatefulWidget {
  final VoidCallback? onDismissed;
  final ShowInterstitialAd? showInterstitialAd;
  final bool autoStartCountdown;
  final int initialRemainingSeconds;
  final bool autoShowAd;

  const InterstitialAdScreen({
    super.key,
    this.onDismissed,
    this.showInterstitialAd,
    this.autoStartCountdown = true,
    this.initialRemainingSeconds =
        _InterstitialAdScreenState._requiredWaitSeconds,
    this.autoShowAd = true,
  });

  @override
  State<InterstitialAdScreen> createState() => _InterstitialAdScreenState();
}

class _InterstitialAdScreenState extends State<InterstitialAdScreen> {
  static const int _requiredWaitSeconds = 5;
  late int _remainingSeconds;
  Timer? _timer;
  bool get _canClose => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialRemainingSeconds;
    if (widget.autoStartCountdown && _remainingSeconds > 0) {
      _startCountdown();
    }
    // Show the ad if available.
    if (widget.autoShowAd) {
      _showAd();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds -= 1;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _showAd() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final show = widget.showInterstitialAd;
    if (mounted) {
      if (show != null) {
        await show(onDismissed: _handleAdDismissed);
      } else {
        await AdsService().showInterstitialAd(onDismissed: _handleAdDismissed);
      }
    }
  }

  void _handleAdDismissed() {
    if (kDebugMode) debugPrint('Ad dismissed by user or auto-closed');
    // Ad was closed; nothing further to do here.
  }

  void _close() {
    if (!_canClose) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.l10n.onboardingFinishButton} ($_remainingSeconds s)',
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }
    _timer?.cancel();
    widget.onDismissed?.call();
    Navigator.of(context).pop();
  }

  void _skip() {
    _timer?.cancel();
    widget.onDismissed?.call();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canClose,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_canClose) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Espera $_remainingSeconds segundos'),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Main placeholder content while ad is loading.
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videogame_asset,
                      size: 80,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Anuncio publicitario',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Esperando a que se cargue...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Top-right close button respecting safe area insets.
              Builder(
                builder: (ctx) {
                  final topInset = MediaQuery.of(ctx).viewPadding.top;
                  return Positioned(
                    top: topInset + 8,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _close,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              color: _canClose
                                  ? AppColors.accent
                                  : AppColors.border,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Cooldown countdown badge.
              if (!_canClose)
                Builder(
                  builder: (ctx) {
                    final topInset = MediaQuery.of(ctx).viewPadding.top;
                    return Positioned(
                      top: topInset + 72,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_remainingSeconds s',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              // Bottom skip button respecting safe insets.
              Builder(
                builder: (ctx) {
                  final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
                  return Positioned(
                    bottom: bottomInset + 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: OutlinedButton(
                        onPressed: _skip,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'SALTAR',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.accent),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
