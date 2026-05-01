import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/services/instagram_service.dart';
import 'package:whaticker/core/services/tiktok_service.dart';

class PendingShare {
  final String rawText;
  final String source; // 'tiktok' | 'instagram' | 'unknown'
  final String? resolvedVideoUrl;
  final String? error;
  final bool isResolving;

  const PendingShare({
    required this.rawText,
    required this.source,
    this.resolvedVideoUrl,
    this.error,
    this.isResolving = false,
  });

  PendingShare copyWith({
    String? rawText,
    String? source,
    String? resolvedVideoUrl,
    String? error,
    bool? isResolving,
  }) {
    return PendingShare(
      rawText: rawText ?? this.rawText,
      source: source ?? this.source,
      resolvedVideoUrl: resolvedVideoUrl ?? this.resolvedVideoUrl,
      error: error,
      isResolving: isResolving ?? this.isResolving,
    );
  }

  bool get hasResolvedVideo => resolvedVideoUrl != null && resolvedVideoUrl!.isNotEmpty;
  String get displayText => rawText;
}

final pendingShareProvider = StateProvider<PendingShare?>((ref) => null);

String detectShareSource(String text) {
  final t = text.toLowerCase();
  if (t.contains('tiktok.com') || t.contains('vm.tiktok.com')) return 'tiktok';
  if (t.contains('instagram.com') || t.contains('instagr.am')) return 'instagram';
  return 'unknown';
}

Future<PendingShare> resolvePendingShare(PendingShare pending) async {
  switch (pending.source) {
    case 'tiktok':
      final extractedUrl = TikTokService.extractFirstTikTokUrl(pending.rawText);
      if (extractedUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: 'Pega un enlace válido de TikTok',
        );
      }

      final result = await TikTokService.getVideoUrl(extractedUrl);
      if (!result.success || result.videoUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: result.error ?? 'No se pudo obtener el video de TikTok',
        );
      }

      return pending.copyWith(
        resolvedVideoUrl: result.videoUrl,
        isResolving: false,
        error: null,
      );

    case 'instagram':
      final extractedUrl = InstagramService.cleanInstagramUrl(pending.rawText);
      if (extractedUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: 'Pega un enlace válido de Instagram',
        );
      }

      final result = await InstagramService.getVideoUrl(extractedUrl);
      if (!result.success || result.videoUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: result.error ?? 'No se pudo obtener el video de Instagram',
        );
      }

      return pending.copyWith(
        resolvedVideoUrl: result.videoUrl,
        isResolving: false,
        error: null,
      );

    default:
      return pending.copyWith(
        resolvedVideoUrl: pending.rawText,
        isResolving: false,
        error: null,
      );
  }
}
