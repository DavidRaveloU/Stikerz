import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/data/models/app_state_model.dart';

final appStateRepositoryProvider = Provider<AppStateRepository>((ref) {
  return AppStateRepository.instance;
});

class AppStateRepository {
  static AppStateRepository? _instance;

  // Singleton
  static AppStateRepository get instance {
    _instance ??= AppStateRepository._();
    return _instance!;
  }

  AppStateRepository._();

  /// Obtiene la instancia de Isar desde PackRepository
  static Isar? get _isar => PackRepository.db;

  Future<bool> isOnboardingCompleted() async {
    try {
      final isar = _isar;
      if (isar == null || !isar.isOpen) {
        return false;
      }
      final appState = await isar.appStateModels.where().findFirst();
      return appState?.onboardingCompleted ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      final isar = _isar;
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
    } catch (e) {
      // Handle error silently
    }
  }
}
