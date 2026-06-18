import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';

/// Painter that draws the free-form crop trace.
class FreeFormCropPainter extends CustomPainter {
  final List<ui.Offset> points;

  const FreeFormCropPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final strokePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Draw start point indicator
    final startPoint = points.first;
    canvas.drawCircle(
      startPoint,
      5.0,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      startPoint,
      5.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant FreeFormCropPainter old) {
    return old.points != points;
  }
}
