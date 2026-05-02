import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';
import 'package:whaticker/core/services/whatsapp_sticker_service.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: canSend ? Colors.white : AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
