import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

class OnboardingPage1Welcome extends StatefulWidget {
  const OnboardingPage1Welcome({super.key});

  @override
  State<OnboardingPage1Welcome> createState() => _OnboardingPage1WelcomeState();
}

class _OnboardingPage1WelcomeState extends State<OnboardingPage1Welcome>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Etiqueta pequeña superior
                    Text(
                      context.l10n.onboardingWelcomeSmallLabel,
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
                                '${context.l10n.onboardingWelcomeTitlePrimary}\n',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          TextSpan(
                            text: context.l10n.onboardingWelcomeTitleAccent,
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
                      context.l10n.onboardingWelcomeDesc,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),

                    // Animación Lottie
                    SizedBox(
                      height: 300,
                      child: Lottie.asset(
                        'assets/lottie/welcome_emoji.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        reverse: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Flecha rebotante en la parte inferior
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 56,
                height: 56,
                child: Lottie.asset(
                  'assets/lottie/arrow_down.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
