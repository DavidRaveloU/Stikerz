import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

class OnboardingPage4Ads extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingPage4Ads({super.key, required this.onFinish});

  @override
  State<OnboardingPage4Ads> createState() => _OnboardingPage4AdsState();
}

class _OnboardingPage4AdsState extends State<OnboardingPage4Ads> {
  static const int _initialSeconds = 10;
  late int _remainingSeconds;
  Timer? _timer;
  bool get _enabled => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _initialSeconds;
    _startCountdown();
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '💚',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Título
                    Text(
                      context.l10n.onboardingAdsTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Descripción
                    Text(
                      context.l10n.onboardingAdsDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 40,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _enabled ? widget.onFinish : null,
                style: btnStyle,
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
