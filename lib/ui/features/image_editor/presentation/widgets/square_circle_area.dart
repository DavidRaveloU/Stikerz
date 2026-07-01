import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
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
    final cacheWidth = _cacheDimensionPx(context, imageRect.width);
    final cacheHeight = _cacheDimensionPx(context, imageRect.height);

    final left = imageRect.left + (state.cropOffset.dx * imageRect.width);
    final top = imageRect.top + (state.cropOffset.dy * imageRect.height);
    final w = state.cropWidth * imageRect.width;
    final h = state.cropHeight * imageRect.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Imagen
        Positioned.fromRect(
          rect: imageRect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              filterQuality: FilterQuality.low,
            ),
          ),
        ),
        // Overlay oscuro + borde del recuadro (dibujado UNA sola vez aquí)
        Positioned.fill(
          child: CustomPaint(
            painter: CropOverlayPainter(
              cropRect: Rect.fromLTWH(left, top, w, h),
              isCircle: cropType == CropType.circle,
            ),
          ),
        ),
        // Crop box: solo handles + gesto de movimiento, sin borde propio
        _ImageCropBox(
          offset: state.cropOffset,
          cropWidth: state.cropWidth,
          imageAspect: state.imageAspect,
          imageRect: imageRect,
          onChanged: notifier.updateCrop,
        ),
      ],
    );
  }
}

int _cacheDimensionPx(BuildContext context, double logicalSize) {
  final dpr = MediaQuery.of(context).devicePixelRatio;
  return (logicalSize * dpr).ceil().clamp(256, 2048).toInt();
}

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
  Offset? _dragStartOffset;
  Offset? _dragStartFocalPoint;

  double get _height => (widget.cropWidth * widget.imageAspect) / 1.0;

  @override
  Widget build(BuildContext context) {
    final vr = widget.imageRect;
    final left = vr.left + (widget.offset.dx * vr.width);
    final top = vr.top + (widget.offset.dy * vr.height);
    final w = widget.cropWidth * vr.width;
    final h = _height * vr.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Zona central de arrastre ─────────────────────────────────────
        Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (details) {
              if (details.pointerCount != 1) return;
              _dragStartOffset = widget.offset;
              _dragStartFocalPoint = details.focalPoint;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount != 1) return;
              if (_dragStartOffset == null || _dragStartFocalPoint == null)
                return;
              if (vr.width <= 0 || vr.height <= 0) return;

              final delta = details.focalPoint - _dragStartFocalPoint!;
              final newOffset = Offset(
                _dragStartOffset!.dx + delta.dx / vr.width,
                _dragStartOffset!.dy + delta.dy / vr.height,
              );

              final maxOffsetX = (1.0 - widget.cropWidth).clamp(0.0, 1.0);
              final maxOffsetY = (1.0 - _height).clamp(0.0, 1.0);
              final clampedOffset = Offset(
                newOffset.dx.clamp(0.0, maxOffsetX),
                newOffset.dy.clamp(0.0, maxOffsetY),
              );

              widget.onChanged(clampedOffset, widget.cropWidth);
            },
            onScaleEnd: (_) {
              _dragStartOffset = null;
              _dragStartFocalPoint = null;
            },
            child: const SizedBox.expand(),
          ),
        ),

        // ── Handles de esquina ───────────────────────────────────────────
        _buildHandle(position: Offset(left, top), handle: 1, vr: vr),
        _buildHandle(position: Offset(left + w, top), handle: 2, vr: vr),
        _buildHandle(position: Offset(left, top + h), handle: 3, vr: vr),
        _buildHandle(position: Offset(left + w, top + h), handle: 4, vr: vr),
      ],
    );
  }

  Widget _buildHandle({
    required Offset position,
    required int handle,
    required Rect vr,
  }) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          if (vr.width <= 0) return;
          final deltaX = details.delta.dx / vr.width;
          double nw = widget.cropWidth,
              nox = widget.offset.dx,
              noy = widget.offset.dy;

          switch (handle) {
            case 1: // top-left
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy =
                  widget.offset.dy +
                  (widget.cropWidth - nw) * (_height / widget.cropWidth);
              break;
            case 2: // top-right
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy =
                  widget.offset.dy -
                  (nw - widget.cropWidth) * (_height / widget.cropWidth);
              break;
            case 3: // bottom-left
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy = widget.offset.dy;
              break;
            case 4: // bottom-right
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy = widget.offset.dy;
              break;
          }

          final newHeight = (nw * widget.imageAspect).clamp(0.0, 1.0);
          final maxOffsetX = (1.0 - nw).clamp(0.0, 1.0);
          final maxOffsetY = (1.0 - newHeight).clamp(0.0, 1.0);
          widget.onChanged(
            Offset(nox.clamp(0.0, maxOffsetX), noy.clamp(0.0, maxOffsetY)),
            nw,
          );
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
