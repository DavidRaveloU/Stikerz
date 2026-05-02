import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

class ConfirmBar extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmBar({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: GestureDetector(
          onTap: onConfirm,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
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
                const SizedBox(width: 8),
                Text(
                  context.l10n.useThisVideo,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 15,
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
