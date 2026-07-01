import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:image/image.dart' as img;

/// Parámetros para aplicar la máscara de segmentación en un isolate.
class _SegmentationMaskParams {
  final Uint8List imageBytes;
  final List<double> confidences;

  _SegmentationMaskParams({
    required this.imageBytes,
    required this.confidences,
  });
}

/// Decodifica la imagen, mezcla la máscara de confianza pixel a pixel y
/// re-codifica a PNG. Función TOP-LEVEL (requisito de `compute`) para que
/// se ejecute en un isolate aparte del principal.
///
/// IMPORTANTE: este es el trabajo que antes corría de forma síncrona
/// dentro de una función `async` en el isolate principal. Aunque la
/// función fuera `async`, los bucles `for` que recorren cada pixel de la
/// imagen NO ceden el control al hilo de UI — lo bloquean por completo
/// mientras corren. Con imágenes grandes eso bloqueaba la UI el tiempo
/// suficiente como para disparar un ANR, y de paso hacía imposible que
/// cualquier gesto (cambiar de modo, volver atrás) se procesara mientras
/// tanto. Al moverlo a un isolate real con `compute`, el hilo de UI queda
/// completamente libre durante todo el procesamiento.
Uint8List? applySegmentationMaskInIsolate(_SegmentationMaskParams params) {
  final decoded = img.decodeImage(params.imageBytes);
  if (decoded == null) return null;

  final imgWidth = decoded.width;
  final imgHeight = decoded.height;
  final confidences = params.confidences;

  int maskWidth;
  int maskHeight;

  if (confidences.length == imgWidth * imgHeight) {
    maskWidth = imgWidth;
    maskHeight = imgHeight;
  } else {
    final aspect = imgWidth / imgHeight;
    maskHeight = (confidences.length / aspect).round().clamp(
      1,
      confidences.length,
    );
    maskWidth = confidences.length ~/ maskHeight;
  }

  final output = img.Image(width: imgWidth, height: imgHeight, numChannels: 4);

  for (int y = 0; y < imgHeight; y++) {
    for (int x = 0; x < imgWidth; x++) {
      final maskX = (x * maskWidth / imgWidth).round().clamp(0, maskWidth - 1);
      final maskY = (y * maskHeight / imgHeight).round().clamp(
        0,
        maskHeight - 1,
      );
      final confidence = confidences[maskY * maskWidth + maskX];

      final pixel = decoded.getPixel(x, y);
      final alpha = (confidence * 255).round().clamp(0, 255);

      output.setPixelRgba(
        x,
        y,
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
        alpha,
      );
    }
  }

  return Uint8List.fromList(img.encodePng(output));
}

/// Servicio que usa ML Kit Subject Segmentation para eliminar el fondo de una
/// imagen y devolver un PNG con transparencia. Funciona 100% on-device,
/// sin internet y sin límites de uso.
class SmartCropService {
  /// Elimina el fondo de [inputPath] y guarda el resultado en [outputPath] como PNG.
  /// Devuelve [outputPath] si tuvo éxito, o null si falló.
  static Future<String?> removeBackground({
    required String inputPath,
    required String outputPath,
  }) async {
    SubjectSegmenter? segmenter;
    try {
      final options = SubjectSegmenterOptions(
        enableForegroundBitmap: false,
        enableForegroundConfidenceMask: true,
        enableMultipleSubjects: SubjectResultOptions(
          enableConfidenceMask: false,
          enableSubjectBitmap: false,
        ),
      );
      segmenter = SubjectSegmenter(options: options);

      final inputImage = InputImage.fromFilePath(inputPath);
      final result = await segmenter.processImage(inputImage);

      final confidences = result.foregroundConfidenceMask;
      if (confidences == null || confidences.isEmpty) {
        if (kDebugMode) {
          debugPrint('SmartCrop: máscara nula, no se detectó sujeto');
        }
        return null;
      }

      final bytes = await File(inputPath).readAsBytes();

      // Todo el trabajo pesado de CPU (decode + mezcla de máscara +
      // encode PNG) corre en un isolate aparte, así el hilo de UI nunca
      // se bloquea mientras esto procesa.
      final pngBytes = await compute(
        applySegmentationMaskInIsolate,
        _SegmentationMaskParams(imageBytes: bytes, confidences: confidences),
      );

      if (pngBytes == null) return null;

      await File(outputPath).writeAsBytes(pngBytes);

      if (kDebugMode) debugPrint('✓ SmartCrop completado → $outputPath');
      return outputPath;
    } catch (e) {
      if (kDebugMode) debugPrint('✗ SmartCrop error: $e');
      return null;
    } finally {
      await segmenter?.close();
    }
  }

  /// Pre-procesa la imagen: elimina el fondo y guarda el PNG resultante en
  /// [outputPath]. Devuelve [outputPath] si tuvo éxito.
  ///
  /// A diferencia de [removeBackground], este método está diseñado para
  /// ser llamado desde la UI (crop_toolbar) para pre-visualizar el resultado.
  static Future<String?> preprocessSmartCrop({
    required String inputPath,
    required String outputPath,
  }) async {
    return removeBackground(inputPath: inputPath, outputPath: outputPath);
  }
}
