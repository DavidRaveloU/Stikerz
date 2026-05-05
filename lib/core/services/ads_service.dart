import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ads_config.dart';

/// Servicio centralizado para manejar Google Mobile Ads (Banner + Interstitial)
/// 
/// Cumplen con políticas de AdMob:
/// - No clickear ads automáticamente
/// - No ocultar ads
/// - No usar IDs de test en producción
/// - Respetar carga y destrucción de ads
class AdsService {
  static String get _bannerAdUnitId => AdsConfig.bannerAdUnitId;
  static String get _interstitialAdUnitId => AdsConfig.interstitialAdUnitId;
  static const Duration _interstitialCooldown = Duration(seconds: 45);

  // Singletons
  static final AdsService _instance = AdsService._internal();

  factory AdsService() {
    return _instance;
  }

  AdsService._internal();

  // Estado
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  DateTime? _lastInterstitialShownAt;

  // Getters
  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;

  /// Inicializar Google Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('MobileAds inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando MobileAds: $e');
    }
  }

  /// Cargar banner ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✓ Banner Ad cargado');
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('✗ Banner Ad falló: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
        },
        onAdOpened: (ad) {
          debugPrint('→ Banner Ad abierto (user clicked)');
        },
        onAdClosed: (ad) {
          debugPrint('← Banner Ad cerrado');
        },
        onAdClicked: (ad) {
          debugPrint('🖱️ Banner Ad clickeado');
        },
      ),
    );

    _bannerAd!.load();
  }

  /// Cargar interstitial ad (solo carga, no muestra automáticamente)
  void loadInterstitialAd({VoidCallback? onLoaded}) {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✓ Interstitial Ad cargado');
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('✗ Interstitial Ad falló: ${error.message}');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Mostrar interstitial ad (con validaciones de AdMob)
  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    final now = DateTime.now();
    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null && now.difference(lastShown) < _interstitialCooldown) {
      debugPrint('ℹ️ Interstitial en cooldown, no se muestra todavía');
      onDismissed?.call();
      return;
    }

    if (!_isInterstitialLoaded || _interstitialAd == null) {
      debugPrint('⚠️  Interstitial Ad no está listo. Cargando...');
      loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('📺 Interstitial Ad mostrado');
          _lastInterstitialShownAt = DateTime.now();
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('👈 Interstitial Ad cerrado por usuario');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
          // Cargar el siguiente ad para futuras ocasiones
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('✗ Error mostrando Interstitial: ${error.message}');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          onDismissed?.call();
        },
        onAdClicked: (ad) {
          debugPrint('🖱️ Interstitial Ad clickeado');
        },
      );

      await _interstitialAd!.show();
    } catch (e) {
      debugPrint('❌ Excepción mostrando Interstitial: $e');
      onDismissed?.call();
    }
  }

  /// Limpiar recursos
  Future<void> dispose() async {
    await _bannerAd?.dispose();
    await _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
  }
}
