import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/webview_modal.dart';

const int kOnboardingPage4InitialSeconds = 10;

class OnboardingPage4Ads extends StatefulWidget {
  final VoidCallback onFinish;
  final int initialSeconds;

  const OnboardingPage4Ads({
    super.key,
    required this.onFinish,
    this.initialSeconds = kOnboardingPage4InitialSeconds,
  });

  @override
  State<OnboardingPage4Ads> createState() => _OnboardingPage4AdsState();
}

class _OnboardingPage4AdsState extends State<OnboardingPage4Ads> {
  late int _remainingSeconds;
  Timer? _timer;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  bool get _enabled => _remainingSeconds <= 0;

  void _openTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WebviewModal(
          title: context.l10n.termsAndConditions,
          url: 'https://davidravelou.github.io/stikerz-landing-page/terms/',
        ),
      ),
    );
  }

  void _openPrivacy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WebviewModal(
          title: context.l10n.privacyPolicy,
          url: 'https://davidravelou.github.io/stikerz-landing-page/privacy/',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
    if (_remainingSeconds > 0) {
      _startCountdown();
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

  @override
  void dispose() {
    _timer?.cancel();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle btnStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.border;
        return AppColors.accent;
      }),
      foregroundColor: WidgetStateProperty.all(AppColors.background),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final String buttonText = !_enabled
        ? '${context.l10n.onboardingFinishButton} ($_remainingSeconds s)'
        : context.l10n.onboardingFinishButton;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(24, tabletSize: 32),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.responsiveSize(120, tabletSize: 140),
                      height: context.responsiveSize(120, tabletSize: 140),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '💚',
                          style: context.responsiveTextStyle(
                            mobileSize: 56,
                            tabletSize: 64,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.responsiveSize(40, tabletSize: 48),
                    ),
                    Text(
                      context.l10n.onboardingAdsTitle,
                      style: context.responsiveTextStyle(
                        mobileSize: 24,
                        tabletSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.responsiveSize(24, tabletSize: 28),
                    ),
                    Text(
                      context.l10n.onboardingAdsDescription,
                      style: context.responsiveTextStyle(
                        mobileSize: 16,
                        tabletSize: 18,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.responsiveSize(40, tabletSize: 48),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: context.responsiveSize(20, tabletSize: 28),
            left: context.responsiveSize(24, tabletSize: 32),
            right: context.responsiveSize(40, tabletSize: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: context.responsiveSize(56, tabletSize: 60),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _enabled ? widget.onFinish : null,
                    style: btnStyle,
                    child: Text(
                      buttonText,
                      style: context.responsiveTextStyle(
                        mobileSize: 18,
                        tabletSize: 20,
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(6, tabletSize: 10),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: context.responsiveTextStyle(
                        mobileSize: 12,
                        tabletSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: context.l10n.onboardingLegalPrefix),
                        TextSpan(
                          text: context.l10n.termsAndConditions,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        TextSpan(text: context.l10n.onboardingLegalAnd),
                        TextSpan(
                          text: context.l10n.privacyPolicy,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                        TextSpan(text: context.l10n.onboardingLegalSuffix),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
