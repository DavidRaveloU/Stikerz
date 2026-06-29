import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/constants/app_links.dart';
import 'package:stikerz/core/providers/settings_provider.dart';
import 'package:stikerz/generated_l10n/app_localizations.dart';
import 'package:stikerz/ui/components/about_card.dart';
import 'package:stikerz/ui/components/section_header.dart';
import 'package:stikerz/ui/components/settings_tile.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/bug_report_modal.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/language_selector_modal.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/remove_ads_tile.dart';
import 'package:stikerz/ui/features/settings/presentation/widgets/webview_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final Future<String> _appVersionFuture;

  @override
  void initState() {
    super.initState();
    _appVersionFuture = _loadAppVersion();
  }

  Future<String> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  Future<void> _openSupportLink(BuildContext context) async {
    final uri = Uri.parse(AppLinks.buyMeACoffee);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // ── Premium / Remove Ads ── primero y destacado
          const SizedBox(height: 8),
          const RemoveAdsTile(),
          const SizedBox(height: 8),

          const Divider(color: AppColors.border),
          const SectionHeader('General'),
          SettingsTile(
            icon: Icons.language,
            title: l10n.changeLanguage,
            subtitle: selected == null
                ? l10n.useDeviceLanguage
                : (selected == 'en'
                      ? l10n.languageEnglish
                      : selected == 'es'
                      ? l10n.languageSpanish
                      : l10n.languagePortuguese),
            onTap: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              builder: (_) => const LanguageSelectorModal(),
            ),
          ),

          const Divider(color: AppColors.border),
          const SectionHeader('Support'),
          SettingsTile(
            icon: Icons.article,
            title: l10n.termsAndConditions,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const WebviewModal(
                    title: 'Terms & Conditions',
                    url:
                        'https://davidravelou.github.io/stikerz-landing-page/terms/',
                  ),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.privacy_tip,
            title: l10n.privacyPolicy,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const WebviewModal(
                    title: 'Privacy Policy',
                    url:
                        'https://davidravelou.github.io/stikerz-landing-page/privacy/',
                  ),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.star_rate,
            title: l10n.rateApp,
            onTap: () async {
              final uri = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.davidravelo.stikerz',
              );
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
          SettingsTile(
            icon: Icons.local_cafe,
            title: 'Buy Me a Coffee',
            subtitle: AppLinks.buyMeACoffee.replaceFirst('https://', ''),
            onTap: () => _openSupportLink(context),
          ),
          SettingsTile(
            icon: Icons.bug_report,
            title: l10n.reportBug,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BugReportModal()));
            },
          ),

          const Divider(color: AppColors.border),
          const SectionHeader('About'),
          FutureBuilder<String>(
            future: _appVersionFuture,
            builder: (context, snapshot) {
              final appVersion = snapshot.data ?? '...';
              return AboutCard(
                name: 'David Ravelo',
                role: l10n.aboutRole,
                description: l10n.aboutDescription,
                appName: l10n.appTitle,
                version: '${l10n.versionLabel} $appVersion',
                instagramUrl: AppLinks.instagram,
                githubUrl: AppLinks.github,
                emailAddress: AppLinks.supportEmail,
              );
            },
          ),
        ],
      ),
    );
  }
}