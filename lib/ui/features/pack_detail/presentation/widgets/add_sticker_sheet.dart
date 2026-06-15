import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/instagram_service.dart';
import 'package:stikerz/core/services/tiktok_service.dart';
import 'package:stikerz/core/utils/error_localization.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class AddStickerSheet extends StatefulWidget {
  final VoidCallback onLocal;
  final Function(String videoUrl) onTikTokUrl;
  final Function(String videoUrl) onInstagramUrl;

  const AddStickerSheet({
    super.key,
    required this.onLocal,
    required this.onTikTokUrl,
    required this.onInstagramUrl,
  });

  @override
  State<AddStickerSheet> createState() => _AddStickerSheetState();
}

enum _ImportMode { none, tiktok, instagram }

class _AddStickerSheetState extends State<AddStickerSheet> {
  _ImportMode _mode = _ImportMode.none;
  bool _loading = false;
  String? _errorMessage;
  final _urlCtrl = TextEditingController();

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

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

    if (_mode == _ImportMode.tiktok) {
      final extractedUrl = TikTokService.extractFirstTikTokUrl(raw);
      if (extractedUrl == null) {
        setState(() => _errorMessage = context.l10n.pasteValidTikTokLink);
        return;
      }

      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      final result = await TikTokService.getVideoUrl(extractedUrl);
      if (!mounted) return;

      if (!result.success) {
        setState(() {
          _loading = false;
          _errorMessage = localizeServiceError(context, result.error);
        });
        return;
      }

      Navigator.pop(context);
      widget.onTikTokUrl(result.videoUrl!);
    } else if (_mode == _ImportMode.instagram) {
      final extractedUrl = InstagramService.cleanInstagramUrl(raw);

      if (extractedUrl == null) {
        setState(() => _errorMessage = context.l10n.pasteValidInstagramLink);
        return;
      }

      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      final result = await InstagramService.getVideoUrl(extractedUrl);

      if (!mounted) return;

      if (!result.success) {
        setState(() {
          _loading = false;
          _errorMessage = localizeServiceError(context, result.error);
        });
        return;
      }

      Navigator.pop(context);
      widget.onInstagramUrl(result.videoUrl!);
    }
  }

  String get _sheetTitle {
    return switch (_mode) {
      _ImportMode.tiktok => context.l10n.importFromTikTok,
      _ImportMode.instagram => context.l10n.importFromInstagram,
      _ImportMode.none => context.l10n.newSticker,
    };
  }

  String get _hintText {
    return switch (_mode) {
      _ImportMode.tiktok => 'https://tiktok.com/...',
      _ImportMode.instagram => 'https://instagram.com/reel/...',
      _ImportMode.none => '',
    };
  }

  Color get _accentColor => _mode == _ImportMode.instagram
      ? const Color(0xFFE1306C)
      : AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.responsiveSize(16, tabletSize: 20);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _sheetTitle,
                  style: context.responsiveTextStyle(
                    mobileSize: 18,
                    tabletSize: 20,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.responsiveSize(14, tabletSize: 16)),

            if (_mode == _ImportMode.none) ...[
              _ImportOption(
                onTap: () {
                  setState(() {
                    _mode = _ImportMode.tiktok;
                    _errorMessage = null;
                    _urlCtrl.clear();
                  });
                },
                icon: const Icon(
                  Icons.music_video_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                iconBg: AppColors.accent.withValues(alpha: 0.08),
                iconBorder: AppColors.accent.withValues(alpha: 0.2),
                title: context.l10n.importFromTikTok,
                subtitle: context.l10n.pasteVideoLink,
              ),
              SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
              _ImportOption(
                onTap: () {
                  setState(() {
                    _mode = _ImportMode.instagram;
                    _errorMessage = null;
                    _urlCtrl.clear();
                  });
                },
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFFE1306C),
                  size: 20,
                ),
                iconBg: const Color(0xFFE1306C).withValues(alpha: 0.08),
                iconBorder: const Color(0xFFE1306C).withValues(alpha: 0.2),
                title: context.l10n.importFromInstagram,
                subtitle: context.l10n.pasteReelLink,
              ),
              SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
              _ImportOption(
                onTap: widget.onLocal,
                icon: const Icon(
                  Icons.video_library_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                iconBg: Colors.white.withValues(alpha: 0.04),
                iconBorder: AppColors.border,
                title: context.l10n.localVideo,
                subtitle: context.l10n.fromGallery,
              ),
              SizedBox(height: context.responsiveSize(24, tabletSize: 28)),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.videoLinkLabel,
                      style: context.responsiveTextStyle(
                        mobileSize: 11,
                        tabletSize: 12,
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
                    Row(
                      // Keep GO button vertically centered with the text field.
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _urlCtrl,
                            autofocus: true,
                            enabled: !_loading,
                            onChanged: (_) =>
                                setState(() => _errorMessage = null),
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
                                vertical: context.responsiveSize(
                                  12,
                                  tabletSize: 13,
                                ),
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
                                          color: _accentColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: _accentColor.withValues(
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
                                              color: _accentColor,
                                            ),
                                            SizedBox(
                                              width: context.responsiveSize(
                                                4,
                                                tabletSize: 5,
                                              ),
                                            ),
                                            Text(
                                              context.l10n.paste,
                                              style: context
                                                  .responsiveTextStyle(
                                                    mobileSize: 12,
                                                    tabletSize: 13,
                                                    color: _accentColor,
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
                                      : _accentColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: context.responsiveSize(8, tabletSize: 10),
                        ),

                        // Use adaptive padding instead of fixed size to avoid
                        // text clipping with larger system fonts.
                        GestureDetector(
                          onTap: _loading ? null : _submitUrl,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsiveSize(
                                18,
                                tabletSize: 20,
                              ),
                              vertical: context.responsiveSize(
                                12,
                                tabletSize: 13,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: _loading
                                  ? _accentColor.withValues(alpha: 0.5)
                                  : _accentColor,
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
                    SizedBox(
                      height: context.responsiveSize(16, tabletSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable import option tile.
class _ImportOption extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String subtitle;

  const _ImportOption({
    required this.onTap,
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16, tabletSize: 20),
      ),
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
              // Icon size can stay fixed because it is not text.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconBorder),
                ),
                child: Center(child: icon),
              ),
              SizedBox(width: context.responsiveSize(14, tabletSize: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.responsiveTextStyle(
                        mobileSize: 14,
                        tabletSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.responsiveSize(2, tabletSize: 3)),
                    Text(
                      subtitle,
                      style: context.responsiveTextStyle(
                        mobileSize: 12,
                        tabletSize: 13,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
