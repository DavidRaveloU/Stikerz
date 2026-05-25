import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class OnboardingPage3ShareDirect extends StatelessWidget {
  final bool showAnimations;

  const OnboardingPage3ShareDirect({super.key, this.showAnimations = true});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(24, tabletSize: 32),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.onboardingShareLabel,
                  style: context.responsiveTextStyle(
                    mobileSize: 11,
                    tabletSize: 12,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveSize(24, tabletSize: 28)),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${context.l10n.onboardingShareTitlePrimary} ',
                        style: context.responsiveTextStyle(
                          mobileSize: 30,
                          tabletSize: 36,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: context.l10n.onboardingShareTitleAccent,
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
                SizedBox(height: context.responsiveSize(24, tabletSize: 28)),

                Text(
                  context.l10n.onboardingShareDescExtended,
                  style: context.responsiveTextStyle(
                    mobileSize: 16,
                    tabletSize: 18,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveSize(60, tabletSize: 72)),

                SizedBox(
                  height: context.responsiveSize(300, tabletSize: 360),
                  child: showAnimations
                      ? Lottie.asset(
                          'assets/lottie/share_options.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        )
                      : Center(
                          child: Icon(
                            Icons.share_rounded,
                            size: context.responsiveSize(84, tabletSize: 96),
                            color: AppColors.accent,
                          ),
                        ),
                ),
                SizedBox(height: context.responsiveSize(40, tabletSize: 48)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
