import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/instagram_service.dart';
import 'package:stikerz/core/services/tiktok_service.dart';
import 'package:stikerz/core/utils/error_localization.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

enum _AddStickerStep { main, local, social }

class AddStickerSheet extends StatefulWidget {
  final VoidCallback onLocal;
  final VoidCallback onImage;
  final Function(String videoUrl) onTikTokUrl;
  final Function(String videoUrl) onInstagramUrl;

  const AddStickerSheet({
    super.key,
    required this.onLocal,
    required this.onImage,
    required this.onTikTokUrl,
    required this.onInstagramUrl,
  });

  @override
  State<AddStickerSheet> createState() => _AddStickerSheetState();
}

enum _SocialPlatform { tiktok, instagram }

class _AddStickerSheetState extends State<AddStickerSheet> {
  _AddStickerStep _step = _AddStickerStep.main;
  _SocialPlatform _socialPlatform = _SocialPlatform.tiktok;
  bool _loading = false;
  String? _errorMessage;
  final _urlCtrl = TextEditingController();

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  String get _stepTitle {
    return switch (_step) {
      _AddStickerStep.main => context.l10n.newSticker,
      _AddStickerStep.local => context.l10n.addStickerFromDevice,
      _AddStickerStep.social => context.l10n.addStickerFromSocial,
    };
  }

  String get _socialTitle =>
      _socialPlatform == _SocialPlatform.tiktok ? 'TikTok' : 'Instagram';

  Color get _socialColor => _socialPlatform == _SocialPlatform.tiktok
      ? AppColors.accent
      : const Color(0xFFE1306C);

  String get _hintText => _socialPlatform == _SocialPlatform.tiktok
      ? 'https://tiktok.com/...'
      : 'https://instagram.com/reel/...';

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _urlCtrl.text = text;
      _urlCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _submitUrl() async {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    switch (_socialPlatform) {
      case _SocialPlatform.tiktok:
        final extractedUrl = TikTokService.extractFirstTikTokUrl(raw);
        if (extractedUrl == null) {
          setState(() {
            _loading = false;
            _errorMessage = context.l10n.pasteValidTikTokLink;
          });
          return;
        }

        final result = await TikTokService.getVideoUrl(extractedUrl);
        if (!mounted) return;

        if (!result.success) {
          setState(() {
            _loading = false;
            _errorMessage = localizeServiceError(context, result.error);
          });
          return;
        }

        if (!mounted) return;
        Navigator.pop(context);
        widget.onTikTokUrl(result.videoUrl!);
        break;

      case _SocialPlatform.instagram:
        final extractedUrl = InstagramService.cleanInstagramUrl(raw);
        if (extractedUrl == null) {
          setState(() {
            _loading = false;
            _errorMessage = context.l10n.pasteValidInstagramLink;
          });
          return;
        }

        final result = await InstagramService.getVideoUrl(extractedUrl);
        if (!mounted) return;

        if (!result.success) {
          setState(() {
            _loading = false;
            _errorMessage = localizeServiceError(context, result.error);
          });
          return;
        }

        if (!mounted) return;
        Navigator.pop(context);
        widget.onInstagramUrl(result.videoUrl!);
        break;
    }
  }

  void _goToMain() {
    setState(() {
      _step = _AddStickerStep.main;
      _urlCtrl.clear();
      _errorMessage = null;
    });
  }

  void _goToLocal() {
    setState(() {
      _step = _AddStickerStep.local;
      _urlCtrl.clear();
      _errorMessage = null;
    });
  }

  void _goToSocial() {
    setState(() {
      _step = _AddStickerStep.social;
      _urlCtrl.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = context.responsiveSize(16, tabletSize: 20);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontal,
          0,
          horizontal,
          context.responsiveSize(16, tabletSize: 20),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──
            SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
            Container(
              width: context.responsiveSize(36, tabletSize: 40),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.responsiveSize(16, tabletSize: 18)),

            // ── Header ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Row(
                children: [
                  if (_step != _AddStickerStep.main)
                    GestureDetector(
                      onTap: _goToMain,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textSecondary,
                        size: context.responsiveSize(22, tabletSize: 24),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _stepTitle,
                      style: context.responsiveTextStyle(
                        mobileSize: 18,
                        tabletSize: 20,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_step != _AddStickerStep.main)
                    GestureDetector(
                      onTap: _goToMain,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: context.responsiveSize(22, tabletSize: 24),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: context.responsiveSize(14, tabletSize: 16)),

            // ── Body ──
            switch (_step) {
              _AddStickerStep.main => _buildMainStep(horizontal),
              _AddStickerStep.local => _buildLocalStep(horizontal),
              _AddStickerStep.social => _buildSocialStep(horizontal),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildMainStep(double horizontal) {
    final l10n = context.l10n;
    return Column(
      children: [
        _MainOption(
          horizontal: horizontal,
          icon: Icons.devices_rounded,
          iconColor: Colors.blue,
          title: l10n.addStickerFromDevice,
          subtitle: l10n.addStickerFromDeviceSubtitle,
          onTap: _goToLocal,
        ),
        SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
        _MainOption(
          horizontal: horizontal,
          icon: Icons.public_rounded,
          iconColor: Colors.purple,
          title: l10n.addStickerFromSocial,
          subtitle: l10n.addStickerFromSocialSubtitle,
          onTap: _goToSocial,
        ),
        SizedBox(height: context.responsiveSize(24, tabletSize: 28)),
      ],
    );
  }

  Widget _buildLocalStep(double horizontal) {
    final l10n = context.l10n;
    return Column(
      children: [
        _LocalOption(
          horizontal: horizontal,
          icon: Icons.video_library_rounded,
          iconColor: Colors.orange,
          title: l10n.addStickerVideo,
          subtitle: l10n.addStickerVideoSubtitle,
          onTap: widget.onLocal,
        ),
        SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
        _LocalOption(
          horizontal: horizontal,
          icon: Icons.photo_rounded,
          iconColor: const Color(0xFF34C759),
          title: l10n.addStickerImage,
          subtitle: l10n.addStickerImageSubtitle,
          onTap: widget.onImage,
        ),
        SizedBox(height: context.responsiveSize(24, tabletSize: 28)),
      ],
    );
  }

  Widget _buildSocialStep(double horizontal) {
    final l10n = context.l10n;
    return Column(
      children: [
        // ── Selector TikTok / Instagram ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _socialPlatform = _SocialPlatform.tiktok;
                      _urlCtrl.clear();
                      _errorMessage = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSize(10, tabletSize: 12),
                    ),
                    decoration: BoxDecoration(
                      color: _socialPlatform == _SocialPlatform.tiktok
                          ? AppColors.accent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _socialPlatform == _SocialPlatform.tiktok
                            ? AppColors.accent
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_video_rounded,
                          color: _socialPlatform == _SocialPlatform.tiktok
                              ? AppColors.accent
                              : AppColors.textMuted,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TikTok',
                          style: context.responsiveTextStyle(
                            mobileSize: 13,
                            tabletSize: 14,
                            color: _socialPlatform == _SocialPlatform.tiktok
                                ? AppColors.accent
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _socialPlatform = _SocialPlatform.instagram;
                      _urlCtrl.clear();
                      _errorMessage = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSize(10, tabletSize: 12),
                    ),
                    decoration: BoxDecoration(
                      color: _socialPlatform == _SocialPlatform.instagram
                          ? const Color(0xFFE1306C).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _socialPlatform == _SocialPlatform.instagram
                            ? const Color(0xFFE1306C)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: _socialPlatform == _SocialPlatform.instagram
                              ? const Color(0xFFE1306C)
                              : AppColors.textMuted,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Instagram',
                          style: context.responsiveTextStyle(
                            mobileSize: 13,
                            tabletSize: 14,
                            color: _socialPlatform == _SocialPlatform.instagram
                                ? const Color(0xFFE1306C)
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveSize(12, tabletSize: 14)),

        // ── URL Input ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addStickerPasteLinkHint(_socialTitle),
                style: context.responsiveTextStyle(
                  mobileSize: 11,
                  tabletSize: 12,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _urlCtrl,
                      autofocus: true,
                      enabled: !_loading,
                      onChanged: (_) => setState(() => _errorMessage = null),
                      style: context.responsiveTextStyle(
                        mobileSize: 13,
                        tabletSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: _hintText,
                        hintStyle: context.responsiveTextStyle(
                          mobileSize: 12,
                          tabletSize: 13,
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.responsiveSize(
                            12,
                            tabletSize: 14,
                          ),
                          vertical: context.responsiveSize(12, tabletSize: 13),
                        ),
                        suffixIcon: _loading
                            ? null
                            : GestureDetector(
                                onTap: _pasteFromClipboard,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 7,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _socialColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _socialColor.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.content_paste_rounded,
                                        size: context.responsiveSize(
                                          13,
                                          tabletSize: 14,
                                        ),
                                        color: _socialColor,
                                      ),
                                      SizedBox(
                                        width: context.responsiveSize(
                                          4,
                                          tabletSize: 5,
                                        ),
                                      ),
                                      Text(
                                        context.l10n.paste,
                                        style: context.responsiveTextStyle(
                                          mobileSize: 12,
                                          tabletSize: 13,
                                          color: _socialColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? Colors.redAccent
                                : AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? Colors.redAccent
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? Colors.redAccent
                                : _socialColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
                  GestureDetector(
                    onTap: _loading ? null : _submitUrl,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSize(18, tabletSize: 20),
                        vertical: context.responsiveSize(12, tabletSize: 13),
                      ),
                      decoration: BoxDecoration(
                        color: _loading
                            ? _socialColor.withValues(alpha: 0.5)
                            : _socialColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.background,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              context.l10n.go,
                              style: context.responsiveTextStyle(
                                mobileSize: 13,
                                tabletSize: 14,
                                color: AppColors.background,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: context.responsiveSize(8, tabletSize: 10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: context.responsiveTextStyle(
                      mobileSize: 12,
                      tabletSize: 13,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              SizedBox(height: context.responsiveSize(16, tabletSize: 18)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reusable Option Widgets (sin cambios, solo reciben strings) ──

class _MainOption extends StatelessWidget {
  final double horizontal;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MainOption({
    required this.horizontal,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.responsiveSize(14, tabletSize: 16)),
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              SizedBox(width: context.responsiveSize(14, tabletSize: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.responsiveTextStyle(
                        mobileSize: 15,
                        tabletSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: context.responsiveSize(2, tabletSize: 3)),
                    Text(
                      subtitle,
                      style: context.responsiveTextStyle(
                        mobileSize: 12,
                        tabletSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalOption extends StatelessWidget {
  final double horizontal;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LocalOption({
    required this.horizontal,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.responsiveSize(14, tabletSize: 16)),
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              SizedBox(width: context.responsiveSize(14, tabletSize: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.responsiveTextStyle(
                        mobileSize: 15,
                        tabletSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: context.responsiveSize(2, tabletSize: 3)),
                    Text(
                      subtitle,
                      style: context.responsiveTextStyle(
                        mobileSize: 12,
                        tabletSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
