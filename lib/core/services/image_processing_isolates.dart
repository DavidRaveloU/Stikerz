// lib/core/services/image_processing_isolates.dart

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

/// Parámetros para procesar una imagen estática hasta PNG 512x512.
class StaticStickerProcessParams {
  final Uint8List imageBytes;
  final double normalizedCropX;
  final double normalizedCropY;
  final double normalizedCropWidth;
  final double normalizedCropHeight;
  final bool useCircularMask;
  final List<ui.Offset>? freeFormPoints;
  final bool smartSubjectMode;

  StaticStickerProcessParams({
    required this.imageBytes,
    required this.normalizedCropX,
    required this.normalizedCropY,
    required this.normalizedCropWidth,
    required this.normalizedCropHeight,
    required this.useCircularMask,
    required this.freeFormPoints,
    required this.smartSubjectMode,
  });
}

/// Parámetros para el procesamiento free-form en isolate.
class FreeFormMaskParams {
  final Uint8List imageBytes;
  final List<ui.Offset> points;
  final int imageWidth;
  final int imageHeight;

  FreeFormMaskParams({
    required this.imageBytes,
    required this.points,
    required this.imageWidth,
    required this.imageHeight,
  });
}

/// Decodifica dimensiones en isolate y devuelve aspecto (width/height).
Future<double> extractImageAspectInIsolate(Uint8List imageBytes) async {
  final decoded = img.decodeImage(imageBytes);
  if (decoded == null || decoded.height == 0) {
    throw Exception('Failed to decode image dimensions');
  }
  return decoded.width / decoded.height;
}

/// Aplica máscara free-form y devuelve los bytes de la imagen procesada (PNG).
/// Esta función es top-level para ser usada con compute.
Future<Uint8List> applyFreeFormMaskInIsolate(FreeFormMaskParams params) async {
  final source = img.decodeImage(params.imageBytes);
  if (source == null) throw Exception('Failed to decode image');

  final processed = _applyFreeFormMaskOptimized(source, params.points);
  return Uint8List.fromList(img.encodePng(processed));
}

/// Pipeline completo de procesamiento para sticker estático.
///
/// Devuelve un PNG listo para convertir a WebP animado.
Future<Uint8List> processStaticStickerImageInIsolate(
  StaticStickerProcessParams params,
) async {
  final decoded = img.decodeImage(params.imageBytes);
  if (decoded == null) throw Exception('Failed to decode image');

  final source = _downscaleIfTooLarge(
    decoded,
    maxDimension: params.smartSubjectMode ? 2048 : 2560,
  );

  img.Image processed;
  final points = params.freeFormPoints;

  if (points != null && points.isNotEmpty) {
    processed = _applyFreeFormMaskOptimized(source, points);
  } else {
    processed = _applyCrop(
      source,
      params.normalizedCropX,
      params.normalizedCropY,
      params.normalizedCropWidth,
      params.normalizedCropHeight,
    );
  }

  if (params.smartSubjectMode) {
    // En Smart Cutout eliminamos bordes transparentes para que el sujeto
    // quede centrado y escale como en free-form.
    processed = _trimTransparentBounds(processed, alphaThreshold: 8);
  }

  final square = _makeSquareFast(processed);
  final resized = img.copyResize(
    square,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.average,
  );

  final postProcessed = params.smartSubjectMode
      ? _cleanSmartCutoutAlphaEdges(resized)
      : resized;

  final masked = params.useCircularMask
      ? _applyCircularMask512(postProcessed)
      : postProcessed;

  return Uint8List.fromList(img.encodePng(masked));
}

img.Image _downscaleIfTooLarge(img.Image source, {required int maxDimension}) {
  final longestSide = source.width > source.height
      ? source.width
      : source.height;
  if (longestSide <= maxDimension) return source;

  final scale = maxDimension / longestSide;
  final targetWidth = (source.width * scale).round().clamp(1, source.width);
  final targetHeight = (source.height * scale).round().clamp(1, source.height);

  return img.copyResize(
    source,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.average,
  );
}

/// Optimización: una sola pasada para aplicar máscara y calcular bounding box.
img.Image _applyFreeFormMaskOptimized(
  img.Image source,
  List<ui.Offset> points,
) {
  if (points.isEmpty || points.length < 3) return source;

  // Convertir puntos a coordenadas de píxel
  final pixelPoints = points
      .map((p) => ui.Offset(p.dx * source.width, p.dy * source.height))
      .toList();

  // Crear imagen de salida con canal alfa
  final masked = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  // Inicializar transparente
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      masked.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  // Variables para bounding box
  int minX = source.width;
  int minY = source.height;
  int maxX = 0;
  int maxY = 0;
  bool hasPixel = false;

  // Función auxiliar para verificar punto dentro del polígono
  bool isInside(List<ui.Offset> vertices, double x, double y) {
    bool inside = false;
    final n = vertices.length;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final vi = vertices[i];
      final vj = vertices[j];
      final intersect =
          ((vi.dy > y) != (vj.dy > y)) &&
          (x < (vj.dx - vi.dx) * (y - vi.dy) / (vj.dy - vi.dy) + vi.dx);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  // Recorrer píxeles
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      if (isInside(pixelPoints, x.toDouble(), y.toDouble())) {
        final pixel = source.getPixel(x, y);
        masked.setPixelRgba(
          x,
          y,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
          pixel.a.toInt(),
        );
        // Actualizar bounding box
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
        hasPixel = true;
      }
    }
  }

  if (!hasPixel) return masked; // Sin píxeles opacos

  // Recortar al bounding box
  final bboxW = maxX - minX + 1;
  final bboxH = maxY - minY + 1;
  return img.copyCrop(masked, x: minX, y: minY, width: bboxW, height: bboxH);
}

img.Image _applyCrop(
  img.Image source,
  double normX,
  double normY,
  double normW,
  double normH,
) {
  final x = (normX * source.width).round().clamp(0, source.width - 1);
  final y = (normY * source.height).round().clamp(0, source.height - 1);
  final w = (normW * source.width).round().clamp(1, source.width - x);
  final h = (normH * source.height).round().clamp(1, source.height - y);
  return img.copyCrop(source, x: x, y: y, width: w, height: h);
}

img.Image _trimTransparentBounds(img.Image source, {int alphaThreshold = 8}) {
  int minX = source.width;
  int minY = source.height;
  int maxX = -1;
  int maxY = -1;

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final alpha = source.getPixel(x, y).a.toInt();
      if (alpha > alphaThreshold) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX < minX || maxY < minY) {
    return source;
  }

  final width = maxX - minX + 1;
  final height = maxY - minY + 1;
  return img.copyCrop(source, x: minX, y: minY, width: width, height: height);
}

img.Image _makeSquareFast(img.Image source) {
  final side = source.width > source.height ? source.width : source.height;
  final result = img.Image(width: side, height: side, numChannels: 4);
  img.fill(result, color: img.ColorRgba8(0, 0, 0, 0));

  final offsetX = (side - source.width) ~/ 2;
  final offsetY = (side - source.height) ~/ 2;

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      result.setPixel(offsetX + x, offsetY + y, source.getPixel(x, y));
    }
  }
  return result;
}

img.Image _applyCircularMask512(img.Image source) {
  final centerX = source.width / 2;
  final centerY = source.height / 2;
  final radiusSquared = (source.width / 2) * (source.width / 2);

  final result = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  img.fill(result, color: img.ColorRgba8(0, 0, 0, 0));

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      if ((dx * dx + dy * dy) <= radiusSquared) {
        result.setPixel(x, y, source.getPixel(x, y));
      }
    }
  }

  return result;
}

/// Limpieza de bordes para smart cutout.
///
/// El objetivo es reducir "shimmer" en contornos con alfa muy bajo o
/// semitransparencias inestables tras la conversión PNG -> video -> WebP.
img.Image _cleanSmartCutoutAlphaEdges(img.Image source) {
  final result = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );

  const int alphaCutToTransparent = 72;
  const int alphaSnapToOpaque = 245;

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final p = source.getPixel(x, y);
      final a = p.a.toInt();

      if (a <= alphaCutToTransparent) {
        // Píxeles casi transparentes: volverlos totalmente transparentes
        // y limpiar RGB para evitar halos de color.
        result.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      if (a >= alphaSnapToOpaque) {
        result.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
        continue;
      }

      result.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), a);
    }
  }

  return result;
}
