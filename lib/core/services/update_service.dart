import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  bool _updateCheckInProgress = false;
  bool _updateAvailable = false;
  bool _updateChecked = false;

  bool get updateAvailable => _updateAvailable;

  /// Verifica si hay una actualización disponible sin mostrar nada.
  /// Esta función es no bloqueante y no interrumpe al usuario.
  Future<bool> checkForUpdateSilent() async {
    if (_updateCheckInProgress) return _updateAvailable;
    _updateCheckInProgress = true;

    try {
      final info = await InAppUpdate.checkForUpdate();
      _updateAvailable =
          info.updateAvailability == UpdateAvailability.updateAvailable;
      _updateChecked = true;
      if (kDebugMode) {
        debugPrint('Update check completed: available = $_updateAvailable');
      }
      return _updateAvailable;
    } catch (e) {
      if (kDebugMode) debugPrint('Silent update check failed: $e');
      return false;
    } finally {
      _updateCheckInProgress = false;
    }
  }

  /// Muestra la actualización si está disponible.
  /// Esta función debe llamarse en un momento que no interrumpa al usuario.
  Future<void> showUpdateIfAvailable() async {
    if (!_updateAvailable) {
      // Si no hemos verificado aún, hacerlo ahora
      if (!_updateChecked) {
        await checkForUpdateSilent();
      }
      if (!_updateAvailable) return;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
        // Después de mostrar la actualización, resetear el flag
        _updateAvailable = false;
        _updateChecked = false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error showing update: $e');
    }
  }

  /// Resetea el estado de la verificación (útil después de mostrar la actualización)
  void reset() {
    _updateAvailable = false;
    _updateChecked = false;
    _updateCheckInProgress = false;
  }
}
