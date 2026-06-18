import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';

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
    // Fondo oscuro con recorte
    final fill = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, fill);

    // Borde del recuadro con color accent
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Líneas de la cuadrícula 3x3
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
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.cropRect != cropRect;
}