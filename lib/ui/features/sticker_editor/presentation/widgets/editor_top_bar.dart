import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
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
            const SizedBox(width: 12),
            Text(
              context.l10n.stickerEditorTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
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
