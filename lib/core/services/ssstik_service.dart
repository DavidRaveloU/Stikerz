// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Third-party service to obtain a TikTok video URL.
/// Used as a second fallback when tikwm and SnapTik fail.
///
/// Flow:
///   1. GET https://ssstik.io/ → extract `tt` token from HTML
///   2. POST https://ssstik.io/abc?url=dl with link + tt → parse the
///      "Without watermark" button href from the response HTML
class SssTikService {
  static const String _baseUrl = 'https://ssstik.io';
  static const String _apiPath = '/abc?url=dl';

  /// Returns a direct video URL, or `null` when it cannot be resolved.
  ///
  /// This method does not throw; failures are logged in debug mode.
  static Future<String?> getVideoUrl(String tiktokUrl) async {
    try {
      // Step 1: fetch the tt token from the main page
      final tt = await _fetchToken();
      if (tt == null) {
        if (kDebugMode) debugPrint('[SssTikService] could not fetch tt token');
        return null;
      }

      // Step 2: submit the TikTok URL with the extracted token.
      http.Response? response;
      const int maxAttempts = 3;

      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          response = await http
              .post(
                Uri.parse('$_baseUrl$_apiPath'),
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded',
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                      'AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/147.0.0.0 Safari/537.36',
                  'Accept': '*/*',
                  'Accept-Language': 'en-US,en;q=0.9',
                  'Origin': _baseUrl,
                  'Referer': '$_baseUrl/',
                  // HTMX headers required by the service.
                  'HX-Current-URL': '$_baseUrl/',
                  'HX-Request': 'true',
                  'HX-Target': 'target',
                  'HX-Trigger': '_gcaptcha_pt',
                },
                body: {'id': tiktokUrl.trim(), 'locale': 'en', 'tt': tt},
              )
              .timeout(const Duration(seconds: 20));

          if (kDebugMode) {
            debugPrint(
              '[SssTikService] attempt $attempt status: ${response.statusCode}',
            );
          }

          if (response.statusCode == 200) break;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[SssTikService] attempt $attempt error: $e');
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      if (response == null || response.statusCode != 200) {
        if (kDebugMode) debugPrint('[SssTikService] all attempts failed');
        return null;
      }

      final videoUrl = _extractVideoUrl(response.body);
      if (kDebugMode) debugPrint('[SssTikService] videoUrl: $videoUrl');
      return videoUrl;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[SssTikService] unexpected error: $e');
      if (kDebugMode) debugPrint(st.toString());
      return null;
    }
  }

  /// Fetches the `tt` token from the landing page.
  static Future<String?> _fetchToken() async {
    try {
      http.Response? response;
      const int maxAttempts = 3;

      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          response = await http
              .get(
                Uri.parse('$_baseUrl/'),
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                      'AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/147.0.0.0 Safari/537.36',
                  'Accept': 'text/html',
                  'Accept-Language': 'en-US,en;q=0.9',
                },
              )
              .timeout(const Duration(seconds: 20));

          if (response.statusCode == 200) break;
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[SssTikService] _fetchToken attempt $attempt error: $e',
            );
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      if (response == null || response.statusCode != 200) return null;

      // The tt token is in a hidden input: <input type="hidden" name="tt" value="XXXXX">
      // It may also appear as data-tt="XXXXX" on some elements
      final match =
          RegExp(
            r'''<input[^>]+name=["']tt["'][^>]+value=["']([^"']+)["']''',
            caseSensitive: false,
          ).firstMatch(response.body) ??
          RegExp(
            r'''<input[^>]+value=["']([^"']+)["'][^>]+name=["']tt["']''',
            caseSensitive: false,
          ).firstMatch(response.body);

      final tt = match?.group(1);
      if (kDebugMode) debugPrint('[SssTikService] tt token: $tt');
      return tt;
    } catch (e) {
      if (kDebugMode) debugPrint('[SssTikService] _fetchToken error: $e');
      return null;
    }
  }

  /// Extracts the "Without watermark" button href from the response HTML.
  ///
  /// Expected HTML snippet:
  ///   <a href="https://tikcdn.io/ssstik/VIDEO_ID?st=...&e=..." class="... without_watermark ...">
  ///
  /// Avoid the HD button (without_watermark_hd) because it requires an
  /// extra reward-token step. Use the standard without-watermark button.
  static String? _extractVideoUrl(String html) {
    final patterns = <RegExp>[
      // Standard "Without watermark" button on tikcdn.io (non-HD)
      RegExp(
        r'href="(https?://tikcdn\.io/ssstik/\d+[^"]*)"[^>]*class="[^"]*without_watermark[^"]*"',
        caseSensitive: false,
      ),
      // Fallback: class without_watermark first, href afterwards
      RegExp(
        r'class="[^"]*without_watermark(?!_hd)[^"]*"[^>]*href="(https?://tikcdn\.io/ssstik/[^"]+)"',
        caseSensitive: false,
      ),
      // Broad fallback: any tikcdn URL with ssstik
      RegExp(
        r'href="(https?://tikcdn\.io/ssstik/\d+\?[^"]+)"',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        final url = match.group(1);
        if (url != null && url.isNotEmpty) return url;
      }
    }

    if (kDebugMode) debugPrint('[SssTikService] no video URL found in HTML');
    return null;
  }
}
