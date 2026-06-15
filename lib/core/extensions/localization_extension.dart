import 'package:flutter/material.dart';
import 'package:stikerz/generated_l10n/app_localizations.dart';

/// Extension to easily access localized strings from BuildContext
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
