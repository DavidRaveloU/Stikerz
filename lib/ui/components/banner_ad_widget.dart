import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Widget para mostrar Google Mobile Ads Banner
/// 
/// Se debe envolver en un Scaffold para que el banner se muestre correctamente.
/// El banner se coloca al fondo de la pantalla sin tapar otros elementos.
/// 
/// **Políticas AdMob cumplidas:**
/// - El banner NO está oculto
/// - El banner NO es clickeado automáticamente
/// - El banner tiene suficiente espacio alrededor (no comprimido)
class BannerAdWidget extends StatelessWidget {
  final BannerAd? bannerAd;
  final bool isLoaded;

  const BannerAdWidget({
    super.key,
    required this.bannerAd,
    required this.isLoaded,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || bannerAd == null) {
      // Retornar un SizedBox vacío si el ad no está cargado
      // Esto previene que la altura cambie dinámicamente
      return const SizedBox(height: 50);
    }

    return Container(
      alignment: Alignment.center,
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: bannerAd!),
    );
  }
}
