import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/whatsapp_sticker_service.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

class WhatsAppButton extends StatefulWidget {
  final StickerPackModel pack;

  const WhatsAppButton({super.key, required this.pack});

  @override
  State<WhatsAppButton> createState() => _WhatsAppButtonState();
}

class _WhatsAppButtonState extends State<WhatsAppButton> {
  bool _isExporting = false;

  Future<void> _sendToWhatsApp() async {
    if (!widget.pack.canSendToWhatsApp) return;

    setState(() => _isExporting = true);

    try {
      await WhatsAppStickerService.sendPack(widget.pack);
    } on WhatsAppStickerException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotSendToWhatsApp)),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.pack.canSendToWhatsApp && !_isExporting;

    String label;
    if (_isExporting) {
      label = context.l10n.sendingToWhatsApp;
    } else if (!widget.pack.hasCover) {
      label = context.l10n.addCoverFirst;
    } else if (widget.pack.filledCount < 3) {
      label = context.l10n.needAtLeastThreeStickers;
    } else {
      label = context.l10n.addToWhatsApp;
    }

    return GestureDetector(
      onTap: canSend ? _sendToWhatsApp : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(28, tabletSize: 32),
          vertical: context.responsiveSize(14, tabletSize: 16),
        ),
        decoration: BoxDecoration(
          color: canSend ? const Color(0xFF25D366) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: canSend ? null : Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.send_rounded,
              color: canSend ? Colors.white : AppColors.textMuted,
              size: context.responsiveSize(18, tabletSize: 20),
            ),
            SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.responsiveTextStyle(
                  mobileSize: 14,
                  tabletSize: 15,
                  color: canSend ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
