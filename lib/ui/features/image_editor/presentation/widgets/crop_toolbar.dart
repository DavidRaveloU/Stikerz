import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';

/// Toolbar with crop type buttons.
class CropToolbar extends ConsumerWidget {
  final VoidCallback onFullscreenTap;

  const CropToolbar({super.key, required this.onFullscreenTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSize(6, tabletSize: 8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12, tabletSize: 16),
        ),
        child: Row(
          children: [
            _CropToolButton(
              icon: Icons.crop_square_rounded,
              label: context.l10n.cropTypeRectangle,
              isSelected: state.selectedCrop == CropType.square,
              onTap: () {
                ref
                    .read(imageEditorProvider.notifier)
                    .setSelectedCrop(CropType.square);
              },
            ),
            const SizedBox(width: 6),
            _CropToolButton(
              icon: Icons.circle_outlined,
              label: context.l10n.cropTypeCircle,
              isSelected: state.selectedCrop == CropType.circle,
              onTap: () {
                ref
                    .read(imageEditorProvider.notifier)
                    .setSelectedCrop(CropType.circle);
              },
            ),
            const SizedBox(width: 6),
            _CropToolButton(
              icon: Icons.gesture_rounded,
              label: context.l10n.cropTypeFreeForm,
              isSelected: state.selectedCrop == CropType.freeForm,
              onTap: () {
                ref
                    .read(imageEditorProvider.notifier)
                    .setSelectedCrop(CropType.freeForm);
              },
            ),
            const SizedBox(width: 6),
            _CropToolButton(
              icon: Icons.auto_fix_high_rounded,
              label: context.l10n.cropTypeSmart,
              isSelected: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.cropTypeSmartComingSoon)),
                );
              },
            ),
            const SizedBox(width: 6),
            _CropToolButton(
              icon: Icons.fullscreen_rounded,
              label: context.l10n.cropToolbarFullscreen,
              isSelected: false,
              onTap: onFullscreenTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _CropToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  // Ancho fijo suficiente para el texto más largo en cualquier idioma
  static const double _buttonWidth = 74.0;
  // Alto fijo para todos los botones
  static const double _buttonHeight = 56.0;

  const _CropToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _buttonWidth,
        height: _buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  height: 1.1,
                  color: isSelected ? AppColors.accent : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
