import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

import 'aspect_ratio_selector.dart';

class GenerateConfirmDialog extends StatelessWidget {
  final AspectRatioOption aspectRatio;
  final double startSecs;
  final double durationSecs;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const GenerateConfirmDialog({
    super.key,
    required this.aspectRatio,
    required this.startSecs,
    required this.durationSecs,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        context.l10n.generateStickerTitle,
        style: context.responsiveTextStyle(
          mobileSize: 17,
          tabletSize: 18,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ConfirmRow(
            label: context.l10n.aspectLabel,
            value: aspectRatio.label,
          ),
          _ConfirmRow(
            label: context.l10n.startLabel,
            value: _formatTime(startSecs),
          ),
          _ConfirmRow(
            label: context.l10n.durationShort,
            value: context.l10n.durationValue(durationSecs.toStringAsFixed(1)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            context.l10n.cancel,
            style: context.responsiveTextStyle(
              mobileSize: 14,
              tabletSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            context.l10n.generateButton,
            style: context.responsiveTextStyle(
              mobileSize: 14,
              tabletSize: 15,
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(double secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toStringAsFixed(1);
    return '$m:${s.padLeft(4, '0')}';
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.responsiveSize(4, tabletSize: 6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.responsiveTextStyle(
              mobileSize: 13,
              tabletSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: context.responsiveTextStyle(
              mobileSize: 13,
              tabletSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
