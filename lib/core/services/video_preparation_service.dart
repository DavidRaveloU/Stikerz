import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum VideoPreparationPhase { preparing, downloading, retrying, completed }

class VideoPreparationStatus {
  final VideoPreparationPhase phase;
  final int attempt;
  final int maxAttempts;
  final Duration elapsed;
  final double? progress;
  final int? totalBytes;

  const VideoPreparationStatus({
    required this.phase,
    required this.attempt,
    required this.maxAttempts,
    required this.elapsed,
    this.progress,
    this.totalBytes,
  });
}

typedef VideoPreparationStatusCallback =
    void Function(VideoPreparationStatus status);

class VideoPreparationException implements Exception {
  final String code;
  final String message;

  const VideoPreparationException(this.message, {this.code = 'unknown'});

  const VideoPreparationException.networkInterrupted([String message = ''])
    : code = 'network_interrupted',
      message = message;

  const VideoPreparationException.downloadFailed([String message = ''])
    : code = 'download_failed',
      message = message;

  @override
  String toString() => message;
}

class VideoPreparationService {
  static const int _maxAttempts = 3;
  static const Duration _idleTimeout = Duration(seconds: 12);

  static bool isRemoteVideoSource(String path) {
    final uri = Uri.tryParse(path.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static Future<String> prepareVideoSource(
    String videoPath, {
    VideoPreparationStatusCallback? onStatus,
    http.Client? client,
    Directory? tempDirectory,
  }) async {
    if (!isRemoteVideoSource(videoPath)) {
      return videoPath;
    }

    final sourceUri = Uri.parse(videoPath.trim());
    final tempDir = tempDirectory ?? await getTemporaryDirectory();
    final fileName = _buildTempFileName(sourceUri);
    final outputPath = '${tempDir.path}${Platform.pathSeparator}$fileName';
    final httpClient = client ?? http.Client();
    final ownsClient = client == null;

    try {
      for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
        final attemptStartedAt = DateTime.now();
        onStatus?.call(
          VideoPreparationStatus(
            phase: attempt == 1
                ? VideoPreparationPhase.preparing
                : VideoPreparationPhase.retrying,
            attempt: attempt,
            maxAttempts: _maxAttempts,
            elapsed: Duration.zero,
          ),
        );

        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          await outputFile.delete();
        }

        try {
          final request = http.Request('GET', sourceUri);
          final response = await httpClient.send(request);

          if (response.statusCode < 200 || response.statusCode >= 300) {
            final retryableStatus =
                response.statusCode >= 500 || response.statusCode == 429;

            if (retryableStatus && attempt < _maxAttempts) {
              throw TimeoutException(
                'Retryable server response ${response.statusCode}.',
              );
            }

            throw VideoPreparationException.downloadFailed(
              'Unexpected response ${response.statusCode} while downloading video.',
            );
          }

          final sink = outputFile.openWrite();
          var receivedBytes = 0;
          final totalBytes = response.contentLength;

          try {
            final monitoredStream = response.stream.timeout(
              _idleTimeout,
              onTimeout: (sink) {
                sink.addError(
                  TimeoutException(
                    'No data received for ${_idleTimeout.inSeconds} seconds.',
                  ),
                );
              },
            );

            await for (final chunk in monitoredStream) {
              sink.add(chunk);
              receivedBytes += chunk.length;

              onStatus?.call(
                VideoPreparationStatus(
                  phase: VideoPreparationPhase.downloading,
                  attempt: attempt,
                  maxAttempts: _maxAttempts,
                  elapsed: DateTime.now().difference(attemptStartedAt),
                  progress: totalBytes != null && totalBytes > 0
                      ? (receivedBytes / totalBytes).clamp(0.0, 1.0)
                      : null,
                  totalBytes: totalBytes,
                ),
              );
            }
          } finally {
            await sink.flush();
            await sink.close();
          }

          onStatus?.call(
            VideoPreparationStatus(
              phase: VideoPreparationPhase.completed,
              attempt: attempt,
              maxAttempts: _maxAttempts,
              elapsed: DateTime.now().difference(attemptStartedAt),
              progress: 1.0,
              totalBytes: totalBytes,
            ),
          );

          return outputPath;
        } catch (error) {
          final outputFile = File(outputPath);
          if (await outputFile.exists()) {
            await outputFile.delete();
          }

          final isTransient =
              error is SocketException ||
              error is http.ClientException ||
              error is TimeoutException ||
              error.toString().contains(
                'Connection closed while receiving data',
              );

          if (!isTransient || attempt == _maxAttempts) {
            if (error is VideoPreparationException) rethrow;

            if (isTransient) {
              throw VideoPreparationException.networkInterrupted(
                'The network connection ended while downloading the video.',
              );
            }

            throw VideoPreparationException.downloadFailed(
              'Failed to prepare video source.',
            );
          }

          onStatus?.call(
            VideoPreparationStatus(
              phase: VideoPreparationPhase.retrying,
              attempt: attempt,
              maxAttempts: _maxAttempts,
              elapsed: DateTime.now().difference(attemptStartedAt),
            ),
          );

          await Future.delayed(const Duration(seconds: 8));
        }
      }

      throw VideoPreparationException.downloadFailed(
        'Failed to prepare video source.',
      );
    } catch (error) {
      if (error is VideoPreparationException) rethrow;

      throw VideoPreparationException.downloadFailed(
        'Failed to prepare video source.',
      );
    } finally {
      if (ownsClient) {
        httpClient.close();
      }
    }
  }

  static String _buildTempFileName(Uri sourceUri) {
    final rawName = sourceUri.pathSegments.isNotEmpty
        ? sourceUri.pathSegments.last
        : '';
    final dotIndex = rawName.lastIndexOf('.');
    final extension = dotIndex > 0 && dotIndex < rawName.length - 1
        ? rawName.substring(dotIndex)
        : '.mp4';
    final safeExtension = extension.length <= 8 ? extension : '.mp4';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'stikerz_video_$timestamp$safeExtension';
  }
}
