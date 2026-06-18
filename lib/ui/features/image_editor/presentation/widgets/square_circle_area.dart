import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/crop_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';
import 'package:stikerz/ui/features/image_editor/presentation/widgets/crop_overlay_painter.dart';

/// Area for square or circular crop.
class SquareCircleArea extends ConsumerWidget {
  final String imagePath;
  final Rect imageRect;
  final CropType cropType;

  const SquareCircleArea({
    super.key,
    required this.imagePath,
    required this.imageRect,
    required this.cropType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);
    final notifier = ref.read(imageEditorProvider.notifier);

    final left = imageRect.left + (state.cropOffset.dx * imageRect.width);
    final top = imageRect.top + (state.cropOffset.dy * imageRect.height);
    final w = state.cropWidth * imageRect.width;
    final h = state.cropHeight * imageRect.height;

    final isCircle = cropType == CropType.circle;

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
        // Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: CropOverlayPainter(
              cropRect: Rect.fromLTWH(left, top, w, h),
              isCircle: isCircle,
            ),
          ),
        ),
        // Crop Box with handles
        _ImageCropBox(
          offset: state.cropOffset,
          cropWidth: state.cropWidth,
          imageAspect: state.imageAspect,
          imageRect: imageRect,
          onChanged: (offset, width) {
            // Aplicar normalización antes de actualizar
            final normalized = CropProvider.normalizeCrop(
              rawOffset: offset,
              rawWidth: width,
              imageAspect: state.imageAspect,
              aspectRatio: 1.0,
            );
            notifier.updateCrop(normalized.$1, normalized.$2);
          },
        ),
      ],
    );
  }
}

/// Internal crop box for images.
class _ImageCropBox extends StatefulWidget {
  final Offset offset;
  final double cropWidth;
  final double imageAspect;
  final Rect imageRect;
  final void Function(Offset offset, double width) onChanged;

  const _ImageCropBox({
    required this.offset,
    required this.cropWidth,
    required this.imageAspect,
    required this.imageRect,
    required this.onChanged,
  });

  @override
  State<_ImageCropBox> createState() => _ImageCropBoxState();
}

class _ImageCropBoxState extends State<_ImageCropBox> {
  Offset? _startOffset;
  Offset? _startFocalPoint;
  double? _startWidth;
  bool? _isScaling;

  double get _height => (widget.cropWidth * widget.imageAspect) / 1.0;

  @override
  Widget build(BuildContext context) {
    final vr = widget.imageRect;
    final left = vr.left + (widget.offset.dx * vr.width);
    final top = vr.top + (widget.offset.dy * vr.height);
    final w = widget.cropWidth * vr.width;
    final h = _height * vr.height;

    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: GestureDetector(
        onScaleStart: (details) {
          _startOffset = widget.offset;
          _startWidth = widget.cropWidth;
          _startFocalPoint = details.focalPoint;
          _isScaling = details.pointerCount >= 2;
        },
        onScaleUpdate: (details) {
          if (vr.width <= 0 || vr.height <= 0) return;
          if (_isScaling == false) {
            final startOff = _startOffset ?? widget.offset;
            final startF = _startFocalPoint ?? details.focalPoint;
            final delta = details.focalPoint - startF;
            widget.onChanged(
              Offset(
                startOff.dx + delta.dx / vr.width,
                startOff.dy + delta.dy / vr.height,
              ),
              widget.cropWidth,
            );
          } else {
            const sens = 0.2;
            final startW = _startWidth ?? widget.cropWidth;
            widget.onChanged(
              widget.offset,
              startW * (1 + (details.scale - 1) * sens),
            );
          }
        },
        onScaleEnd: (_) {
          _startOffset = null;
          _startWidth = null;
          _startFocalPoint = null;
          _isScaling = null;
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(color: Colors.transparent),
            _buildHandle(
              Offset(0, 0),
              1,
              left: left,
              top: top,
              w: w,
              h: h,
              vr: vr,
            ),
            _buildHandle(
              Offset(w, 0),
              2,
              left: left,
              top: top,
              w: w,
              h: h,
              vr: vr,
            ),
            _buildHandle(
              Offset(0, h),
              3,
              left: left,
              top: top,
              w: w,
              h: h,
              vr: vr,
            ),
            _buildHandle(
              Offset(w, h),
              4,
              left: left,
              top: top,
              w: w,
              h: h,
              vr: vr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(
    Offset position,
    int handle, {
    required double left,
    required double top,
    required double w,
    required double h,
    required Rect vr,
  }) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (vr.width <= 0) return;
          final deltaX = details.delta.dx / vr.width;
          double nw = widget.cropWidth,
              nox = widget.offset.dx,
              noy = widget.offset.dy;
          switch (handle) {
            case 1:
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy =
                  widget.offset.dy +
                  (widget.cropWidth - nw) * (_height / widget.cropWidth);
              break;
            case 2:
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy =
                  widget.offset.dy -
                  (nw - widget.cropWidth) * (_height / widget.cropWidth);
              break;
            case 3:
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy = widget.offset.dy;
              break;
            case 4:
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy = widget.offset.dy;
              break;
          }
          widget.onChanged(Offset(nox, noy), nw);
        },
        child: Container(
          width: 40,
          height: 40,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
