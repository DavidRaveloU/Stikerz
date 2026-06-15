import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class GenerationFailureModal extends StatelessWidget {
  final bool canRetry;
  final int? failedSizeBytes;
  final VoidCallback onRetryWithBlur;
  final VoidCallback onRetryWithReduceFps;
  final VoidCallback onRetryWithBlurAndReduceFps;
  final VoidCallback onRetryWithTransparency;
  final VoidCallback onClose;

  const GenerationFailureModal({
    super.key,
    required this.canRetry,
    this.failedSizeBytes,
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
        padding: EdgeInsets.all(context.responsiveSize(20, tabletSize: 24)),
        child: SingleChildScrollView(
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
              SizedBox(height: context.responsiveSize(6, tabletSize: 8)),
              Text(
                context.l10n.couldNotCreateSticker,
                style: context.responsiveTextStyle(
                  mobileSize: 16,
                  tabletSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.responsiveSize(10, tabletSize: 12)),
              Text(
                context.l10n.videoTooComplex,
                style: context.responsiveTextStyle(
                  mobileSize: 13,
                  tabletSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (failedSizeBytes != null) ...[
                SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
                _buildReductionMessage(context),
              ],
              SizedBox(height: context.responsiveSize(16, tabletSize: 18)),

              _tip(context, context.l10n.reduceSelectionArea),
              _tip(context, context.l10n.shortenClipDuration),
              SizedBox(height: context.responsiveSize(18, tabletSize: 20)),

              _strategyButton(
                context,
                context.l10n.blurReduceFps,
                context.l10n.blurMildTenFps,
                onRetryWithBlurAndReduceFps,
              ),
              _strategyButton(
                context,
                context.l10n.smoothDetails,
                context.l10n.applyMildBlur,
                onRetryWithBlur,
              ),
              _strategyButton(
                context,
                context.l10n.reduceFpsLabel,
                context.l10n.reduceTo10Fps,
                onRetryWithReduceFps,
              ),
              _strategyButton(
                context,
                context.l10n.moreTransparency,
                context.l10n.reduceVisibleArea,
                onRetryWithTransparency,
              ),

              if (canRetry)
                Padding(
                  padding: EdgeInsets.only(
                    top: context.responsiveSize(10, tabletSize: 12),
                  ),
                  child: Text(
                    context.l10n.tryAnotherStrategy,
                    style: context.responsiveTextStyle(
                      mobileSize: 12,
                      tabletSize: 13,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tip(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSize(4, tabletSize: 6),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 14, color: Colors.white54),
          SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
          Expanded(
            child: Text(
              text,
              style: context.responsiveTextStyle(
                mobileSize: 12,
                tabletSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strategyButton(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: context.responsiveSize(10, tabletSize: 12),
        ),
        padding: EdgeInsets.all(context.responsiveSize(12, tabletSize: 14)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
            SizedBox(width: context.responsiveSize(10, tabletSize: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.responsiveTextStyle(
                      mobileSize: 13,
                      tabletSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.responsiveTextStyle(
                      mobileSize: 11,
                      tabletSize: 12,
                      color: AppColors.textMuted,
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

  Widget _buildReductionMessage(BuildContext context) {
    const maxSizeBytes = 500 * 1024; // 500KB
    final reductionNeeded =
        ((failedSizeBytes! / 1024).round()) - (maxSizeBytes ~/ 1024);
    final reductionKB = reductionNeeded.clamp(
      0,
      reductionNeeded,
    ); // Asegurar que no sea negativo

    return Container(
      padding: EdgeInsets.all(context.responsiveSize(12, tabletSize: 14)),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Text(
        context.l10n.needToReduce(reductionKB),
        style: context.responsiveTextStyle(
          mobileSize: 12,
          tabletSize: 13,
          color: Colors.orange,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
