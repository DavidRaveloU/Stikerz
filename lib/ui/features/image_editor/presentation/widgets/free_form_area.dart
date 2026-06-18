import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/free_form_crop_painter.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/magnifier.dart';

/// Area for free-form drawing.
class FreeFormArea extends ConsumerWidget {
  final String imagePath;
  final Rect imageRect;
  final Size areaSize;

  const FreeFormArea({
    super.key,
    required this.imagePath,
    required this.imageRect,
    required this.areaSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);
    final notifier = ref.read(imageEditorProvider.notifier);

    final points = state.freeFormPoints;
    final isDrawing = state.isDrawing;
    final magnifierFocalPoint = state.magnifierFocalPoint;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Image
        Positioned.fromRect(
          rect: imageRect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
        ),
        // Drawing overlay
        Positioned.fromRect(
          rect: imageRect,
          child: GestureDetector(
            onPanStart: (details) {
              final localPoint = details.localPosition;
              notifier.startDrawing(localPoint);
              notifier.addFreeFormPoint(
                ui.Offset(
                  (localPoint.dx / imageRect.width).clamp(0.0, 1.0),
                  (localPoint.dy / imageRect.height).clamp(0.0, 1.0),
                ),
              );
            },
            onPanUpdate: (details) {
              final localPoint = details.localPosition;
              notifier.updateMagnifier(
                ui.Offset(
                  localPoint.dx.clamp(0.0, imageRect.width),
                  localPoint.dy.clamp(0.0, imageRect.height),
                ),
              );
              if (isDrawing) {
                notifier.addFreeFormPoint(
                  ui.Offset(
                    (localPoint.dx / imageRect.width).clamp(0.0, 1.0),
                    (localPoint.dy / imageRect.height).clamp(0.0, 1.0),
                  ),
                );
              }
            },
            onPanEnd: (_) {
              notifier.endDrawing();
            },
            child: CustomPaint(
              size: Size(imageRect.width, imageRect.height),
              painter: FreeFormCropPainter(
                points: points
                    .map(
                      (p) => ui.Offset(
                        p.dx * imageRect.width,
                        p.dy * imageRect.height,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        // Instructions
        if (points.isEmpty && !isDrawing)
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
                child: const Text(
                  'Trace the outline without lifting your finger',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        // Magnifier
        if (isDrawing && magnifierFocalPoint != null && points.length > 5)
          MagnifierZoom(
            imagePath: imagePath,
            imageRect: imageRect,
            areaSize: areaSize,
            focalPoint: magnifierFocalPoint,
            tracePoints: points,
          ),
      ],
    );
  }
}
