import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

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
            margin: EdgeInsets.only(
              left: context.responsiveSize(5, tabletSize: 6),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(9, tabletSize: 11),
              vertical: context.responsiveSize(5, tabletSize: 6),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : AppColors.border,
              ),
            ),
            child: Text(
              opt.label,
              style: context.responsiveTextStyle(
                mobileSize: 10,
                tabletSize: 11,
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
