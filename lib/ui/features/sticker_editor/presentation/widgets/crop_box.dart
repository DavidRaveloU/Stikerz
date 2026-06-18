import 'package:flutter/material.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';

enum ResizeHandle { topLeft, topRight, bottomLeft, bottomRight }

class CropBox extends StatefulWidget {
  final Offset offset;
  final double cropWidth;
  final AspectRatioOption aspectRatio;
  final double videoAspect;
  final Rect videoRect;
  final Function(Offset offset, double width) onChanged;

  final VoidCallback? onDragStart;
  final VoidCallback? onResizeStart;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<ResizeHandle>? onResizeHandleChanged;
  final VoidCallback? onDragEnd;

  const CropBox({
    super.key,
    required this.offset,
    required this.cropWidth,
    required this.aspectRatio,
    required this.videoAspect,
    required this.videoRect,
    required this.onChanged,
    this.onDragStart,
    this.onResizeStart,
    this.onDragUpdate,
    this.onResizeHandleChanged,
    this.onDragEnd,
  });

  @override
  State<CropBox> createState() => _CropBoxState();
}

class _CropBoxState extends State<CropBox> {
  Offset? _dragStartOffset;
  Offset? _dragStartFocalPoint;

  double get _height =>
      (widget.cropWidth * widget.videoAspect) / widget.aspectRatio.ratio;

  @override
  Widget build(BuildContext context) {
    final vr = widget.videoRect;
    final left = vr.left + (widget.offset.dx * vr.width);
    final top = vr.top + (widget.offset.dy * vr.height);
    final w = widget.cropWidth * vr.width;
    final h = _height * vr.height;

    // Sin Positioned.fromRect envolviendo: este Stack se coloca directo
    // dentro del Stack de EditorVideoArea, igual que _ImageCropBox.
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
              widget.onDragStart?.call();
            },
            onScaleUpdate: (details) {
              if (details.pointerCount != 1) return;
              if (_dragStartOffset == null || _dragStartFocalPoint == null) {
                return;
              }
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
              widget.onDragUpdate?.call(details.localFocalPoint);
            },
            onScaleEnd: (_) {
              _dragStartOffset = null;
              _dragStartFocalPoint = null;
              widget.onDragEnd?.call();
            },
            child: const SizedBox.expand(),
          ),
        ),

        // ── Handles de esquina ───────────────────────────────────────────
        _buildHandle(
          position: Offset(left, top),
          handle: ResizeHandle.topLeft,
          vr: vr,
        ),
        _buildHandle(
          position: Offset(left + w, top),
          handle: ResizeHandle.topRight,
          vr: vr,
        ),
        _buildHandle(
          position: Offset(left, top + h),
          handle: ResizeHandle.bottomLeft,
          vr: vr,
        ),
        _buildHandle(
          position: Offset(left + w, top + h),
          handle: ResizeHandle.bottomRight,
          vr: vr,
        ),
      ],
    );
  }

  Widget _buildHandle({
    required Offset position,
    required ResizeHandle handle,
    required Rect vr,
  }) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          widget.onResizeHandleChanged?.call(handle);
          widget.onResizeStart?.call();
          widget.onDragUpdate?.call(position);
        },
        onPanUpdate: (details) {
          if (vr.width <= 0) return;
          final deltaX = details.delta.dx / vr.width;
          double nw = widget.cropWidth,
              nox = widget.offset.dx,
              noy = widget.offset.dy;

          switch (handle) {
            case ResizeHandle.topLeft:
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy =
                  widget.offset.dy +
                  (widget.cropWidth - nw) * (_height / widget.cropWidth);
              break;
            case ResizeHandle.topRight:
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy =
                  widget.offset.dy -
                  (nw - widget.cropWidth) * (_height / widget.cropWidth);
              break;
            case ResizeHandle.bottomLeft:
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy = widget.offset.dy;
              break;
            case ResizeHandle.bottomRight:
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy = widget.offset.dy;
              break;
          }

          final maxOffsetX = (1.0 - nw).clamp(0.0, 1.0);
          final maxOffsetY = (1.0 - _height).clamp(0.0, 1.0);
          widget.onChanged(
            Offset(nox.clamp(0.0, maxOffsetX), noy.clamp(0.0, maxOffsetY)),
            nw,
          );

          final newLeft = vr.left + (nox * vr.width);
          final newTop = vr.top + (noy * vr.height);
          final newW = nw * vr.width;
          final newH = _height * vr.height;

          final cornerPosition = _getCornerPosition(
            handle,
            newLeft,
            newTop,
            newW,
            newH,
          );
          widget.onDragUpdate?.call(cornerPosition);
        },
        onPanEnd: (_) {
          widget.onDragEnd?.call();
        },
        // 60x60 de área táctil — más grande que el círculo de 24x24,
        // así no se necesita precisión para agarrar la esquina.
        child: Container(
          width: 40,
          height: 40,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
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

  Offset _getCornerPosition(
    ResizeHandle handle,
    double cropLeft,
    double cropTop,
    double cropW,
    double cropH,
  ) {
    switch (handle) {
      case ResizeHandle.topLeft:
        return Offset(cropLeft, cropTop);
      case ResizeHandle.topRight:
        return Offset(cropLeft + cropW, cropTop);
      case ResizeHandle.bottomLeft:
        return Offset(cropLeft, cropTop + cropH);
      case ResizeHandle.bottomRight:
        return Offset(cropLeft + cropW, cropTop + cropH);
    }
  }
}
