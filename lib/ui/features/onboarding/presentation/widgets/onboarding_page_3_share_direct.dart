import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

class OnboardingPage3ShareDirect extends StatelessWidget {
  const OnboardingPage3ShareDirect({super.key});

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
                // Etiqueta superior sugerida
                Text(
                  context.l10n.onboardingShareLabel,
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
                        text: '${context.l10n.onboardingShareTitlePrimary} ',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      TextSpan(
                        text: context.l10n.onboardingShareTitleAccent,
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
                  context.l10n.onboardingShareDescExtended,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Lottie animación
                SizedBox(
                  height: 300,

                  child: Lottie.asset(
                    'assets/lottie/share_options.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
