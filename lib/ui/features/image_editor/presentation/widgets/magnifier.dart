import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/magnifier_trace_painter.dart';

/// A magnifier widget that shows a zoomed-in view of the image at the focal point.
class MagnifierZoom extends StatelessWidget {
  final String imagePath;
  final Rect imageRect;
  final Size areaSize;
  final ui.Offset focalPoint; // local to imageRect
  final List<ui.Offset> tracePoints; // normalized 0-1

  static const double diameter = 120.0;
  static const double zoomFactor = 2.5;
  static const double margin = 16.0;

  const MagnifierZoom({
    super.key,
    required this.imagePath,
    required this.imageRect,
    required this.areaSize,
    required this.focalPoint,
    this.tracePoints = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (imageRect.isEmpty) return const SizedBox.shrink();

    final absX = imageRect.left + focalPoint.dx;
    final absY = imageRect.top + focalPoint.dy;

    final mx = absX.clamp(
      diameter / 2 + margin,
      areaSize.width - diameter / 2 - margin,
    );
    final my = (absY - diameter - margin).clamp(
      margin,
      areaSize.height - diameter - margin,
    );

    final fx = (focalPoint.dx / imageRect.width).clamp(0.0, 1.0);
    final fy = (focalPoint.dy / imageRect.height).clamp(0.0, 1.0);

    return Positioned(
      left: mx - diameter / 2,
      top: my,
      child: IgnorePointer(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                Container(color: Colors.black),
                Positioned(
                  left: (diameter / 2) - (fx * imageRect.width * zoomFactor),
                  top: (diameter / 2) - (fy * imageRect.height * zoomFactor),
                  width: imageRect.width * zoomFactor,
                  height: imageRect.height * zoomFactor,
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
                // Crosshair
                Center(
                  child: Container(
                    width: 1,
                    height: diameter,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                Center(
                  child: Container(
                    width: diameter,
                    height: 1,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                // Trace overlay
                if (tracePoints.isNotEmpty)
                  CustomPaint(
                    size: Size(diameter, diameter),
                    painter: MagnifierTracePainter(
                      points: tracePoints,
                      imageRect: imageRect,
                      focalPoint: focalPoint,
                      zoomFactor: zoomFactor,
                      magnifierSize: diameter,
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
