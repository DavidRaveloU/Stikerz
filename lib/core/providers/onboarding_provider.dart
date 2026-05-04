import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/repositories/app_state_repository.dart';

/// Provider para saber si el onboarding fue completado
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repository = AppStateRepository.instance;
  return await repository.isOnboardingCompleted();
});

/// Provider notificador para cambiar el estado de onboarding
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
      return OnboardingNotifier();
    });

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = await AppStateRepository.instance.isOnboardingCompleted();
  }

  Future<void> completeOnboarding() async {
    await AppStateRepository.instance.setOnboardingCompleted(true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    await AppStateRepository.instance.setOnboardingCompleted(false);
    state = false;
  }
}
