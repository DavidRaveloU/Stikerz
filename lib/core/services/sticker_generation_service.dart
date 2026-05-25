import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class StickerGenerationException implements Exception {
  final String message;
  const StickerGenerationException(this.message);

  @override
  String toString() => message;
}

class StickerGenerationResult {
  final bool success;
  final String? path;
  final bool usedStrategy;
  final String? error;
  // Size in bytes when generation failed due to exceeding allowed size.
  final int? failedSize;

  const StickerGenerationResult({
    required this.success,
    this.path,
    this.usedStrategy = false,
    this.error,
    this.failedSize,
  });
}

enum StickerStrategy {
  none,
  lightBlur,
  reduceFps,
  increaseTransparency,
  blurAndReduceFps,
}

class StickerGenerationRequest {
  final String inputPath;
  final int packId;
  final int slotIndex;
  final double startSec;
  final double durationSec;
  final double cropX;
  final double cropY;
  final double cropWidth;
  final double cropHeight;
  final bool requiresInternet;
  final String aspectRatioLabel;

  const StickerGenerationRequest({
    required this.inputPath,
    required this.packId,
    required this.slotIndex,
    required this.startSec,
    required this.durationSec,
    required this.cropX,
    required this.cropY,
    required this.cropWidth,
    required this.cropHeight,
    required this.requiresInternet,
    required this.aspectRatioLabel,
  });
}

class StickerGenerationService {
  static const int _maxBytes = 500 * 1024;
  static bool _checkedWebpRuntime = false;

  static Future<StickerGenerationResult> generate(
    StickerGenerationRequest req, {
    String strategy = 'none',
    void Function(String status, double? progress)? onStatus,
  }) async {
    final strategyMode = _parseStrategy(strategy);
    onStatus?.call('Preparing video...', 0.05);

    await _validateWebpRuntime();

    if (req.requiresInternet && !await _hasConnection()) {
      throw const StickerGenerationException(
        'A stable internet connection is required to create stickers from online sources.',
      );
    }

    final outputDir = await _ensureOutputDir(req.packId);
    final baseName =
        'slot_${req.slotIndex}_${DateTime.now().millisecondsSinceEpoch}';
    final finalPath =
        '${outputDir.path}${Platform.pathSeparator}$baseName.webp';

    final normalized = _normalizeCrop(req);
    final profiles = _buildProfiles(strategyMode);

    final tempFiles = <File>[];
    var lostConnection = false;
    StreamSubscription<List<ConnectivityResult>>? sub;

    if (req.requiresInternet) {
      sub = Connectivity().onConnectivityChanged.listen((results) {
        if (_isOffline(results)) {
          lostConnection = true;
          FFmpegKit.cancel();
        }
      });
    }

    try {
      onStatus?.call('Starting conversion...', 0.12);
      String? lastFailure;
      int? lastFailedSize;

      for (var i = 0; i < profiles.length; i++) {
        final progress = 0.15 + (0.75 * (i / profiles.length));

        onStatus?.call(
          'Generating sticker (attempt ${i + 1}/${profiles.length})...',
          progress,
        );

        if (req.requiresInternet && !await _hasConnection()) {
          throw const StickerGenerationException(
            'Internet connection lost during sticker creation.',
          );
        }

        final profile = profiles[i];

        final attemptPath =
            '${outputDir.path}${Platform.pathSeparator}${baseName}_try_$i.webp';
        final attemptFile = File(attemptPath);
        tempFiles.add(attemptFile);

        final filters = _buildFilter(
          normalized,
          profile.fps,
          req.aspectRatioLabel,
          strategyMode,
        );

        final command =
            '-y '
            '-ss ${req.startSec.toStringAsFixed(3)} '
            '-t ${req.durationSec.toStringAsFixed(3)} '
            '-i ${_q(req.inputPath)} '
            '-an '
            '-vf $filters '
            '-c:v libwebp '
            '-loop 0 '
            '-compression_level 9 '
            '-q:v ${profile.quality} '
            '${_q(attemptPath)}';

        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        final logs = (await session.getAllLogsAsString()) ?? '';
        final failStack = (await session.getFailStackTrace()) ?? '';

        if (lostConnection) {
          throw const StickerGenerationException(
            'Internet connection lost during sticker creation.',
          );
        }

        if (!ReturnCode.isSuccess(returnCode)) {
          lastFailure = _summarizeFailure(logs, failStack);
          continue;
        }

        if (!await attemptFile.exists()) {
          lastFailure =
              'FFmpeg finished without error but did not produce an output file.';
          continue;
        }

        final bytes = await attemptFile.length();

        if (bytes <= _maxBytes) {
          onStatus?.call('Saving sticker...', 0.95);
          await attemptFile.rename(finalPath);
          await _createThumbnail(finalPath);
          onStatus?.call('Sticker created.', 1.0);

          return StickerGenerationResult(
            success: true,
            path: finalPath,
            usedStrategy: strategyMode != StickerStrategy.none,
          );
        }
        // Keep the latest oversized result for better diagnostics.
        lastFailedSize = bytes;
      }

      return StickerGenerationResult(
        success: false,
        usedStrategy: strategyMode != StickerStrategy.none,
        error: lastFailure,
        failedSize: lastFailedSize,
      );
    } finally {
      await sub?.cancel();
      for (final file in tempFiles) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  static String _buildFilter(
    _NormalizedCrop crop,
    int fps,
    String aspectLabel,
    StickerStrategy strategy,
  ) {
    final x = crop.x.toStringAsFixed(6);
    final y = crop.y.toStringAsFixed(6);
    final w = crop.width.toStringAsFixed(6);
    final h = crop.height.toStringAsFixed(6);

    final scaleTarget = _scaleForAspect(aspectLabel, 512);

    var filter =
        'crop=iw*$w:ih*$h:iw*$x:ih*$y:exact=1,'
        'fps=$fps,'
        'scale=$scaleTarget:flags=lanczos,'
        'format=rgba,'
        'pad=512:512:(ow-iw)/2:(oh-ih)/2:color=0x00000000';

    switch (strategy) {
      case StickerStrategy.lightBlur:
        filter += ',boxblur=1:1';
        break;

      case StickerStrategy.reduceFps:
        break;

      case StickerStrategy.blurAndReduceFps:
        filter += ',boxblur=1:1';
        break;

      case StickerStrategy.increaseTransparency:
        filter =
            'crop=iw*$w:ih*$h:iw*$x:ih*$y:exact=1,'
            'fps=$fps,'
            'scale=448:448:flags=lanczos,'
            'format=rgba,'
            'pad=512:512:(ow-iw)/2:(oh-ih)/2:color=0x00000000';
        break;

      case StickerStrategy.none:
        break;
    }

    return filter;
  }

  static List<_EncodeProfile> _buildProfiles(StickerStrategy strategy) {
    final fps = switch (strategy) {
      StickerStrategy.reduceFps => 10,
      StickerStrategy.blurAndReduceFps => 10,
      StickerStrategy.increaseTransparency => 12,
      _ => 12,
    };

    return [
      _EncodeProfile(fps: fps, quality: 16),
      _EncodeProfile(fps: fps, quality: 12),
      _EncodeProfile(fps: fps, quality: 8),
      _EncodeProfile(fps: fps, quality: 4),
      _EncodeProfile(fps: fps, quality: 2),
    ];
  }

  static StickerStrategy _parseStrategy(String raw) {
    switch (raw) {
      case 'lightBlur':
        return StickerStrategy.lightBlur;
      case 'reduceFps':
        return StickerStrategy.reduceFps;
      case 'increaseTransparency':
        return StickerStrategy.increaseTransparency;
      case 'blurAndReduceFps':
        return StickerStrategy.blurAndReduceFps;
      default:
        return StickerStrategy.none;
    }
  }

  static Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return !_isOffline(results);
  }

  static bool _isOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.length == 1 && results.first == ConnectivityResult.none;
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

  static _NormalizedCrop _normalizeCrop(StickerGenerationRequest req) {
    final w = req.cropWidth.clamp(0.05, 1.0).toDouble();
    final h = req.cropHeight.clamp(0.05, 1.0).toDouble();
    final x = req.cropX.clamp(0.0, 1.0 - w);
    final y = req.cropY.clamp(0.0, 1.0 - h);

    return _NormalizedCrop(
      x: x.toDouble(),
      y: y.toDouble(),
      width: w,
      height: h,
    );
  }

  static String _scaleForAspect(String aspectLabel, int baseSize) {
    switch (aspectLabel) {
      case '1:1':
        return '$baseSize:$baseSize';
      case '4:3':
        return '$baseSize:${((baseSize * 3) / 4).round()}';
      case '16:9':
        return '$baseSize:${((baseSize * 9) / 16).round()}';
      default:
        return '$baseSize:$baseSize';
    }
  }

  static String _q(String path) => '"${path.replaceAll('"', r'\"')}"';

  static Future<void> _createThumbnail(String webpPath) async {
    final command =
        '-y -i ${_q(webpPath)} -frames:v 1 -vf scale=120:120 ${_q('$webpPath.thumb.jpg')}';
    await FFmpegKit.execute(command);
  }

  static Future<void> _validateWebpRuntime() async {
    if (_checkedWebpRuntime) return;

    final session = await FFmpegKit.execute('-hide_banner -encoders');
    final output = (await session.getOutput()) ?? '';

    if (!output.contains('libwebp')) {
      throw const StickerGenerationException('FFmpeg does not support WebP.');
    }

    _checkedWebpRuntime = true;
  }

  static String _summarizeFailure(String logs, String failStack) {
    final source = failStack.isNotEmpty ? failStack : logs;
    final lines = source.split('\n').take(6).join(' | ');
    return lines;
  }
}

class _EncodeProfile {
  final int fps;
  final int quality;
  const _EncodeProfile({required this.fps, required this.quality});
}

class _NormalizedCrop {
  final double x;
  final double y;
  final double width;
  final double height;

  const _NormalizedCrop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
