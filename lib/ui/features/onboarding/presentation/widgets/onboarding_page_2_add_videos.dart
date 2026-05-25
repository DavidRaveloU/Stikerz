import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class OnboardingPage2AddVideos extends StatelessWidget {
  final bool showAnimations;

  const OnboardingPage2AddVideos({super.key, this.showAnimations = true});

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
                  context.l10n.onboardingContentLabel,
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
                        text:
                            '${context.l10n.onboardingFromSocialTitlePrimary}\n',
                        style: context.responsiveTextStyle(
                          mobileSize: 30,
                          tabletSize: 36,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: context.l10n.onboardingFromSocialTitleAccent,
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
                  context.l10n.onboardingFromSocialDesc,
                  style: context.responsiveTextStyle(
                    mobileSize: 16,
                    tabletSize: 18,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveSize(60, tabletSize: 72)),

                // Animated social preview with delayed loop segment.
                showAnimations
                    ? const _LottieSocials()
                    : const _StaticSocials(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LottieSocials extends StatefulWidget {
  const _LottieSocials();

  @override
  State<_LottieSocials> createState() => _LottieSocialsState();
}

class _StaticSocials extends StatelessWidget {
  const _StaticSocials();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.responsiveSize(300, tabletSize: 360),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎬',
              style: context.responsiveTextStyle(
                mobileSize: 72,
                tabletSize: 84,
              ),
            ),
            SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
            Text(
              context.l10n.onboardingFromSocialTitleAccent,
              style: context.responsiveTextStyle(
                mobileSize: 16,
                tabletSize: 18,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LottieSocialsState extends State<_LottieSocials>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final double reboteStart = 2140 / 5000.0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.responsiveSize(300, tabletSize: 360),
      child: ClipRect(
        child: Transform.scale(
          scale: 1.5,
          child: Lottie.asset(
            'assets/lottie/socials_options.json',
            controller: _controller,
            fit: BoxFit.contain,
            onLoaded: (composition) async {
              if (_initialized) return;
              _initialized = true;

              _controller.duration = composition.duration;

              await Future.delayed(const Duration(milliseconds: 400));

              if (!mounted) return;

              // Intro segment (0 -> 2.14s).
              await _controller.animateTo(
                reboteStart,
                duration: Duration(
                  milliseconds:
                      (composition.duration.inMilliseconds * reboteStart)
                          .toInt(),
                ),
              );

              // Loop segment (2.14s -> end).
              _controller.repeat(min: reboteStart, max: 1.0);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
