import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/crop_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/free_form_area.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/square_circle_area.dart';

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

    return SquareCircleArea(
      imagePath: imagePath,
      imageRect: imageRect,
      cropType: state.selectedCrop,
    );
  }
}
