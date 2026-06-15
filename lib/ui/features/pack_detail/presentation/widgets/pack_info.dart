import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

class PackInfo extends StatelessWidget {
  final StickerPackModel pack;

  const PackInfo({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: context.l10n.packInfoName, value: pack.name),
        _InfoRow(label: context.l10n.packInfoAuthor, value: pack.author),
        _InfoRow(
          label: context.l10n.packInfoStickersAdded,
          value: context.l10n.stickerCountSimple(pack.filledCount),
        ),
        _InfoRow(
          label: context.l10n.packInfoCover,
          value: pack.hasCover
              ? context.l10n.coverConfigured
              : context.l10n.noCover,
          valueColor: pack.hasCover ? AppColors.accent : Colors.redAccent,
        ),
        _InfoRow(
          label: context.l10n.packInfoStatus,
          value: pack.isFull
              ? context.l10n.statusComplete
              : context.l10n.statusInProgress,
          valueColor: pack.isFull ? AppColors.accent : AppColors.textSecondary,
        ),
        _InfoRow(
          label: context.l10n.packInfoCreated,
          value: _formatDate(pack.createdAt),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSize(14, tabletSize: 16),
        horizontal: context.responsiveSize(16, tabletSize: 18),
      ),
      margin: EdgeInsets.only(
        bottom: context.responsiveSize(8, tabletSize: 10),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: context.responsiveTextStyle(
                mobileSize: 13,
                tabletSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(width: context.responsiveSize(8)),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 0, maxWidth: 160),
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: context.responsiveTextStyle(
                  mobileSize: 13,
                  tabletSize: 14,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
