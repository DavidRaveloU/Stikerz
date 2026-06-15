import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/repositories/app_state_repository.dart';

/// Provider that exposes whether onboarding has been completed.
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repository = AppStateRepository.instance;
  return await repository.isOnboardingCompleted();
});

/// Notifier provider to change onboarding state.
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier()
    : super(AppStateRepository.instance.cachedOnboardingCompleted ?? false) {
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
