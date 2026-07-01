// lib/core/services/static_sticker_generation_service.dart

import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stikerz/core/services/image_processing_isolates.dart';
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
    bool smartSubjectMode = false,
    double rotationDegrees = 0.0,
    void Function(String status, double? progress)? onStatus,
  }) async {
    onStatus?.call('Processing image...', 0.05);

    await _validateWebpRuntime();

    final outputDir = await _ensureOutputDir(packId);
    final baseName =
        'slot_${slotIndex}_${DateTime.now().millisecondsSinceEpoch}';

    final inputBytes = await File(inputImagePath).readAsBytes();

    onStatus?.call('Processing pixels in background...', 0.2);

    late final List<int> pngBytes;
    try {
      final processedBytes = await compute(
        processStaticStickerImageInIsolate,
        StaticStickerProcessParams(
          imageBytes: inputBytes,
          normalizedCropX: normalizedCropX,
          normalizedCropY: normalizedCropY,
          normalizedCropWidth: normalizedCropWidth,
          normalizedCropHeight: normalizedCropHeight,
          useCircularMask: useCircularMask,
          freeFormPoints: freeFormPoints,
          smartSubjectMode: smartSubjectMode,
        ),
      );
      pngBytes = processedBytes;
    } catch (e) {
      return StickerGenerationResult(
        success: false,
        error: 'Image processing failed: $e',
      );
    }

    onStatus?.call('Preparing for conversion...', 0.7);

    final tempPngPath =
        '${outputDir.path}${Platform.pathSeparator}${baseName}_temp.png';
    final tempPngFile = File(tempPngPath);

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

  static Future<String?> _createFakeVideo({
    required String pngPath,
    required String outputDir,
    required String baseName,
  }) async {
    // igual que antes
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

    try {
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        final file = File(videoPath);
        if (await file.exists()) return videoPath;
      }
      // Fallback...
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
      final fallbackSession = await FFmpegKit.execute(fallbackCommand);
      final fallbackReturnCode = await fallbackSession.getReturnCode();
      if (ReturnCode.isSuccess(fallbackReturnCode)) {
        final file = File(fallbackVideoPath);
        if (await file.exists()) return fallbackVideoPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
