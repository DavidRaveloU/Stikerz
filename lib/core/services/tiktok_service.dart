import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class TikTokResult {
  final String? videoUrl;
  final String? error;

  const TikTokResult({this.videoUrl, this.error});

  bool get success => videoUrl != null && error == null;
  bool get hasError => error != null;
}

class TikTokService {
  static const String _apiUrl = 'https://www.tikwm.com/api/';

  // ── Extracción y validación de URL ─────────────────────────────────────

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

  // ── Conexión ───────────────────────────────────────────────────────────

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  // ── Llamada principal ───────────────────────────────────────────────────

  static Future<TikTokResult> getVideoUrl(String tiktokUrl) async {
    if (!isValidTikTokUrl(tiktokUrl)) {
      return const TikTokResult(error: 'El enlace no es válido de TikTok');
    }

    if (!await hasInternet()) {
      return const TikTokResult(error: 'Sin conexión a internet');
    }

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'url': tiktokUrl.trim(), 'hd': '0'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return const TikTokResult(error: 'Error al conectar con el servidor');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const TikTokResult(error: 'Respuesta inválida del servidor');
      }

      final json = decoded;

      if (json['code'] != 0) {
        return const TikTokResult(
          error: 'No se pudo obtener el video. Verifica que sea público.',
        );
      }

      final data = json['data'];
      if (data is! Map<String, dynamic>) {
        return const TikTokResult(error: 'Respuesta inválida del servidor');
      }

      final imageList = data['images'];
      if (imageList is List && imageList.isNotEmpty) {
        return const TikTokResult(
          error:
              'Este enlace de TikTok no es un video. Elige un video y no una publicación de fotos.',
        );
      }

      final videoUrl = _extractPlayableVideoUrl(data);

      if (videoUrl == null || videoUrl.isEmpty) {
        return const TikTokResult(
          error:
              'Este enlace de TikTok no es un video. Elige un video y no una publicación de fotos.',
        );
      }

      return TikTokResult(videoUrl: videoUrl);
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return const TikTokResult(error: 'Tiempo de espera agotado');
      }
      return TikTokResult(error: 'Error inesperado: ${e.toString()}');
    }
  }

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
