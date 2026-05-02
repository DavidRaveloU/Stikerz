import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

class GenerationFailureModal extends StatelessWidget {
  final bool canRetry;
  final VoidCallback onRetryWithBlur;
  final VoidCallback onRetryWithReduceFps;
  final VoidCallback onRetryWithBlurAndReduceFps;
  final VoidCallback onRetryWithTransparency;
  final VoidCallback onClose;

  const GenerationFailureModal({
    super.key,
    required this.canRetry,
    required this.onRetryWithBlur,
    required this.onRetryWithReduceFps,
    required this.onRetryWithBlurAndReduceFps,
    required this.onRetryWithTransparency,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.couldNotCreateSticker,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.videoTooComplex,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _tip(context.l10n.reduceSelectionArea),
            _tip(context.l10n.shortenClipDuration),
            const SizedBox(height: 18),

            _strategyButton(
              context.l10n.blurReduceFps,
              context.l10n.blurMildTenFps,
              onRetryWithBlurAndReduceFps,
            ),
            _strategyButton(
              context.l10n.smoothDetails,
              context.l10n.applyMildBlur,
              onRetryWithBlur,
            ),
            _strategyButton(
              context.l10n.reduceFpsLabel,
              context.l10n.reduceTo10Fps,
              onRetryWithReduceFps,
            ),
            _strategyButton(
              context.l10n.moreTransparency,
              context.l10n.reduceVisibleArea,
              onRetryWithTransparency,
            ),

            if (canRetry)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  context.l10n.tryAnotherStrategy,
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 14, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strategyButton(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
