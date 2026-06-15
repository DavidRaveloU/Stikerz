import 'package:stikerz/core/constants/app_links.dart';

/// Small helper that exposes the support email address used by the app.
///
/// The email address may be provided at build time via `--dart-define`.
class FeedbackService {
  /// Email address where user feedback should be sent.
  ///
  /// Respects the `FEEDBACK_TO_EMAIL` dart-define; falls back to
  /// `AppLinks.supportEmail` when not provided.
  static String get supportEmail => String.fromEnvironment(
    'FEEDBACK_TO_EMAIL',
    defaultValue: AppLinks.supportEmail,
  );
}
