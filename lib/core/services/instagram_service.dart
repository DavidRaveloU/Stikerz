// ignore_for_file: constant_identifier_names

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class InstagramResult {
  final String? videoUrl;
  final String? error;

  const InstagramResult({this.videoUrl, this.error});

  bool get success => videoUrl != null && error == null;
  bool get hasError => error != null;
}

class InstagramService {
  static const String _baseUrl = 'https://reelsvideo.io';

  // Error tokens returned to the UI and mapped to localized messages.
  static const String errExternal = 'err_external_service';
  static const String errTimeout = 'err_timeout';
  static const String errInvalidResponse = 'err_invalid_response';
  static const String errNotVideo = 'err_not_a_video';
  static const String errVideoNotPublic = 'err_video_not_public';

  static String? cleanInstagramUrl(String rawInput) {
    if (rawInput.trim().isEmpty) return null;
    final regex = RegExp(
      r'https?://(?:www\.)?instagram\.com/(?:reel|p|tv)/[^\s]+',
      caseSensitive: false,
    );
    final match = regex.firstMatch(rawInput);
    if (match == null) return null;
    return _stripTrailingPunctuation(match.group(0)!);
  }

  static String _stripTrailingPunctuation(String value) {
    var out = value.trim();
    while (out.isNotEmpty && '.!,?)]'.contains(out[out.length - 1])) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  static String? _extractShortcode(String instagramUrl) {
    final uri = Uri.tryParse(instagramUrl);
    if (uri == null) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final typeIndex = segments.indexWhere(
      (s) => s == 'reel' || s == 'p' || s == 'tv',
    );
    if (typeIndex == -1 || typeIndex + 1 >= segments.length) return null;
    return segments[typeIndex + 1];
  }

  static bool isValidInstagramUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return false;
    if (!uri.host.toLowerCase().contains('instagram.com')) return false;
    return ['/reel/', '/p/', '/tv/'].any((p) => uri.path.contains(p));
  }

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Resolves an Instagram URL to a direct video URL.

  static Future<InstagramResult> getVideoUrl(String instagramUrl) async {
    if (!isValidInstagramUrl(instagramUrl)) {
      return const InstagramResult(error: errInvalidResponse);
    }

    if (!await hasInternet()) {
      return const InstagramResult(error: errExternal);
    }

    // Use reelsvideo.io as primary resolver.
    final videoUrl = await _tryReelsVideo(instagramUrl);
    if (videoUrl != null) {
      if (kDebugMode) debugPrint('[InstagramService] reelsvideo.io succeeded');
      return InstagramResult(videoUrl: videoUrl);
    }

    if (kDebugMode) debugPrint('[InstagramService] reelsvideo.io failed');
    return const InstagramResult(error: errExternal);
  }

  /// Primary resolver implementation using reelsvideo.io.

  static Future<String?> _tryReelsVideo(String instagramUrl) async {
    final shortcode = _extractShortcode(instagramUrl);
    if (shortcode == null) return null;

    final tokens = await _fetchTokens();
    if (tokens == null) {
      if (kDebugMode) debugPrint('[InstagramService] Failed to fetch tokens');
      return null;
    }

    try {
      final cleanUrl = instagramUrl.split('?')[0];

      final postUri = Uri.parse(
        '$_baseUrl/reel/$shortcode/?utm_source=ig_web_copy_link',
      );

      http.Response? response;
      const int maxAttempts = 3;

      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          response = await http
              .post(
                postUri,
                headers: {
                  'Content-Type':
                      'application/x-www-form-urlencoded; charset=UTF-8',
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
                  'Accept': '*/*',
                  'Accept-Language': 'en-US,en;q=0.9',
                  'Referer': '$_baseUrl/',
                  'HX-Current-URL': '$_baseUrl/',
                  'HX-Request': 'true',
                  'HX-Target': 'target',
                  'HX-Trigger': 'main-form',
                  'Origin': _baseUrl,
                },
                body: {
                  'id': cleanUrl,
                  'locale': 'en',
                  'cf-turnstile-response': '',
                  'tt': tokens.tt,
                  'ts': tokens.ts,
                },
              )
              .timeout(const Duration(seconds: 25));

          if (kDebugMode) {
            debugPrint(
              '[InstagramService] attempt $attempt -> ${response.statusCode}',
            );
          }

          if (response.statusCode == 200) break;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[InstagramService] attempt $attempt error: $e');
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 700 * attempt));
        }
      }

      if (response == null || response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
            '[InstagramService] Failed with status: ${response?.statusCode}',
          );
        }
        return null;
      }

      final html = response.body;

      // Extraction patterns (prefer direct links first)
      final videoRegexes = [
        RegExp(r'href="(https?://ssscdn\.io/[^"\s]+)"', caseSensitive: false),
        RegExp(
          r'href="(https?://[^"\s]*reelsvideo[^"\s]*\.(mp4|video)[^"\s]*)"',
          caseSensitive: false,
        ),
        RegExp(
          r'class="[^"]*download_link[^"]*"[^>]*href="(https?://[^"\s]+)"',
          caseSensitive: false,
        ),
        RegExp(r'"(https?://[^"\s]+\.mp4[^"\s]*)"', caseSensitive: false),
      ];

      for (final regex in videoRegexes) {
        final match = regex.firstMatch(html);
        if (match != null) {
          final videoUrl = match.group(1);
          if (videoUrl != null &&
              videoUrl.isNotEmpty &&
              !videoUrl.contains('/reel/') && // Avoid page URLs
              (videoUrl.contains('ssscdn.io') || videoUrl.contains('.mp4'))) {
            if (kDebugMode) {
              debugPrint('[InstagramService] Direct video URL: $videoUrl');
            }
            return videoUrl;
          }
        }
      }

      if (kDebugMode) {
        debugPrint('[InstagramService] No direct video URL found');
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[InstagramService] _tryReelsVideo error: $e');
      if (kDebugMode) debugPrint(st.toString());
      return null;
    }
  }

  /// Fetches anti-bot tokens required by reelsvideo.io.

  static Future<({String tt, String ts})?> _fetchTokens() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/'),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final body = response.body;

      final ttMatch = RegExp(r'id="tt"[^>]*value="([^"]+)"').firstMatch(body);
      final tsMatch = RegExp(r'id="ts"[^>]*value="([^"]+)"').firstMatch(body);

      if (ttMatch == null || tsMatch == null) {
        if (kDebugMode) {
          debugPrint('[InstagramService] Tokens not found');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('[InstagramService] Tokens fetched successfully');
      }
      return (tt: ttMatch.group(1)!, ts: tsMatch.group(1)!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InstagramService] _fetchTokens error: $e');
      }
      return null;
    }
  }
}
