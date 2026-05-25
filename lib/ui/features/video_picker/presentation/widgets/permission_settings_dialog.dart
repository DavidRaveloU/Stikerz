import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

/// Shows a guidance dialog when the OS blocks the native permission prompt.
///
/// This happens when access has been permanently denied and users must open
/// system settings manually.
Future<void> showPermissionSettingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => const PermissionSettingsDialog(),
  );
}

class PermissionSettingsDialog extends StatelessWidget {
  const PermissionSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(24, tabletSize: 48),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        padding: EdgeInsets.all(context.responsiveSize(24, tabletSize: 28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.responsiveSize(56, tabletSize: 64),
              height: context.responsiveSize(56, tabletSize: 64),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: AppColors.accent,
                size: context.responsiveSize(26, tabletSize: 30),
              ),
            ),
            SizedBox(height: context.responsiveSize(16, tabletSize: 20)),

            Text(
              context.l10n.permissionRequiredTitle,
              style: context.responsiveTextStyle(
                mobileSize: 17,
                tabletSize: 19,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(10, tabletSize: 12)),

            Text(
              context.l10n.permissionRequiredDesc,
              style: context.responsiveTextStyle(
                mobileSize: 13,
                tabletSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(16, tabletSize: 20)),

            _buildSteps(context),
            SizedBox(height: context.responsiveSize(22, tabletSize: 26)),

            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
                await PhotoManager.openSetting();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(15, tabletSize: 17),
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
                    Icon(
                      Icons.settings_rounded,
                      color: AppColors.background,
                      size: context.responsiveSize(16, tabletSize: 18),
                    ),
                    SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
                    Text(
                      context.l10n.openSettingsButton,
                      style: context.responsiveTextStyle(
                        mobileSize: 14,
                        tabletSize: 15,
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.responsiveSize(10, tabletSize: 12)),

            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(8, tabletSize: 10),
                ),
                child: Text(
                  context.l10n.cancel,
                  style: context.responsiveTextStyle(
                    mobileSize: 13,
                    tabletSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      context.l10n.permissionStep1,
      context.l10n.permissionStep2,
      context.l10n.permissionStep3,
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsiveSize(14, tabletSize: 16)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final isLast = i == steps.length - 1;
          return Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : context.responsiveSize(10, tabletSize: 12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.responsiveSize(22, tabletSize: 24),
                  height: context.responsiveSize(22, tabletSize: 24),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: context.responsiveTextStyle(
                        mobileSize: 11,
                        tabletSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.responsiveSize(10, tabletSize: 12)),
                Expanded(
                  child: Text(
                    steps[i],
                    style: context.responsiveTextStyle(
                      mobileSize: 12,
                      tabletSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
