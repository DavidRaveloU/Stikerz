import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stikerz/core/providers/share_provider.dart';

import 'snaptik_service.dart';
import 'ssstik_service.dart';

class TikTokResult {
  final String? videoUrl;
  final String? error;

  const TikTokResult({this.videoUrl, this.error});

  bool get success => videoUrl != null && error == null;
  bool get hasError => error != null;
}

class TikTokService {
  static const String _apiUrl = 'https://www.tikwm.com/api/';

  // Error tokens returned to the UI; these are mapped to localized
  // user-facing messages elsewhere in the app.
  static const String errExternal = 'err_external_service';
  static const String errTimeout = 'err_timeout';
  static const String errInvalidResponse = 'err_invalid_response';
  static const String errNotVideo = 'err_not_a_video';
  static const String errVideoNotPublic = 'err_video_not_public';

  // --- URL extraction & validation ---

  static String? extractFirstTikTokUrl(String rawInput) {
    if (rawInput.trim().isEmpty) return null;

    final regex = RegExp(
      r'https?://(?:www\.)?(?:m\.)?(?:vm\.|vt\.)?tiktok\.com/[^\s]+',
      caseSensitive: false,
    );

    final match = regex.firstMatch(rawInput);
    if (match == null) return null;

    return _stripTrailingPunctuation(match.group(0)!);
  }

  static String _stripTrailingPunctuation(String value) {
    var out = value.trim();
    while (out.isNotEmpty) {
      final c = out[out.length - 1];
      if ('.!,?)]'.contains(c)) {
        out = out.substring(0, out.length - 1);
      } else {
        break;
      }
    }
    return out;
  }

  static bool isValidTikTokUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return false;
    final host = uri.host.toLowerCase();
    return host.contains('tiktok.com');
  }

  // ── Connectivity helpers ─────────────────────────────────────────────────

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  // ── Main resolver entrypoint ───────────────────────────────────────────

  static Future<TikTokResult> getVideoUrl(String tiktokUrl) async {
    if (!isValidTikTokUrl(tiktokUrl)) {
      return const TikTokResult(error: ERR_INVALID_TIKTOK_LINK);
    }

    if (!await hasInternet()) {
      return const TikTokResult(error: errExternal);
    }

    // --- Attempt 1: tikwm.com ---
    final tikwmUrl = await _tryTikwm(tiktokUrl);
    if (tikwmUrl != null) {
      if (kDebugMode) debugPrint('[TikTokService] tikwm succeeded');
      return TikTokResult(videoUrl: tikwmUrl);
    }

    // --- Attempt 2: snaptik.as ---
    if (kDebugMode) debugPrint('[TikTokService] tikwm failed, trying SnapTik');
    final snapTikUrl = await SnapTikService.getVideoUrl(tiktokUrl);
    if (snapTikUrl != null) {
      if (kDebugMode) debugPrint('[TikTokService] SnapTik succeeded');
      return TikTokResult(videoUrl: snapTikUrl);
    }

    // --- Attempt 3: ssstik.io ---
    if (kDebugMode) debugPrint('[TikTokService] SnapTik failed, trying SssTik');
    final sssTikUrl = await SssTikService.getVideoUrl(tiktokUrl);
    if (sssTikUrl != null) {
      if (kDebugMode) debugPrint('[TikTokService] SssTik succeeded');
      return TikTokResult(videoUrl: sssTikUrl);
    }

    // --- All three services failed ---
    if (kDebugMode) {
      debugPrint('[TikTokService] all three services failed');
    }
    return const TikTokResult(error: errExternal);
  }

  // ── tikwm.com ───────────────────────────────────────────────────────────

  static Future<String?> _tryTikwm(String tiktokUrl) async {
    try {
      http.Response? response;
      const int maxAttempts = 3;

      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          response = await http
              .post(
                Uri.parse(_apiUrl),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: {'url': tiktokUrl.trim(), 'hd': '0'},
              )
              .timeout(const Duration(seconds: 20));

          if (kDebugMode) {
            debugPrint(
              '[TikTokService] tikwm attempt $attempt status: ${response.statusCode}',
            );
          }
          if (kDebugMode) {
            debugPrint(
              '[TikTokService] body[:500]: ${response.body.substring(0, response.body.length.clamp(0, 500))}',
            );
          }

          if (response.statusCode == 200) {
            break;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TikTokService] tikwm attempt $attempt error: $e');
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      if (response == null || response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final json = decoded;
      if (json['code'] != 0) return null;

      final data = json['data'];
      if (data is! Map<String, dynamic>) return null;

      // If the content is a slideshow of images, it's not a video
      final imageList = data['images'];
      if (imageList is List && imageList.isNotEmpty) return null;

      return _extractPlayableVideoUrl(data);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[TikTokService] _tryTikwm unexpected error: $e');
      }
      if (kDebugMode) {
        debugPrint(st.toString());
      }
      return null;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static String? _extractPlayableVideoUrl(Map<String, dynamic> data) {
    final candidates = <String?>[
      data['play'] as String?,
      data['wmplay'] as String?,
      data['hdplay'] as String?,
    ];

    for (final candidate in candidates) {
      if (_isVideoDownloadUrl(candidate)) {
        return candidate;
      }
    }

    return null;
  }

  static bool _isVideoDownloadUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final mimeType = uri.queryParameters['mime_type']?.toLowerCase();
    if (mimeType != null && mimeType.contains('video')) {
      return true;
    }

    final path = uri.path.toLowerCase();
    return path.contains('/video/') || path.endsWith('.mp4');
  }
}
