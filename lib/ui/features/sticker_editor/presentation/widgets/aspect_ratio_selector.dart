import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';

enum AspectRatioOption {
  square('1:1', 1 / 1),
  fourThree('4:3', 4 / 3),
  sixteenNine('16:9', 16 / 9);

  final String label;
  final double ratio;
  const AspectRatioOption(this.label, this.ratio);
}

class AspectRatioSelector extends StatelessWidget {
  final AspectRatioOption selected;
  final ValueChanged<AspectRatioOption> onChanged;

  const AspectRatioSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AspectRatioOption.values.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(left: 5),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            child: Text(
              opt.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
