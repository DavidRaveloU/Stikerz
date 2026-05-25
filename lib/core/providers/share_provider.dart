// ignore_for_file: constant_identifier_names

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/services/instagram_service.dart';
import 'package:stikerz/core/services/tiktok_service.dart';

/// Local error tokens used by services and provider.
const String ERR_INVALID_TIKTOK_LINK = 'err_invalid_tiktok_link';
const String ERR_INVALID_INSTAGRAM_LINK = 'err_invalid_instagram_link';

/// Represents an incoming shared text item that may resolve to a video URL.
class PendingShare {
  final String rawText;
  final String source;
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

  bool get hasResolvedVideo =>
      resolvedVideoUrl != null && resolvedVideoUrl!.isNotEmpty;
  String get displayText => rawText;
}

final pendingShareProvider = StateProvider<PendingShare?>((ref) => null);
final shareFlowResetProvider = StateProvider<int>((ref) => 0);

String detectShareSource(String text) {
  final t = text.toLowerCase();
  if (t.contains('tiktok.com') || t.contains('vm.tiktok.com')) {
    return 'tiktok';
  }
  if (t.contains('instagram.com') || t.contains('instagr.am')) {
    return 'instagram';
  }
  return 'unknown';
}

Future<PendingShare> resolvePendingShare(PendingShare pending) async {
  switch (pending.source) {
    case 'tiktok':
      final extractedUrl = TikTokService.extractFirstTikTokUrl(pending.rawText);
      if (extractedUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: ERR_INVALID_TIKTOK_LINK,
        );
      }

      final result = await TikTokService.getVideoUrl(extractedUrl);
      if (!result.success || result.videoUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: result.error ?? TikTokService.errExternal,
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
          error: ERR_INVALID_INSTAGRAM_LINK,
        );
      }

      final result = await InstagramService.getVideoUrl(extractedUrl);
      if (!result.success || result.videoUrl == null) {
        return pending.copyWith(
          isResolving: false,
          error: result.error ?? InstagramService.errExternal,
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
