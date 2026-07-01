// lib/ui/features/image_editor/presentation/widgets/crop_toolbar.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/smart_crop_service.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';

/// Toolbar with crop type buttons.
class CropToolbar extends ConsumerWidget {
  final VoidCallback onFullscreenTap;
  final String imagePath;

  const CropToolbar({
    super.key,
    required this.onFullscreenTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);
    final canFullscreen = ref.watch(canUseFullscreenProvider);

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
              isSelected: state.selectedCrop == CropType.smart,
              onTap: () {
                if (!state.isSmartProcessing) {
                  _performSmartCrop(ref, context);
                }
              },
            ),
            const SizedBox(width: 6),
            _CropToolButton(
              icon: Icons.fullscreen_rounded,
              label: context.l10n.cropToolbarFullscreen,
              isSelected: false,
              enabled: canFullscreen,
              onTap: onFullscreenTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Procesa la imagen con ML Kit para eliminar el fondo y pre-visualizar.
  /// Se ejecuta en el hilo principal (ML Kit usa canales de plataforma).
  Future<void> _performSmartCrop(WidgetRef ref, BuildContext context) async {
    final notifier = ref.read(imageEditorProvider.notifier);

    // 1. Limpiar preview anterior inmediatamente
    notifier.clearSmartCrop();

    // 2. Seleccionar smart mode y mostrar spinner.
    notifier.setSelectedCrop(CropType.smart);
    notifier.setSmartProcessing(true);

    try {
      // 3. Pre-procesar la imagen: eliminar el fondo con ML Kit
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}${Platform.pathSeparator}smart_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await SmartCropService.preprocessSmartCrop(
        inputPath: imagePath,
        outputPath: outputPath,
      );

      if (result != null) {
        // 4. Guardar ruta del preview
        notifier.setSmartCropPreviewPath(result);
      } else {
        notifier.clearSmartCrop();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not detect subject. Try a different photo.'),
            ),
          );
        }
      }
    } catch (e) {
      notifier.clearSmartCrop();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Smart cutout error: $e')));
      }
    } finally {
      notifier.setSmartProcessing(false);
    }
  }
}

class _CropToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Si es false, el botón se muestra atenuado y no responde a toques.
  final bool enabled;

  // Ancho fijo suficiente para el texto más largo en cualquier idioma
  static const double _buttonWidth = 74.0;
  // Alto fijo para todos los botones
  static const double _buttonHeight = 56.0;

  const _CropToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Un botón deshabilitado nunca debe verse "seleccionado".
    final effectiveSelected = enabled && isSelected;

    final Color contentColor = !enabled
        ? AppColors.textMuted.withValues(alpha: 0.35)
        : (effectiveSelected ? AppColors.accent : AppColors.textMuted);

    final Color borderColor = !enabled
        ? AppColors.border.withValues(alpha: 0.25)
        : (effectiveSelected
              ? AppColors.accent
              : AppColors.border.withValues(alpha: 0.5));

    final Color bgColor = effectiveSelected
        ? AppColors.accent.withValues(alpha: 0.2)
        : Colors.transparent;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _buttonWidth,
        height: _buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: contentColor, size: 20),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9, height: 1.1, color: contentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
