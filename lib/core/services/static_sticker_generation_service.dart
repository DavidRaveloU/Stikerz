import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:stikerz/core/services/sticker_generation_service.dart';

class StaticStickerGenerationService {
  static bool _checkedWebpRuntime = false;

  static Future<StickerGenerationResult> generate({
    required String inputImagePath,
    required int packId,
    required int slotIndex,
    required double normalizedCropX,
    required double normalizedCropY,
    required double normalizedCropWidth,
    required double normalizedCropHeight,
    required bool useCircularMask,
    required List<Offset>? freeFormPoints,
    double rotationDegrees = 0.0,
    void Function(String status, double? progress)? onStatus,
  }) async {
    onStatus?.call('Processing image...', 0.05);

    await _validateWebpRuntime();

    final outputDir = await _ensureOutputDir(packId);
    final baseName =
        'slot_${slotIndex}_${DateTime.now().millisecondsSinceEpoch}';

    final inputBytes = await File(inputImagePath).readAsBytes();
    final original = img.decodeImage(inputBytes);
    if (original == null) {
      return const StickerGenerationResult(
        success: false,
        error: 'Could not decode image.',
      );
    }

    img.Image processed;

    if (freeFormPoints != null && freeFormPoints.isNotEmpty) {
      onStatus?.call('Applying free-form mask...', 0.2);
      // _applyFreeFormMask ya devuelve la imagen recortada, centrada y lista
      processed = _applyFreeFormMask(original, freeFormPoints);
    } else {
      onStatus?.call('Applying crop...', 0.2);
      var cropped = _applyCrop(
        original,
        normalizedCropX,
        normalizedCropY,
        normalizedCropWidth,
        normalizedCropHeight,
      );

      if (cropped == null) {
        return const StickerGenerationResult(
          success: false,
          error: 'Could not crop image.',
        );
      }
      processed = cropped;
    }

    onStatus?.call('Resizing to sticker format...', 0.4);

    final square = _makeSquare(processed);
    final resized = img.copyResize(
      square,
      width: 512,
      height: 512,
      interpolation: img.Interpolation.average,
    );

    onStatus?.call('Applying circular mask...', 0.6);

    img.Image masked = resized;
    if (useCircularMask) {
      masked = _applyCircularMask(resized);
    }

    onStatus?.call('Preparing for conversion...', 0.7);

    final tempPngPath =
        '${outputDir.path}${Platform.pathSeparator}${baseName}_temp.png';
    final tempPngFile = File(tempPngPath);

    final pngBytes = img.encodePng(masked);
    await tempPngFile.writeAsBytes(pngBytes);

    onStatus?.call('Creating fake video...', 0.75);

    final fakeVideoPath = await _createFakeVideo(
      pngPath: tempPngPath,
      outputDir: outputDir.path,
      baseName: baseName,
    );

    if (fakeVideoPath == null) {
      if (await tempPngFile.exists()) {
        await tempPngFile.delete();
      }
      return const StickerGenerationResult(
        success: false,
        error: 'Failed to create fake video.',
      );
    }

    onStatus?.call('Generating animated WebP...', 0.8);

    final result = await StickerGenerationService.generate(
      StickerGenerationRequest(
        inputPath: fakeVideoPath,
        packId: packId,
        slotIndex: slotIndex,
        startSec: 0.0,
        durationSec: 1.0,
        cropX: 0.0,
        cropY: 0.0,
        cropWidth: 1.0,
        cropHeight: 1.0,
        requiresInternet: false,
        aspectRatioLabel: '1:1',
      ),
      onStatus: (status, progress) {
        if (onStatus != null) {
          final adjustedProgress = 0.8 + (progress ?? 0.0) * 0.2;
          onStatus('Creating animated sticker...', adjustedProgress);
        }
      },
    );

    if (await tempPngFile.exists()) {
      await tempPngFile.delete();
    }

    final fakeVideoFile = File(fakeVideoPath);
    if (await fakeVideoFile.exists()) {
      await fakeVideoFile.delete();
    }

    if (result.success && result.path != null) {
      onStatus?.call('Sticker created.', 1.0);
    } else if (!result.success) {
      onStatus?.call('Failed to create sticker.', 1.0);
    }

    return result;
  }

  static bool _isPointInsidePolygon(
    List<ui.Offset> vertices,
    double x,
    double y,
  ) {
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

  /// Aplica la máscara free-form, calcula el bounding box de los píxeles
  /// opacos resultantes, recorta a ese bounding box y devuelve esa imagen.
  /// El pipeline posterior (_makeSquare → copyResize 512×512) se encarga de
  /// centrarla y escalarla al máximo respetando la relación de aspecto.
  static img.Image _applyFreeFormMask(img.Image source, List<Offset> points) {
    if (points.isEmpty || points.length < 3) return source;

    final pixelPoints = points.map((p) {
      return ui.Offset(p.dx * source.width, p.dy * source.height);
    }).toList();

    // ── 1. Aplicar máscara sobre imagen de tamaño original ──
    final masked = img.Image(
      width: source.width,
      height: source.height,
      numChannels: 4,
    );

    // Inicializar todo como transparente
    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        masked.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }

    // Copiar píxeles dentro del polígono
    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        if (_isPointInsidePolygon(pixelPoints, x.toDouble(), y.toDouble())) {
          final pixel = source.getPixel(x, y);
          masked.setPixelRgba(
            x,
            y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }

    // ── 2. Calcular bounding box de los píxeles opacos ──
    int minX = source.width;
    int minY = source.height;
    int maxX = 0;
    int maxY = 0;

    for (var y = 0; y < masked.height; y++) {
      for (var x = 0; x < masked.width; x++) {
        final pixel = masked.getPixel(x, y);
        if (pixel.a.toInt() > 0) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    // Si no hay ningún píxel opaco, devolver la imagen enmascarada tal cual
    if (minX > maxX || minY > maxY) return masked;

    final bboxW = maxX - minX + 1;
    final bboxH = maxY - minY + 1;

    // ── 3. Recortar al bounding box ──
    // Esto es lo que _makeSquare + copyResize recibirán:
    // una imagen ajustada al contenido real, que luego se centra y escala.
    return img.copyCrop(masked, x: minX, y: minY, width: bboxW, height: bboxH);
  }

  static Future<String?> _createFakeVideo({
    required String pngPath,
    required String outputDir,
    required String baseName,
  }) async {
    final videoPath = '$outputDir${Platform.pathSeparator}${baseName}_fake.mov';

    final command =
        '-y '
        '-loop 1 '
        '-i ${_q(pngPath)} '
        '-c:v png '
        '-pix_fmt rgba '
        '-t 1 '
        '-vf "scale=512:512:flags=lanczos" '
        '${_q(videoPath)}';

    if (kDebugMode) {
      debugPrint('[StaticSticker] Creating fake video: $command');
    }

    try {
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final file = File(videoPath);
        if (await file.exists()) {
          return videoPath;
        }
      }

      // Fallback: MP4 con alfa
      final fallbackVideoPath =
          '$outputDir${Platform.pathSeparator}${baseName}_fake.mp4';
      final fallbackCommand =
          '-y '
          '-loop 1 '
          '-i ${_q(pngPath)} '
          '-c:v libx264 '
          '-pix_fmt yuva420p '
          '-t 1 '
          '-vf "scale=512:512:flags=lanczos,format=rgba" '
          '${_q(fallbackVideoPath)}';

      if (kDebugMode) {
        debugPrint('[StaticSticker] Fallback video command: $fallbackCommand');
      }

      final fallbackSession = await FFmpegKit.execute(fallbackCommand);
      final fallbackReturnCode = await fallbackSession.getReturnCode();

      if (ReturnCode.isSuccess(fallbackReturnCode)) {
        final file = File(fallbackVideoPath);
        if (await file.exists()) {
          return fallbackVideoPath;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StaticSticker] Error creating fake video: $e');
      }
      return null;
    }
  }

  static img.Image? _applyCrop(
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

  static img.Image _makeSquare(img.Image source) {
    final side = math.max(source.width, source.height);
    final result = img.Image(width: side, height: side, numChannels: 4);

    for (var y = 0; y < side; y++) {
      for (var x = 0; x < side; x++) {
        result.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }

    final offsetX = (side - source.width) ~/ 2;
    final offsetY = (side - source.height) ~/ 2;

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final pixel = source.getPixel(x, y);
        if (source.hasAlpha) {
          result.setPixelRgba(
            offsetX + x,
            offsetY + y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            pixel.a.toInt(),
          );
        } else {
          result.setPixelRgba(
            offsetX + x,
            offsetY + y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            255,
          );
        }
      }
    }
    return result;
  }

  static img.Image _applyCircularMask(img.Image source) {
    final centerX = source.width / 2;
    final centerY = source.height / 2;
    final radius = math.min(centerX, centerY);

    final result = img.Image(
      width: source.width,
      height: source.height,
      numChannels: 4,
    );

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        result.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        if ((dx * dx + dy * dy) <= radius * radius) {
          final pixel = source.getPixel(x, y);
          if (source.hasAlpha) {
            result.setPixelRgba(
              x,
              y,
              pixel.r.toInt(),
              pixel.g.toInt(),
              pixel.b.toInt(),
              pixel.a.toInt(),
            );
          } else {
            result.setPixelRgba(
              x,
              y,
              pixel.r.toInt(),
              pixel.g.toInt(),
              pixel.b.toInt(),
              255,
            );
          }
        }
      }
    }

    return result;
  }

  static Future<Directory> _ensureOutputDir(int packId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${docs.path}${Platform.pathSeparator}stickers${Platform.pathSeparator}pack_$packId',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static String _q(String path) => '"${path.replaceAll('"', r'\"')}"';

  static Future<void> _validateWebpRuntime() async {
    if (_checkedWebpRuntime) return;

    final session = await FFmpegKit.execute('-hide_banner -encoders');
    final output = (await session.getOutput()) ?? '';

    if (!output.contains('libwebp')) {
      throw const StickerGenerationException('FFmpeg does not support WebP.');
    }

    _checkedWebpRuntime = true;
  }
}
