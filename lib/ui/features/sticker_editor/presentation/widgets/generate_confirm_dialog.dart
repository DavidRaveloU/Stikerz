import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';

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
      title: const Text(
        'Generar sticker',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ConfirmRow(label: 'Aspecto', value: aspectRatio.label),
          _ConfirmRow(label: 'Inicio', value: _formatTime(startSecs)),
          _ConfirmRow(
            label: 'Duración',
            value: '${durationSecs.toStringAsFixed(1)}s',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'Generar',
            style: TextStyle(
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
