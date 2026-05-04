import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

class OnboardingPage2AddVideos extends StatelessWidget {
  const OnboardingPage2AddVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Etiqueta pequeña superior
                Text(
                  context.l10n.onboardingContentLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Título principal
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${context.l10n.onboardingFromSocialTitlePrimary}\n',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      TextSpan(
                        text: context.l10n.onboardingFromSocialTitleAccent,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Descripción
                Text(
                  context.l10n.onboardingFromSocialDesc,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Lottie con zoom + delay
                const _LottieSocials(),
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
      height: 300,
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

              // Intro (0 → 2.14s)
              await _controller.animateTo(
                reboteStart,
                duration: Duration(
                  milliseconds:
                      (composition.duration.inMilliseconds * reboteStart)
                          .toInt(),
                ),
              );

              // Loop (2.14 → 5s)
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
