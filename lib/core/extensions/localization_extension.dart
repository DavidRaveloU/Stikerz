import 'package:flutter/material.dart';
import 'package:whaticker/generated_l10n/app_localizations.dart';

/// Extension para acceder fácilmente a las traducciones desde BuildContext
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
