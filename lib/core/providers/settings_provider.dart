import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/repositories/app_state_repository.dart';

/// Provider that holds the selected locale code: 'en','es','pt' or null for system.
final settingsProvider = StateNotifierProvider<SettingsNotifier, String?>((
  ref,
) {
  final repo = AppStateRepository.instance;
  return SettingsNotifier(repo);
});

class SettingsNotifier extends StateNotifier<String?> {
  final AppStateRepository _repo;
  SettingsNotifier(this._repo) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final code = await _repo.getPreferredLocale();
    state = code;
  }

  Future<void> setLocale(String? code) async {
    state = code;
    await _repo.setPreferredLocale(code);
  }
}
