import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/utils/image_cache_utils.dart';
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

    final tracedAnchor = tracePoints.isNotEmpty
        ? ui.Offset(
            (tracePoints.last.dx * imageRect.width).clamp(0.0, imageRect.width),
            (tracePoints.last.dy * imageRect.height).clamp(
              0.0,
              imageRect.height,
            ),
          )
        : null;

    final clampedFocalPoint =
        tracedAnchor ??
        ui.Offset(
          focalPoint.dx.clamp(0.0, imageRect.width),
          focalPoint.dy.clamp(0.0, imageRect.height),
        );

    // FIX: antes se calculaban cacheWidth y cacheHeight por separado,
    // cada uno con su propio clamp a maxPx. Con imágenes no cuadradas
    // eso podía deformar el aspect ratio del bitmap decodificado y
    // desfasar visualmente el contenido de la lupa respecto al dedo.
    // Ahora se calculan juntos, preservando la proporción real.
    final (cacheWidth, cacheHeight) = cacheDimensionsPx(
      context,
      imageRect.width * zoomFactor,
      imageRect.height * zoomFactor,
      maxPx: 1536,
    );

    final absX = imageRect.left + clampedFocalPoint.dx;
    final absY = imageRect.top + clampedFocalPoint.dy;

    final mx = absX.clamp(
      diameter / 2 + margin,
      areaSize.width - diameter / 2 - margin,
    );
    final my = (absY - diameter - margin).clamp(
      margin,
      areaSize.height - diameter - margin,
    );

    final imageZoomWidth = imageRect.width * zoomFactor;
    final imageZoomHeight = imageRect.height * zoomFactor;
    final imageLeft = (diameter / 2) - (clampedFocalPoint.dx * zoomFactor);
    final imageTop = (diameter / 2) - (clampedFocalPoint.dy * zoomFactor);

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
                  left: imageLeft,
                  top: imageTop,
                  width: imageZoomWidth,
                  height: imageZoomHeight,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    cacheWidth: cacheWidth,
                    cacheHeight: cacheHeight,
                    filterQuality: FilterQuality.low,
                  ),
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
                      focalPoint: clampedFocalPoint,
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
