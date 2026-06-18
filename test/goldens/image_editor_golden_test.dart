import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';

import '../golden_test_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock widget sin animaciones ni dependencias externas
// ─────────────────────────────────────────────────────────────────────────────

class _FakeImageEditorPage extends StatelessWidget {
  final CropType initialCrop;
  final List<ui.Offset> freeFormPoints;

  const _FakeImageEditorPage({
    this.initialCrop = CropType.square,
    this.freeFormPoints = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        leading: const Icon(Icons.close_rounded, color: Colors.white),
        title: const Text(
          'Edit Image',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _FakeEditorBody(
        initialCrop: initialCrop,
        freeFormPoints: freeFormPoints,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: Color(0xFF2E2E2E))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Generate Sticker',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeEditorBody extends StatefulWidget {
  final CropType initialCrop;
  final List<ui.Offset> freeFormPoints;

  const _FakeEditorBody({
    required this.initialCrop,
    required this.freeFormPoints,
  });

  @override
  State<_FakeEditorBody> createState() => _FakeEditorBodyState();
}

class _FakeEditorBodyState extends State<_FakeEditorBody> {
  late CropType _selectedCrop;
  late List<ui.Offset> _freeFormPoints;

  final Offset _cropOffset = const Offset(0.08, 0.10);
  final double _cropWidth = 0.76;
  final double _imageAspect = 4 / 3;

  @override
  void initState() {
    super.initState();
    _selectedCrop = widget.initialCrop;
    _freeFormPoints = List.from(widget.freeFormPoints);
  }

  double get _effectiveAspect => _imageAspect > 0 ? _imageAspect : 1.0;
  double get _cropHeight => (_cropWidth * _effectiveAspect) / 1.0;

  Rect _calculateImageRect(Size areaSize) {
    if (areaSize.width <= 0 || areaSize.height <= 0) return Rect.zero;
    final aspect = _effectiveAspect;
    final areaAspect = areaSize.width / areaSize.height;
    if (areaAspect > aspect) {
      final h = areaSize.height;
      final w = h * aspect;
      return Rect.fromLTWH((areaSize.width - w) / 2, 0, w, h);
    } else {
      final w = areaSize.width;
      final h = w / aspect;
      return Rect.fromLTWH(0, (areaSize.height - h) / 2, w, h);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolBar(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final areaSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final imageRect = _calculateImageRect(areaSize);

              if (_selectedCrop == CropType.freeForm) {
                return _buildFreeFormArea(imageRect);
              }
              return _buildSquareCircleArea(imageRect);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolBar() {
    const cropTypes = [
      (Icons.crop_square_rounded, 'Rectangle', CropType.square),
      (Icons.circle_outlined, 'Circle', CropType.circle),
      (Icons.gesture_rounded, 'Free', CropType.freeForm),
      (Icons.auto_fix_high_rounded, 'Smart', CropType.smart),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final (icon, label, type) in cropTypes) ...[
              _toolButton(
                icon,
                label,
                _selectedCrop == type && type != CropType.smart,
              ),
              const SizedBox(width: 6),
            ],
            const SizedBox(width: 6),
            _toolButton(Icons.fullscreen_rounded, 'Full', false),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? Colors.greenAccent : Colors.white24,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? Colors.greenAccent : Colors.white54,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected ? Colors.greenAccent : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeFormArea(Rect imageRect) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: imageRect,
          child: Container(
            color: Colors.blueGrey.shade800,
            child: const Center(
              child: Icon(Icons.image, color: Colors.white30, size: 48),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: imageRect,
          child: CustomPaint(
            size: Size(imageRect.width, imageRect.height),
            painter: _FreeFormCropPainterTest(
              points: _freeFormPoints
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
        if (_freeFormPoints.isEmpty)
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
      ],
    );
  }

  Widget _buildSquareCircleArea(Rect imageRect) {
    final left = imageRect.left + (_cropOffset.dx * imageRect.width);
    final top = imageRect.top + (_cropOffset.dy * imageRect.height);
    final w = _cropWidth * imageRect.width;
    final h = _cropHeight * imageRect.height;

    return Stack(
      children: [
        Positioned.fromRect(
          rect: imageRect,
          child: Container(
            color: Colors.blueGrey.shade800,
            child: const Center(
              child: Icon(Icons.image, color: Colors.white30, size: 48),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DimOverlayPainterTest(
              cropRect: Rect.fromLTWH(left, top, w, h),
              isCircle: _selectedCrop == CropType.circle,
            ),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters simplificados
// ─────────────────────────────────────────────────────────────────────────────

class _DimOverlayPainterTest extends CustomPainter {
  final Rect cropRect;
  final bool isCircle;
  const _DimOverlayPainterTest({required this.cropRect, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    if (isCircle) {
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(
          Rect.fromCircle(center: cropRect.center, radius: cropRect.width / 2),
        )
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, fill);
      canvas.drawCircle(
        cropRect.center,
        cropRect.width / 2,
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), fill);
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          cropRect.bottom,
          size.width,
          size.height - cropRect.bottom,
        ),
        fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
        fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          cropRect.right,
          cropRect.top,
          size.width - cropRect.right,
          cropRect.height,
        ),
        fill,
      );
      canvas.drawRect(
        cropRect,
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DimOverlayPainterTest o) =>
      o.cropRect != cropRect || o.isCircle != isCircle;
}

class _FreeFormCropPainterTest extends CustomPainter {
  final List<ui.Offset> points;
  const _FreeFormCropPainterTest({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final stroke = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _FreeFormCropPainterTest o) =>
      o.points != points;
}

// ─────────────────────────────────────────────────────────────────────────────
// TESTS
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setupGoldenTests();

  // ── Square crop (default) ─────────────────────────────────────────────────
  goldenTest(
    name: 'image_editor_square_crop',
    subdirectory: 'image_editor',
    builder: (_) => const _FakeImageEditorPage(initialCrop: CropType.square),
  );

  // ── Circle crop ───────────────────────────────────────────────────────────
  goldenTest(
    name: 'image_editor_circle_crop',
    subdirectory: 'image_editor',
    builder: (_) => const _FakeImageEditorPage(initialCrop: CropType.circle),
  );

  // ── Free-form – empty ────────────────────────────────────────────────────
  goldenTest(
    name: 'image_editor_freeform_empty',
    subdirectory: 'image_editor',
    builder: (_) => const _FakeImageEditorPage(
      initialCrop: CropType.freeForm,
      freeFormPoints: [],
    ),
  );

  // ── Free-form – closed triangle ──────────────────────────────────────────
  goldenTest(
    name: 'image_editor_freeform_triangle',
    subdirectory: 'image_editor',
    builder: (_) => _FakeImageEditorPage(
      initialCrop: CropType.freeForm,
      freeFormPoints: const [
        ui.Offset(0.5, 0.1),
        ui.Offset(0.8, 0.8),
        ui.Offset(0.2, 0.8),
        ui.Offset(0.5, 0.1),
      ],
    ),
  );

  // ── Dark theme ────────────────────────────────────────────────────────────
  goldenTest(
    name: 'image_editor_dark_square',
    subdirectory: 'image_editor',
    supportedThemes: const [Brightness.dark],
    supportMultipleDevices: false,
    builder: (_) => const _FakeImageEditorPage(initialCrop: CropType.square),
  );
}
