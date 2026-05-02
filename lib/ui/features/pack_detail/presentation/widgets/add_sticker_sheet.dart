import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';
import 'package:whaticker/core/services/instagram_service.dart';
import 'package:whaticker/core/services/tiktok_service.dart';

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
          _errorMessage = result.error;
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
          _errorMessage = result.error;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _sheetTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

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
                iconBg: AppColors.accent.withOpacity(0.08),
                iconBorder: AppColors.accent.withOpacity(0.2),
                title: context.l10n.importFromTikTok,
                subtitle: context.l10n.pasteVideoLink,
              ),
              const SizedBox(height: 8),
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
                iconBg: const Color(0xFFE1306C).withOpacity(0.08),
                iconBorder: const Color(0xFFE1306C).withOpacity(0.2),
                title: context.l10n.importFromInstagram,
                subtitle: context.l10n.pasteReelLink,
              ),
              const SizedBox(height: 8),
              _ImportOption(
                onTap: widget.onLocal,
                icon: const Icon(
                  Icons.video_library_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                iconBg: Colors.white.withOpacity(0.04),
                iconBorder: AppColors.border,
                title: context.l10n.localVideo,
                subtitle: context.l10n.fromGallery,
              ),
              const SizedBox(height: 24),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.videoLinkLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _urlCtrl,
                            autofocus: true,
                            enabled: !_loading,
                            onChanged: (_) =>
                                setState(() => _errorMessage = null),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: _hintText,
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
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
                                          color: _accentColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: _accentColor.withOpacity(
                                              0.25,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.content_paste_rounded,
                                              size: 13,
                                              color: _accentColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              context.l10n.paste,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _accentColor,
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
                                      : _accentColor.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _loading ? null : _submitUrl,
                          child: Container(
                            height: 46,
                            width: 56,
                            decoration: BoxDecoration(
                              color: _loading
                                  ? _accentColor.withOpacity(0.5)
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
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Color de acento según el modo activo
  Color get _accentColor => _mode == _ImportMode.instagram
      ? const Color(0xFFE1306C)
      : AppColors.accent;
}

// Componente reutilizable (sin cambios)
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111114),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
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
