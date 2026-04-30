import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/services/tiktok_service.dart';

class AddStickerSheet extends StatefulWidget {
  final VoidCallback onLocal;
  final Function(String videoUrl) onTikTokUrl;

  const AddStickerSheet({
    super.key,
    required this.onLocal,
    required this.onTikTokUrl,
  });

  @override
  State<AddStickerSheet> createState() => _AddStickerSheetState();
}

class _AddStickerSheetState extends State<AddStickerSheet> {
  bool _showTikTokInput = false;
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

  Future<void> _submitTikTokUrl() async {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) return;

    final extractedUrl = TikTokService.extractFirstTikTokUrl(raw);
    if (extractedUrl == null) {
      setState(() => _errorMessage = 'Pega un enlace válido de TikTok');
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

    if (!mounted) return;
    Navigator.pop(context);
    widget.onTikTokUrl(result.videoUrl!);
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
                  _showTikTokInput ? 'Importar de TikTok' : 'Nuevo sticker',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (!_showTikTokInput) ...[
              _ImportOption(
                onTap: () => setState(() => _showTikTokInput = true),
                icon: const Icon(
                  Icons.music_video_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                iconBg: AppColors.accent.withOpacity(0.08),
                iconBorder: AppColors.accent.withOpacity(0.2),
                title: 'Importar de TikTok',
                subtitle: 'Pega un enlace del video',
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
                title: 'Video local',
                subtitle: 'Desde tu galería',
              ),
              const SizedBox(height: 24),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENLACE DEL VIDEO',
                      style: TextStyle(
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
                              hintText: 'https://tiktok.com/...',
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
                              // ── Botón de pegar integrado como sufijo ──
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
                                          color: AppColors.accent.withOpacity(
                                            0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.accent.withOpacity(
                                              0.25,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.content_paste_rounded,
                                              size: 13,
                                              color: AppColors.accent,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Pegar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.accent,
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
                                      : AppColors.accent.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _loading ? null : _submitTikTokUrl,
                          child: Container(
                            height: 46,
                            width: 56,
                            decoration: BoxDecoration(
                              color: _loading
                                  ? AppColors.accent.withOpacity(0.5)
                                  : AppColors.accent,
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
                                : const Text(
                                    'Ir →',
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
}

// Componente reutilizable
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
