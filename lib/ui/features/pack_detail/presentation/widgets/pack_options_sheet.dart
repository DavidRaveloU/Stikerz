import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class PackOptionsSheet extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const PackOptionsSheet({
    super.key,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.responsiveSize(16, tabletSize: 20),
        0,
        context.responsiveSize(16, tabletSize: 20),
        context.responsiveSize(32, tabletSize: 36),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
          Container(
            width: context.responsiveSize(36, tabletSize: 40),
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
          _SheetOption(
            icon: Icons.drive_file_rename_outline_rounded,
            label: context.l10n.renamePack,
            onTap: onRename,
          ),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: context.l10n.deletePack,
            color: Colors.redAccent,
            onTap: onDelete,
          ),
          SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(20, tabletSize: 22),
          vertical: context.responsiveSize(14, tabletSize: 16),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: context.responsiveSize(20, tabletSize: 22)),
            SizedBox(width: context.responsiveSize(14, tabletSize: 16)),
            Text(
              label,
              style: context.responsiveTextStyle(
                mobileSize: 15,
                tabletSize: 16,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
