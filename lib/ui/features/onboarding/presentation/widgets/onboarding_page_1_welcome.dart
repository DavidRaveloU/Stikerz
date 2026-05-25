import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class OnboardingPage1Welcome extends StatefulWidget {
  final bool showAnimations;

  const OnboardingPage1Welcome({super.key, this.showAnimations = true});

  @override
  State<OnboardingPage1Welcome> createState() => _OnboardingPage1WelcomeState();
}

class _OnboardingPage1WelcomeState extends State<OnboardingPage1Welcome>
    with TickerProviderStateMixin {
  AnimationController? _bounceController;

  @override
  void initState() {
    super.initState();
    if (widget.showAnimations) {
      _bounceController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      context.l10n.onboardingWelcomeSmallLabel,
                      style: context.responsiveTextStyle(
                        mobileSize: 11,
                        tabletSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.responsiveSize(24, tabletSize: 28),
                    ),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${context.l10n.onboardingWelcomeTitlePrimary}\n',
                            style: context.responsiveTextStyle(
                              mobileSize: 30,
                              tabletSize: 36,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: context.l10n.onboardingWelcomeTitleAccent,
                            style: context.responsiveTextStyle(
                              mobileSize: 30,
                              tabletSize: 36,
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: context.responsiveSize(24, tabletSize: 28),
                    ),

                    Text(
                      context.l10n.onboardingWelcomeDesc,
                      style: context.responsiveTextStyle(
                        mobileSize: 16,
                        tabletSize: 18,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: context.responsiveSize(60, tabletSize: 72),
                    ),

                    SizedBox(
                      height: context.responsiveSize(300, tabletSize: 360),
                      child: widget.showAnimations
                          ? Lottie.asset(
                              'assets/lottie/welcome_emoji.json',
                              fit: BoxFit.contain,
                              repeat: true,
                              reverse: false,
                            )
                          : Center(
                              child: Text(
                                '💚',
                                style: context.responsiveTextStyle(
                                  mobileSize: 72,
                                  tabletSize: 84,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom bounce indicator.
          Positioned(
            bottom: context.responsiveSize(60, tabletSize: 72),
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: context.responsiveSize(56, tabletSize: 64),
                height: context.responsiveSize(56, tabletSize: 64),
                child: widget.showAnimations
                    ? Lottie.asset(
                        'assets/lottie/arrow_down.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      )
                    : const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.accent,
                        size: 42,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
