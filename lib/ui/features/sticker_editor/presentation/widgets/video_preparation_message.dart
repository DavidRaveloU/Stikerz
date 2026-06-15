import 'package:flutter/material.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/video_preparation_service.dart';

enum VideoPreparationMessageType {
  defaultMessage,
  slow,
  verySlow,
  tooLong,
  retrying,
}

class VideoPreparationMessage {
  final String title;
  final String subtitle;

  const VideoPreparationMessage({required this.title, required this.subtitle});
}

/// Lógica pura, sin contexto — testeable en unit tests.
VideoPreparationMessageType resolveVideoPreparationMessageType({
  required VideoPreparationStatus? status,
  required bool hasError,
  required bool hasRetried,
}) {
  if (hasError) return VideoPreparationMessageType.defaultMessage;

  final elapsedSeconds = status?.elapsed.inSeconds ?? 0;
  final progress = status?.progress;

  if (hasRetried || status?.phase == VideoPreparationPhase.retrying) {
    return VideoPreparationMessageType.retrying;
  }

  if (elapsedSeconds < 4) return VideoPreparationMessageType.defaultMessage;
  if (elapsedSeconds < 12) return VideoPreparationMessageType.slow;

  if ((progress == null && elapsedSeconds >= 12) ||
      (progress != null && progress < 0.35 && elapsedSeconds >= 12)) {
    return VideoPreparationMessageType.verySlow;
  }

  if (elapsedSeconds >= 20) return VideoPreparationMessageType.tooLong;

  return VideoPreparationMessageType.defaultMessage;
}

/// Capa de UI — traduce el tipo a strings usando i18n.
VideoPreparationMessage buildVideoPreparationMessage({
  required BuildContext context,
  required VideoPreparationStatus? status,
  required bool hasError,
  required bool hasRetried,
}) {
  final l10n = context.l10n;
  final title = l10n.videoPreparationTitle;
  final attempt = status?.attempt ?? 1;
  final maxAttempts = status?.maxAttempts ?? 3;

  final type = resolveVideoPreparationMessageType(
    status: status,
    hasError: hasError,
    hasRetried: hasRetried,
  );

  final subtitle = switch (type) {
    VideoPreparationMessageType.retrying => l10n.videoPreparationRetrying(
      attempt,
      maxAttempts,
    ),
    VideoPreparationMessageType.slow => l10n.videoPreparationSlow,
    VideoPreparationMessageType.verySlow => l10n.videoPreparationVerySlow,
    VideoPreparationMessageType.tooLong => l10n.videoPreparationTooLong,
    VideoPreparationMessageType.defaultMessage => l10n.videoPreparationDefault,
  };

  return VideoPreparationMessage(title: title, subtitle: subtitle);
}
