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

  // ── Extracción y validación ─────────────────────────────────────────────

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

  // ── Conexión ────────────────────────────────────────────────────────────

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  // ── Paso 1: obtener tt y ts de la página principal ──────────────────────

  static Future<({String tt, String ts})?> _fetchTokens() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/es'),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 12; Pixel 6) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/120.0.0.0 Mobile Safari/537.36',
              'Accept': 'text/html',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final match = RegExp(
        r'''data-include-vals="tt:'([^']+)',\s*ts:(\d+)''',
      ).firstMatch(response.body);

      if (match == null) return null;

      return (tt: match.group(1)!, ts: match.group(2)!);
    } catch (e) {
      debugPrint('[InstagramService] _fetchTokens error: $e'); // ← log en dev
      return null;
    }
  }

  // ── Llamada principal ───────────────────────────────────────────────────

  static Future<InstagramResult> getVideoUrl(String instagramUrl) async {
    if (!isValidInstagramUrl(instagramUrl)) {
      return const InstagramResult(
        error: 'El enlace no es válido de Instagram',
      );
    }

    if (!await hasInternet()) {
      return const InstagramResult(error: 'Sin conexión a internet');
    }

    final shortcode = _extractShortcode(instagramUrl);
    if (shortcode == null) {
      return const InstagramResult(error: 'No se pudo procesar el enlace');
    }

    // Paso 1: tokens
    final tokens = await _fetchTokens();
    if (tokens == null) {
      return const InstagramResult(
        error: 'No se pudo conectar con el servidor',
      );
    }

    try {
      // Paso 2: POST con headers HTMX exactos que usa el browser
      final response = await http
          .post(
            Uri.parse('$_baseUrl/reel/$shortcode/'),
            headers: {
              'Content-Type':
                  'application/x-www-form-urlencoded; charset=UTF-8',
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 12; Pixel 6) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/120.0.0.0 Mobile Safari/537.36',
              'Accept': '*/*',
              'Accept-Language': 'es-ES,es;q=0.9',
              'Referer': '$_baseUrl/es',
              // Headers HTMX que el servidor espera
              'HX-Current-URL': '$_baseUrl/es',
              'HX-Request': 'true',
              'HX-Target': 'target',
              'HX-Trigger': 'main-form',
            },
            body: {
              'id': instagramUrl,
              'locale': 'es',
              'cf-turnstile-response': '',
              'tt': tokens.tt,
              'ts': tokens.ts,
            },
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('[InstagramService] status: ${response.statusCode}');
      debugPrint(
        '[InstagramService] body[:500]: ${response.body.substring(0, response.body.length.clamp(0, 500))}',
      );

      if (response.statusCode != 200) {
        return const InstagramResult(
          error: 'Error al conectar con el servidor',
        );
      }

      final html = response.body;

      // Parsear href del botón de descarga de video
      final match =
          RegExp(
            r'href="(https://ssscdn\.io/reelsvideo/[^"]+)"[^>]*class="[^"]*download_link[^"]*type_videos[^"]*"',
          ).firstMatch(html) ??
          RegExp(
            r'class="[^"]*download_link[^"]*type_videos[^"]*"[^>]*href="(https://ssscdn\.io/reelsvideo/[^"]+)"',
          ).firstMatch(html);

      final videoUrl = match?.group(1);
      debugPrint('[InstagramService] videoUrl: $videoUrl');

      if (videoUrl == null || videoUrl.isEmpty) {
        return const InstagramResult(
          error: 'No se pudo obtener el video. Verifica que sea público.',
        );
      }

      return InstagramResult(videoUrl: videoUrl);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return const InstagramResult(error: 'Tiempo de espera agotado');
      }
      return InstagramResult(error: 'Error inesperado: ${e.toString()}');
    }
  }
}
