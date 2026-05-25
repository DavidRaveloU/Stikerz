import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/data/models/app_state_model.dart';

final appStateRepositoryProvider = Provider<AppStateRepository>((ref) {
  return AppStateRepository.instance;
});

/// Repository that stores small application-level state in Isar.
///
/// This keeps simple settings (onboarding completion, preferred locale)
/// persisted and exposes lightweight synchronous caches to avoid frequent
/// DB reads at runtime.
class AppStateRepository {
  static AppStateRepository? _instance;
  static bool? _cachedOnboardingCompleted;

  // Singleton
  static AppStateRepository get instance {
    _instance ??= AppStateRepository._();
    return _instance!;
  }

  AppStateRepository._();

  /// Isar instance used by the repository (delegates to PackRepository).
  static Isar? get _isar => PackRepository.db;

  /// Cached onboarding completion flag to avoid repeated DB reads.
  bool? get cachedOnboardingCompleted => _cachedOnboardingCompleted;

  /// Returns true if onboarding was completed previously.
  ///
  /// Reads the value from the DB on first call and caches it in memory.
  Future<bool> isOnboardingCompleted() async {
    try {
      final isar = _isar;
      if (isar == null || !isar.isOpen) {
        _cachedOnboardingCompleted = false;
        return false;
      }
      final appState = await isar.appStateModels.where().findFirst();
      final completed = appState?.onboardingCompleted ?? false;
      _cachedOnboardingCompleted = completed;
      return completed;
    } catch (_) {
      _cachedOnboardingCompleted = false;
      return false;
    }
  }

  /// Persist onboarding completion flag and update the in-memory cache.
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      final isar = _isar;
      _cachedOnboardingCompleted = completed;
      if (isar == null || !isar.isOpen) {
        return;
      }
      final appState = AppStateModel()
        ..onboardingCompleted = completed
        ..lastModified = DateTime.now();

      await isar.writeTxn(() async {
        await isar.appStateModels.clear();
        await isar.appStateModels.put(appState);
      });
    } catch (_) {
      // Intentionally swallow errors; this is non-critical.
    }
  }

  /// Returns the user's preferred locale code, or `null` if not set.
  Future<String?> getPreferredLocale() async {
    try {
      final isar = _isar;
      if (isar == null || !isar.isOpen) return null;
      final appState = await isar.appStateModels.where().findFirst();
      return appState?.preferredLocale;
    } catch (_) {
      return null;
    }
  }

  /// Persist the preferred locale. Preserves the onboarding cached flag.
  Future<void> setPreferredLocale(String? localeCode) async {
    try {
      final isar = _isar;
      if (isar == null || !isar.isOpen) return;

      final model = AppStateModel()
        ..preferredLocale = localeCode
        ..onboardingCompleted = _cachedOnboardingCompleted ?? false
        ..lastModified = DateTime.now();

      await isar.writeTxn(() async {
        await isar.appStateModels.clear();
        await isar.appStateModels.put(model);
      });
    } catch (_) {
      // ignore errors for non-critical persistence
    }
  }
}
