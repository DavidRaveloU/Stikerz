import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/providers/settings_provider.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/generated_l10n/app_localizations.dart';

class LanguageSelectorModal extends ConsumerWidget {
  const LanguageSelectorModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + media.padding.bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.changeLanguage,
                      style: context.responsiveTextStyle(
                        mobileSize: 20,
                        tabletSize: 22,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildOption(
                      context: context,
                      code: null,
                      label: l10n.useDeviceLanguage,
                      emoji: '🌐',
                      selected: selected,
                      onTap: () async {
                        final nav = Navigator.of(context);
                        await notifier.setLocale(null);
                        nav.pop();
                      },
                    ),
                    _buildOption(
                      context: context,
                      code: 'en',
                      label: l10n.languageEnglish,
                      emoji: '🇺🇸',
                      selected: selected,
                      onTap: () async {
                        final nav = Navigator.of(context);
                        await notifier.setLocale('en');
                        nav.pop();
                      },
                    ),
                    _buildOption(
                      context: context,
                      code: 'es',
                      label: l10n.languageSpanish,
                      emoji: '🇪🇸',
                      selected: selected,
                      onTap: () async {
                        final nav = Navigator.of(context);
                        await notifier.setLocale('es');
                        nav.pop();
                      },
                    ),
                    _buildOption(
                      context: context,
                      code: 'pt',
                      label: l10n.languagePortuguese,
                      emoji: '🇧🇷',
                      selected: selected,
                      onTap: () async {
                        final nav = Navigator.of(context);
                        await notifier.setLocale('pt');
                        nav.pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String? code,
    required String label,
    required String emoji,
    required String? selected,
    required VoidCallback onTap,
  }) {
    final isSelected = selected == code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.04)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.accent.withValues(alpha: 0.05),
            highlightColor: AppColors.accent.withValues(alpha: 0.03),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? Container(
                            key: const ValueKey('check'),
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 13,
                              color: AppColors.background,
                            ),
                          )
                        : Container(
                            key: const ValueKey('empty'),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
