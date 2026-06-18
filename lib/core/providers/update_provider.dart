import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/services/update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Provider que verifica actualizaciones en segundo plano
final silentUpdateCheckProvider = FutureProvider<void>((ref) async {
  final updateService = ref.watch(updateServiceProvider);
  await updateService.checkForUpdateSilent();
});

/// Provider que verifica si hay actualización disponible
final updateAvailableProvider = Provider<bool>((ref) {
  return ref.watch(updateServiceProvider).updateAvailable;
});
