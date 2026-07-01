import 'package:flutter/widgets.dart';

/// Calcula las dimensiones de caché (`cacheWidth`/`cacheHeight`) para
/// `Image.file`/`Image.asset`, respetando el aspect ratio real del
/// contenido a decodificar.
///
/// IMPORTANTE: nunca calcules ancho y alto de caché por separado con dos
/// llamadas independientes que cada una haga su propio `clamp`. Si el
/// contenido no es cuadrado, es muy fácil que un lado choque contra el
/// límite (`maxPx`) y el otro no, lo que hace que Flutter decodifique
/// el bitmap con una relación de aspecto distinta a la original
/// (imagen "estirada"/deformada). Acá escalamos ambos lados por el
/// mismo factor para evitarlo.
(int, int) cacheDimensionsPx(
  BuildContext context,
  double logicalWidth,
  double logicalHeight, {
  int maxPx = 2048,
  int minPx = 256,
}) {
  final dpr = MediaQuery.of(context).devicePixelRatio;
  double w = logicalWidth * dpr;
  double h = logicalHeight * dpr;

  if (w <= 0 || h <= 0) {
    return (minPx, minPx);
  }

  // Si el lado más grande excede el máximo, escalamos AMBOS lados por
  // el mismo factor para no deformar el aspect ratio decodificado.
  final maxSide = w > h ? w : h;
  if (maxSide > maxPx) {
    final scale = maxPx / maxSide;
    w *= scale;
    h *= scale;
  }

  // Mismo criterio para el mínimo: si el lado más chico queda por
  // debajo del piso, escalamos ambos lados hacia arriba juntos.
  final minSide = w < h ? w : h;
  if (minSide < minPx) {
    final scale = minPx / minSide;
    w *= scale;
    h *= scale;
  }

  return (w.ceil(), h.ceil());
}
