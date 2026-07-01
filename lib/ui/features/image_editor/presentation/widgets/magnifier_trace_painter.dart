import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';

/// Painter that draws the trace inside the magnifier.
class MagnifierTracePainter extends CustomPainter {
  final List<ui.Offset> points; // normalized 0-1
  final Rect imageRect;
  final ui.Offset focalPoint; // local to imageRect
  final double zoomFactor;
  final double magnifierSize;

  const MagnifierTracePainter({
    required this.points,
    required this.imageRect,
    required this.focalPoint,
    required this.zoomFactor,
    required this.magnifierSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final imgLeft = centerX - (focalPoint.dx * zoomFactor);
    final imgTop = centerY - (focalPoint.dy * zoomFactor);

    ui.Offset toMagnifier(ui.Offset p) {
      final px = imgLeft + p.dx * imageRect.width * zoomFactor;
      final py = imgTop + p.dy * imageRect.height * zoomFactor;
      return ui.Offset(px, py);
    }

    final path = Path();
    path.moveTo(toMagnifier(points.first).dx, toMagnifier(points.first).dy);
    for (var i = 1; i < points.length; i++) {
      final m = toMagnifier(points[i]);
      path.lineTo(m.dx, m.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Highlight start point
    final startM = toMagnifier(points.first);
    canvas.drawCircle(
      startM,
      5.0,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      startM,
      5.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant MagnifierTracePainter old) {
    return old.points != points || old.focalPoint != focalPoint;
  }
}
