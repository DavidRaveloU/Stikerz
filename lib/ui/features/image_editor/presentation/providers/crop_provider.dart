import 'package:flutter/material.dart';

class CropProvider {
  /// Normaliza un crop para que siempre quede dentro de los límites de la imagen.
  static (Offset, double) normalizeCrop({
    required Offset rawOffset,
    required double rawWidth,
    required double imageAspect,
    double aspectRatio = 1.0,
  }) {
    final safeAspect = imageAspect > 0 ? imageAspect : 1.0;

    double safeWidth = rawWidth.clamp(0.15, 1.0);
    double safeHeight = (safeWidth * safeAspect) / aspectRatio;

    if (safeHeight > 1.0) {
      safeHeight = 1.0;
      safeWidth = (safeHeight * aspectRatio / safeAspect).clamp(0.15, 1.0);
    }

    final maxDx = (1.0 - safeWidth).clamp(0.0, 1.0);
    final maxDy = (1.0 - safeHeight).clamp(0.0, 1.0);

    return (
      Offset(rawOffset.dx.clamp(0.0, maxDx), rawOffset.dy.clamp(0.0, maxDy)),
      safeWidth,
    );
  }

  /// Calcula la altura del crop basada en el ancho, aspect ratio de imagen y aspect ratio objetivo.
  static double calculateCropHeight({
    required double cropWidth,
    required double imageAspect,
    double aspectRatio = 1.0,
  }) {
    return (cropWidth * imageAspect) / aspectRatio;
  }

  /// Calcula el rectángulo de visualización de la imagen dentro de un área dada.
  static Rect calculateImageRect({
    required Size areaSize,
    required double imageAspect,
  }) {
    if (areaSize.width <= 0 || areaSize.height <= 0) return Rect.zero;

    final aspect = imageAspect > 0 ? imageAspect : 1.0;
    final areaAspect = areaSize.width / areaSize.height;

    if (areaAspect > aspect) {
      final h = areaSize.height;
      final w = h * aspect;
      return Rect.fromLTWH((areaSize.width - w) / 2, 0, w, h);
    } else {
      final w = areaSize.width;
      final h = w / aspect;
      return Rect.fromLTWH(0, (areaSize.height - h) / 2, w, h);
    }
  }

  /// Retorna una copia del offset de crop ajustado dentro de los límites válidos.
  static Offset clampOffset({
    required Offset offset,
    required double cropWidth,
    required double cropHeight,
  }) {
    final maxDx = (1.0 - cropWidth).clamp(0.0, 1.0);
    final maxDy = (1.0 - cropHeight).clamp(0.0, 1.0);

    return Offset(offset.dx.clamp(0.0, maxDx), offset.dy.clamp(0.0, maxDy));
  }
}
