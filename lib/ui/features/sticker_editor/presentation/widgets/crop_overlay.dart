import 'package:flutter/material.dart';

class CropOverlay extends StatelessWidget {
  final Offset cropOffset;
  final Size cropSize;
  final Size areaSize;
  final Rect videoRect;

  const CropOverlay({
    super.key,
    required this.cropOffset,
    required this.cropSize,
    required this.areaSize,
    required this.videoRect,
  });

  @override
  Widget build(BuildContext context) {
    final left = videoRect.left + (cropOffset.dx * videoRect.width);
    final top = videoRect.top + (cropOffset.dy * videoRect.height);
    final w = cropSize.width * videoRect.width;
    final h = cropSize.height * videoRect.height;

    return CustomPaint(
      size: areaSize,
      painter: _OverlayPainter(Rect.fromLTWH(left, top, w, h)),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect cropRect;

  _OverlayPainter(this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Draw crop outline.
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, borderPaint);

    // Draw 3x3 composition grid.
    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.5;

    for (int i = 1; i < 3; i++) {
      final x = cropRect.left + (cropRect.width / 3) * i;
      final y = cropRect.top + (cropRect.height / 3) * i;
      canvas.drawLine(
        Offset(x, cropRect.top),
        Offset(x, cropRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(cropRect.left, y),
        Offset(cropRect.right, y),
        gridPaint,
      );
    }

    // Highlight crop corners.
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cLen = size.shortestSide < 360 ? 14.0 : 16.0;
    final corners = [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
    ];

    for (final corner in corners) {
      final isLeft = corner.dx == cropRect.left;
      final isTop = corner.dy == cropRect.top;

      canvas.drawLine(
        corner,
        corner + Offset(isLeft ? cLen : -cLen, 0),
        cornerPaint,
      );
      canvas.drawLine(
        corner,
        corner + Offset(0, isTop ? cLen : -cLen),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.cropRect != cropRect;
}
