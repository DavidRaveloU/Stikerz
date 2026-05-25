import 'package:flutter/material.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/providers/share_provider.dart';
import 'package:stikerz/core/services/instagram_service.dart';
import 'package:stikerz/core/services/tiktok_service.dart';

/// Maps internal service error tokens to localized user-facing messages.
String localizeServiceError(BuildContext context, String? error) {
  if (error == null) return '';

  if (error == TikTokService.errExternal ||
      error == InstagramService.errExternal) {
    return context.l10n.externalServiceDown;
  }
  if (error == TikTokService.errTimeout ||
      error == InstagramService.errTimeout) {
    return context.l10n.externalServiceTimeout;
  }
  if (error == TikTokService.errInvalidResponse ||
      error == InstagramService.errInvalidResponse) {
    return context.l10n.externalServiceInvalidResponse;
  }
  if (error == TikTokService.errNotVideo ||
      error == InstagramService.errNotVideo) {
    return context.l10n.externalServiceNotVideo;
  }
  if (error == TikTokService.errVideoNotPublic ||
      error == InstagramService.errVideoNotPublic) {
    return context.l10n.externalServiceVideoNotPublic;
  }
  if (error == ERR_INVALID_TIKTOK_LINK) {
    return context.l10n.pasteValidTikTokLink;
  }
  if (error == ERR_INVALID_INSTAGRAM_LINK) {
    return context.l10n.pasteValidInstagramLink;
  }

  return error;
}
