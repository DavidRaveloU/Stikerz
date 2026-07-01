import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/utils/image_cache_utils.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/crop_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/free_form_area.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/square_circle_area.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';

/// Preview of the image with crop overlay.
class ImagePreview extends ConsumerWidget {
  final String imagePath;
  final Size areaSize;

  const ImagePreview({
    super.key,
    required this.imagePath,
    required this.areaSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);
    final imageAspect = state.imageAspect;

    final imageRect = CropProvider.calculateImageRect(
      areaSize: areaSize,
      imageAspect: imageAspect,
    );

    if (state.selectedCrop == CropType.freeForm) {
      return FreeFormArea(
        imagePath: imagePath,
        imageRect: imageRect,
        areaSize: areaSize,
      );
    }

    if (state.selectedCrop == CropType.smart) {
      return _SmartCropPreview(
        imagePath: imagePath,
        previewPath: state.smartCropPreviewPath,
        imageRect: imageRect,
        isProcessing: state.isSmartProcessing,
      );
    }

    return SquareCircleArea(
      imagePath: imagePath,
      imageRect: imageRect,
      cropType: state.selectedCrop,
    );
  }
}

/// Preview del smart cutout: muestra la imagen original o la pre-procesada
/// si ya se completó la detección.
class _SmartCropPreview extends StatelessWidget {
  final String imagePath;
  final String? previewPath;
  final Rect imageRect;
  final bool isProcessing;

  const _SmartCropPreview({
    required this.imagePath,
    required this.previewPath,
    required this.imageRect,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    // CAMBIO: antes eran dos líneas con _cacheDimensionPx separado para
    // width y height. Ahora se calculan juntos para no deformar el
    // aspect ratio decodificado.
    final (cacheWidth, cacheHeight) = cacheDimensionsPx(
      context,
      imageRect.width,
      imageRect.height,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Imagen (original si no hay preview, o pre-procesada)
        Positioned.fromRect(
          rect: imageRect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(previewPath ?? imagePath),
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              filterQuality: FilterQuality.low,
            ),
          ),
        ),
        // Indicador de carga — usamos icono estático en vez de
        // CircularProgressIndicator para evitar congelamiento visual
        // cuando ML Kit procesa imágenes pesadas en el main thread.
        if (isProcessing)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      context.l10n.smartCropDetectingSubject,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Mensaje si no hay preview (falló detección)
        if (previewPath == null && !isProcessing)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.smartCropNoSubjectFallbackMessage,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
