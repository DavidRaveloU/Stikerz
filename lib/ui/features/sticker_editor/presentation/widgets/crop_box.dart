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
  Offset? _startOffset;
  Offset? _startFocalPoint;
  double? _startWidth;
  bool? _isScaling;

  double get _height =>
      (widget.cropWidth * widget.videoAspect) / widget.aspectRatio.ratio;

  @override
  Widget build(BuildContext context) {
    final vr = widget.videoRect;
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
          widget.onDragStart?.call();
        },
        onScaleUpdate: (details) {
          if (vr.width <= 0 || vr.height <= 0) return;

          if (_isScaling == false) {
            final startOffset = _startOffset ?? widget.offset;
            final startFocal = _startFocalPoint ?? details.focalPoint;
            final delta = details.focalPoint - startFocal;
            final newOffset = Offset(
              startOffset.dx + delta.dx / vr.width,
              startOffset.dy + delta.dy / vr.height,
            );
            widget.onChanged(newOffset, widget.cropWidth);
            widget.onDragUpdate?.call(details.localFocalPoint);
          } else {
            const sensitivity = 0.2;
            final startWidth = _startWidth ?? widget.cropWidth;
            final adjustedScale = 1 + (details.scale - 1) * sensitivity;
            final newWidth = startWidth * adjustedScale;
            widget.onChanged(widget.offset, newWidth);
            widget.onDragUpdate?.call(details.localFocalPoint);
          }
        },
        onScaleEnd: (_) {
          _startOffset = null;
          _startWidth = null;
          _startFocalPoint = null;
          _isScaling = null;
          widget.onDragEnd?.call();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(color: Colors.transparent),
            _buildHandle(
              position: Offset(0, 0),
              handle: ResizeHandle.topLeft,
              vr: vr,
              cropLeft: left,
              cropTop: top,
              cropW: w,
              cropH: h,
            ),
            _buildHandle(
              position: Offset(w, 0),
              handle: ResizeHandle.topRight,
              vr: vr,
              cropLeft: left,
              cropTop: top,
              cropW: w,
              cropH: h,
            ),
            _buildHandle(
              position: Offset(0, h),
              handle: ResizeHandle.bottomLeft,
              vr: vr,
              cropLeft: left,
              cropTop: top,
              cropW: w,
              cropH: h,
            ),
            _buildHandle(
              position: Offset(w, h),
              handle: ResizeHandle.bottomRight,
              vr: vr,
              cropLeft: left,
              cropTop: top,
              cropW: w,
              cropH: h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle({
    required Offset position,
    required ResizeHandle handle,
    required Rect vr,
    required double cropLeft,
    required double cropTop,
    required double cropW,
    required double cropH,
  }) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: GestureDetector(
        onPanStart: (_) {
          widget.onResizeHandleChanged?.call(handle);
          widget.onResizeStart?.call();

          final cornerPosition = _getCornerPosition(
            handle,
            cropLeft,
            cropTop,
            cropW,
            cropH,
          );
          widget.onDragUpdate?.call(cornerPosition);
        },
        onPanUpdate: (details) {
          if (vr.width <= 0) return;

          final deltaX = details.delta.dx / vr.width;

          double newWidth = widget.cropWidth;
          double newOffsetX = widget.offset.dx;
          double newOffsetY = widget.offset.dy;

          switch (handle) {
            case ResizeHandle.topLeft:
              // Esquina 1: fijar esquina 4 (bottomRight)
              newWidth = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              newOffsetX = widget.offset.dx + (widget.cropWidth - newWidth);
              newOffsetY =
                  widget.offset.dy +
                  (widget.cropWidth - newWidth) * (_height / widget.cropWidth);
              break;

            case ResizeHandle.topRight:
              // Esquina 2: fijar esquina 3 (bottomLeft)
              newWidth = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              newOffsetX = widget.offset.dx;
              // La esquina inferior izquierda debe quedar fija, por lo tanto:
              // la esquina superior derecha se mueve, el offset Y debe ajustarse hacia abajo
              newOffsetY =
                  widget.offset.dy -
                  (newWidth - widget.cropWidth) * (_height / widget.cropWidth);
              break;

            case ResizeHandle.bottomLeft:
              // Esquina 3: fijar esquina 2 (topRight)
              newWidth = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              newOffsetX = widget.offset.dx + (widget.cropWidth - newWidth);
              newOffsetY = widget.offset.dy;
              break;

            case ResizeHandle.bottomRight:
              // Esquina 4: fijar esquina 1 (topLeft)
              newWidth = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              newOffsetX = widget.offset.dx;
              newOffsetY = widget.offset.dy;
              break;
          }

          // Asegurar que el offset no se salga de los límites
          final maxOffsetX = (1.0 - newWidth).clamp(0.0, 1.0);
          final maxOffsetY = (1.0 - _height).clamp(0.0, 1.0);

          newOffsetX = newOffsetX.clamp(0.0, maxOffsetX);
          newOffsetY = newOffsetY.clamp(0.0, maxOffsetY);

          widget.onChanged(Offset(newOffsetX, newOffsetY), newWidth);

          final newCropLeft = vr.left + (newOffsetX * vr.width);
          final newCropTop = vr.top + (newOffsetY * vr.height);
          final newCropW = newWidth * vr.width;
          final newCropH = _height * vr.height;

          final cornerPosition = _getCornerPosition(
            handle,
            newCropLeft,
            newCropTop,
            newCropW,
            newCropH,
          );
          widget.onDragUpdate?.call(cornerPosition);
        },
        onPanEnd: (_) {
          widget.onDragEnd?.call();
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
