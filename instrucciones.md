# Tarea: integrar compra única "remove_ads" con in_app_purchase (solo Android)

## Contexto
Proyecto Flutter llamado `stikerz`. Usa Riverpod (estilo `Provider`/`FutureProvider` funcional, NO `@riverpod` codegen). Tiene un sistema de anuncios AdMob (`AdsConfig`, `AdsService`, `app_ad_shell.dart`, `native_ad_widget.dart`, `banner_ad_widget.dart`) que debe dejar de mostrarse cuando el usuario compre "remove_ads". El producto no consumible ya existe en Play Console con el ID `remove_ads`. Solo Android, no tocar nada de iOS.

No modificar nada de la lógica de anuncios más allá de lo indicado explícitamente abajo. No tocar AndroidManifest.xml: el permiso `com.android.vending.BILLING` ya viene embebido en el manifest del Play Billing Library y se fusiona automáticamente al compilar, no requiere declaración manual.

---

## Paso 1 — Dependencia

En `pubspec.yaml`, dentro de `dependencies:`, agregar:

```yaml
in_app_purchase: ^3.3.0
```

Luego ejecutar `flutter pub get`.

---

## Paso 2 — Crear `lib/core/services/purchase_service.dart` (archivo nuevo)

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// PurchaseService gestiona la compra única "remove_ads" usando el plugin
/// oficial de Flutter (in_app_purchase), sin backend propio.
///
/// El Play Store es la única fuente de verdad: en cada arranque de la app
/// se llama a [initialize], que conecta con el billing client y dispara un
/// restore silencioso. Si el usuario ya compró "remove_ads" (incluso en una
/// instalación anterior), [isPremium] pasará a `true` automáticamente en
/// cuanto el Play Store responda.
class PurchaseService {
  static const String removeAdsProductId = 'remove_ads';

  static final PurchaseService _instance = PurchaseService._internal();

  factory PurchaseService() => _instance;

  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Notifica a quien escuche (ver purchase_provider.dart) cuando cambia
  /// el estado de "es premium / no_ads".
  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  bool _isAvailable = false;
  bool _initialized = false;
  ProductDetails? _removeAdsProduct;

  bool get isStoreAvailable => _isAvailable;
  ProductDetails? get removeAdsProduct => _removeAdsProduct;

  /// Debe llamarse una sola vez al arrancar la app (ver purchase_provider.dart).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      if (kDebugMode) {
        debugPrint('⚠️ IAP no disponible (¿emulador sin Play Store / sin sesión?)');
      }
      return;
    }

    // Importante: suscribirse al stream ANTES de pedir el restore,
    // para no perder eventos que lleguen como respuesta al restore.
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (e) {
        if (kDebugMode) debugPrint('✗ Error en purchaseStream: $e');
      },
    );

    await _loadProduct();

    // Restore silencioso: así, si el usuario reinstaló la app, el estado
    // "sin anuncios" se recupera solo, sin que tenga que tocar nada.
    await restorePurchases();
  }

  Future<void> _loadProduct() async {
    try {
      final response = await _iap.queryProductDetails({removeAdsProductId});

      if (response.error != null) {
        if (kDebugMode) debugPrint('✗ Error consultando producto: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Producto "$removeAdsProductId" no encontrado en el store. '
            'Verifica que esté Activo en Play Console y que el APK/AAB '
            'instalado tenga el mismo applicationId y firma que el subido.',
          );
        }
      }

      if (response.productDetails.isNotEmpty) {
        _removeAdsProduct = response.productDetails.first;
        if (kDebugMode) {
          debugPrint('✓ Producto cargado: ${_removeAdsProduct!.id} (${_removeAdsProduct!.price})');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('✗ Excepción cargando producto: $e');
    }
  }

  /// Lanza el flujo de compra nativo de Google Play.
  Future<void> buyRemoveAds() async {
    if (!_isAvailable) return;

    if (_removeAdsProduct == null) {
      await _loadProduct();
      if (_removeAdsProduct == null) return;
    }

    final purchaseParam = PurchaseParam(productDetails: _removeAdsProduct!);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (kDebugMode) debugPrint('✗ Error iniciando compra: $e');
    }
  }

  /// Pide al store que reenvíe (vía purchaseStream) todas las compras que
  /// el usuario ya posee. Útil tanto para el restore silencioso al arrancar
  /// como para un botón manual "Restaurar compra" en Ajustes.
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (kDebugMode) debugPrint('✗ Error restaurando compras: $e');
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != removeAdsProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isPremium.value = true;
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.error:
          if (kDebugMode) debugPrint('✗ Error de compra: ${purchase.error}');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.pending:
          // No hacemos nada todavía; esperamos el siguiente evento del stream.
          break;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

---

## Paso 3 — Crear `lib/core/providers/purchase_provider.dart` (archivo nuevo)

```dart
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
```

---

## Paso 4 — Crear `lib/ui/features/settings/presentation/widgets/remove_ads_tile.dart` (archivo nuevo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/providers/purchase_provider.dart';

/// Tile para Ajustes con el botón de compra "Eliminar anuncios" y el botón
/// de restaurar compra.
class RemoveAdsTile extends ConsumerWidget {
  const RemoveAdsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final service = ref.watch(purchaseServiceProvider);

    if (isPremium) {
      return const ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text('Anuncios eliminados'),
        subtitle: Text('Gracias por tu compra'),
      );
    }

    final product = service.removeAdsProduct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.block),
          title: const Text('Eliminar anuncios'),
          subtitle: Text(
            product == null
                ? (service.isStoreAvailable ? 'Cargando precio…' : 'No disponible')
                : 'Compra única · ${product.price} · para siempre',
          ),
          onTap: (service.isStoreAvailable && product != null)
              ? () => service.buyRemoveAds()
              : null,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: TextButton(
            onPressed: () => service.restorePurchases(),
            child: const Text('Restaurar compra'),
          ),
        ),
      ],
    );
  }
}
```

Después de crearlo, abrir `lib/ui/features/settings/presentation/pages/settings_page.dart`, importar este widget, e insertar `const RemoveAdsTile()` en un lugar razonable dentro de la lista de opciones de ajustes (cerca de "About" o al inicio de la lista). Mantener el estilo visual existente de la página (si hay un patrón de separadores/secciones entre tiles, replicarlo).

---

## Paso 5 — Editar `lib/core/providers/ads_provider.dart`

Agregar el import:
```dart
import 'package:stikerz/core/providers/purchase_provider.dart';
```

Y modificar `interstitialAdProvider` para que no cargue el interstitial si el usuario ya es premium:

```dart
final interstitialAdProvider = FutureProvider<void>((ref) async {
  if (!AdsConfig.adsEnabled) return;
  if (ref.watch(isPremiumProvider)) return;
  final adsService = ref.watch(adsServiceProvider);
  adsService.loadInterstitialAd();
});
```

---

## Paso 6 — Editar `lib/ui/components/app_ad_shell.dart`

En el método `build` de `_AppAdShellState`, agregar la lectura de `isPremiumProvider` y usarla junto a `AdsConfig.adsEnabled` para decidir si se muestra el banner:

```dart
@override
Widget build(BuildContext context) {
  final shareResetToken = ref.watch(shareFlowResetProvider);
  final isPremium = ref.watch(isPremiumProvider);

  if (!AdsConfig.adsEnabled || isPremium) {
    return Scaffold(body: widget.child);
  }

  return Scaffold(
    body: widget.child,
    bottomNavigationBar: _LocalBannerAdSlot(
      key: ValueKey<int>(shareResetToken),
    ),
  );
}
```

Agregar el import correspondiente:
```dart
import 'package:stikerz/core/providers/purchase_provider.dart';
```

---

## Paso 7 — Editar `lib/main.dart`

En `_AppState.initState()`, agregar la línea que dispara la conexión con el store y el restore silencioso, junto al chequeo de actualizaciones existente:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  ref.read(purchaseInitProvider);
  _checkForUpdateOnStartup();
}
```

Agregar el import:
```dart
import 'package:stikerz/core/providers/purchase_provider.dart';
```

---

## Paso 8 — Editar `lib/ui/components/native_ad_widget.dart`

Abrir el archivo (no incluido en este documento, revisar contenido actual). Es un `ConsumerWidget` o similar que renderiza el anuncio nativo. Al inicio de su método `build`, antes de cualquier otra lógica, agregar:

```dart
if (ref.watch(isPremiumProvider)) {
  return const SizedBox.shrink();
}
```

Si el widget NO es actualmente un `ConsumerWidget`/`ConsumerStatefulWidget` (es decir, no tiene acceso a `ref`), convertirlo a uno para poder leer el provider, ajustando su constructor y los lugares donde se instancia. Si tiene una variante con `AdsConfig.adsEnabled` ya como check inicial (similar a `BannerAdWidget`), agregar el check de `isPremiumProvider` junto a ese, con el mismo criterio: si es premium, no renderizar nada.

Agregar el import correspondiente:
```dart
import 'package:stikerz/core/providers/purchase_provider.dart';
```

---

## Paso 9 — Verificación

1. Ejecutar `flutter pub get`.
2. Ejecutar `flutter analyze` y corregir cualquier error de imports faltantes o tipos.
3. Confirmar que `android/app/build.gradle` tiene `minSdkVersion` >= 21 (in_app_purchase ya no soporta versiones menores). Si es menor, subirlo a 21 y reportarlo.
4. NO modificar `AndroidManifest.xml`.
5. Confirmar que `AdsConfig.dart`, `AdsService.dart`, `BannerAdWidget`, `AppAdShell` (fuera de los cambios del Paso 6) y `ads_provider.dart` (fuera del cambio del Paso 5) quedan sin alterar.
6. Reportar al usuario: lista de archivos creados, lista de archivos modificados con un resumen de cada cambio, y el resultado de `flutter analyze`.
