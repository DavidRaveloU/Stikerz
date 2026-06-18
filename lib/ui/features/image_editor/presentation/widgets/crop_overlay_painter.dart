import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';

/// Painter that draws a dark overlay over the image with a crop area cut out.
class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final bool isCircle;

  const CropOverlayPainter({required this.cropRect, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    if (isCircle) {
      canvas.save();
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(
          Rect.fromCircle(center: cropRect.center, radius: cropRect.width / 2),
        )
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, fill);
      canvas.restore();

      canvas.drawCircle(
        cropRect.center,
        cropRect.width / 2,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      // Top
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), fill);
      // Bottom
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          cropRect.bottom,
          size.width,
          size.height - cropRect.bottom,
        ),
        fill,
      );
      // Left
      canvas.drawRect(
        Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
        fill,
      );
      // Right
      canvas.drawRect(
        Rect.fromLTWH(
          cropRect.right,
          cropRect.top,
          size.width - cropRect.right,
          cropRect.height,
        ),
        fill,
      );
      // Border
      canvas.drawRect(
        cropRect,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter old) {
    return old.cropRect != cropRect || old.isCircle != isCircle;
  }
}
