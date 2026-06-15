import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class VideoPickerTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const VideoPickerTopBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.responsiveSize(16, tabletSize: 20),
          context.responsiveSize(12, tabletSize: 14),
          context.responsiveSize(16, tabletSize: 20),
          context.responsiveSize(12, tabletSize: 14),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: context.responsiveSize(36, tabletSize: 40),
                height: context.responsiveSize(36, tabletSize: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
            ),
            SizedBox(width: context.responsiveSize(12, tabletSize: 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.selectedVideoLabel,
                    style: context.responsiveTextStyle(
                      mobileSize: 16,
                      tabletSize: 18,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    context.l10n.selectVideoHint,
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
}
