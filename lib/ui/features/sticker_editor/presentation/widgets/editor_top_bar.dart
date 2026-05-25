import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

import 'aspect_ratio_selector.dart';

class EditorTopBar extends StatelessWidget {
  final AspectRatioOption selectedAspect;
  final ValueChanged<AspectRatioOption> onAspectChanged;
  final VoidCallback onBack;

  const EditorTopBar({
    super.key,
    required this.selectedAspect,
    required this.onAspectChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.responsiveSize(16, tabletSize: 20),
          context.responsiveSize(10, tabletSize: 12),
          context.responsiveSize(16, tabletSize: 20),
          0,
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
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textSecondary,
                  size: context.responsiveSize(16, tabletSize: 18),
                ),
              ),
            ),
            SizedBox(width: context.responsiveSize(12, tabletSize: 14)),
            Text(
              context.l10n.stickerEditorTitle,
              style: context.responsiveTextStyle(
                mobileSize: 16,
                tabletSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            AspectRatioSelector(
              selected: selectedAspect,
              onChanged: onAspectChanged,
            ),
          ],
        ),
      ),
    );
  }
}
