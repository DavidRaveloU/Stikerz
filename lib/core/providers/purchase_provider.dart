import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/services/purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService();
  ref.onDispose(service.dispose);
  return service;
});

/// `true` una vez que el usuario compró "remove_ads" (o se restauró tras
/// reinstalar la app). Úsalo en cualquier widget para ocultar anuncios:
/// `final isPremium = ref.watch(isPremiumProvider);`
final isPremiumProvider = StateProvider<bool>((ref) => false);

/// Conecta con el billing client y dispara el restore silencioso al
/// arrancar la app. Debe leerse una sola vez, por ejemplo en
/// `_AppState.initState()` junto al chequeo de actualizaciones.
final purchaseInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(purchaseServiceProvider);

  void syncState() {
    ref.read(isPremiumProvider.notifier).state = service.isPremium.value;
  }

  service.isPremium.addListener(syncState);
  ref.onDispose(() => service.isPremium.removeListener(syncState));

  await service.initialize();
  syncState();
});