// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Secondary service to obtain a TikTok video URL.
/// Used as a fallback when [TikTokService] (tikwm.com) fails.
///
/// Flow:
///   POST https://snaptik.as/ with the link → parse the "Download Video"
///   button href from the HTML → return that URL.
class SnapTikService {
  static const String _baseUrl = 'https://snaptik.as';

  // ── Main call ──────────────────────────────────────────────────────────

  /// Returns the direct video URL, or `null` if it could not be obtained.
  /// Does not throw: any error is logged and results in `null`.
  static Future<String?> getVideoUrl(String tiktokUrl) async {
    try {
      http.Response? response;
      const int maxAttempts = 3;

      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          response = await http
              .post(
                Uri.parse('$_baseUrl/'),
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
                  // HTMX headers required by the server
                  'HX-Boosted': 'true',
                  'HX-Current-URL': '$_baseUrl/',
                  'HX-Request': 'true',
                },
                body: {'url': tiktokUrl.trim()},
              )
              .timeout(const Duration(seconds: 20));

          if (kDebugMode) {
            debugPrint(
              '[SnapTikService] attempt $attempt status: ${response.statusCode}',
            );
          }

          if (response.statusCode == 200) {
            break;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[SnapTikService] attempt $attempt error: $e');
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      if (response == null || response.statusCode != 200) {
        if (kDebugMode) debugPrint('[SnapTikService] all attempts failed');
        return null;
      }

      final videoUrl = _extractVideoUrl(response.body);
      if (kDebugMode) debugPrint('[SnapTikService] videoUrl: $videoUrl');
      return videoUrl;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[SnapTikService] unexpected error: $e');
      if (kDebugMode) debugPrint(st.toString());
      return null;
    }
  }

  // ── HTML parsing ───────────────────────────────────────────────────────

  /// Extracts the "Download Video" button href from the response HTML.
  ///
  /// Example HTML snippet:
  ///   <a ... href="https://tikcdn.beubagah.com/?u=BASE64&dl=1" ...>Download Video</a>
  ///
  /// Try the known tikcdn domain first, then use a broader pattern as
  /// a fallback in case the provider changes domains.
  static String? _extractVideoUrl(String html) {
    // Primary pattern: tikcdn domain + dl=1 parameter (this is the video, not MP3)
    final patterns = <RegExp>[
      // href with tikcdn and dl=1 → video button
      RegExp(r'href="(https?://tikcdn\.[^"]+&dl=1)"', caseSensitive: false),
      // Fallback: any href with &dl=1 (in case the domain changes)
      RegExp(r'href="(https?://[^"]+&dl=1)"', caseSensitive: false),
      // Broad fallback: first download button with u= (Base64 parameter)
      RegExp(r'href="(https?://[^"]+[?&]u=[^"]+)"', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        final url = match.group(1);
        if (url != null && url.isNotEmpty) return url;
      }
    }

    if (kDebugMode) debugPrint('[SnapTikService] no video URL found in HTML');
    return null;
  }
}
