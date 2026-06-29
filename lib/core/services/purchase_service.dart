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