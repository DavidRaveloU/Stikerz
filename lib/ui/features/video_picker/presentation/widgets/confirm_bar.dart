import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class ConfirmBar extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmBar({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.responsiveSize(16, tabletSize: 20),
          context.responsiveSize(8, tabletSize: 10),
          context.responsiveSize(16, tabletSize: 20),
          context.responsiveSize(16, tabletSize: 20),
        ),
        child: GestureDetector(
          onTap: onConfirm,
          child: Container(
            width: double.infinity,
            // Vertical padding keeps the button resilient to larger system fonts.
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveSize(16, tabletSize: 18),
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.background,
                  size: 20,
                ),
                SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
                Text(
                  context.l10n.useThisVideo,
                  style: context.responsiveTextStyle(
                    mobileSize: 15,
                    tabletSize: 16,
                    color: AppColors.background,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
