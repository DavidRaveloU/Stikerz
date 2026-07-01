import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:image/image.dart' as img;

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
        if (kDebugMode)
          debugPrint('SmartCrop: máscara nula, no se detectó sujeto');
        return null;
      }

      final bytes = await File(inputPath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final imgWidth = decoded.width;
      final imgHeight = decoded.height;

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
        if (kDebugMode) {
          debugPrint(
            'SmartCrop: máscara ${maskWidth}x$maskHeight '
            '(imagen ${imgWidth}x$imgHeight)',
          );
        }
      }

      final output = img.Image(
        width: imgWidth,
        height: imgHeight,
        numChannels: 4,
      );

      for (int y = 0; y < imgHeight; y++) {
        for (int x = 0; x < imgWidth; x++) {
          final maskX = (x * maskWidth / imgWidth).round().clamp(
            0,
            maskWidth - 1,
          );
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

      final pngBytes = img.encodePng(output);
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
