import 'package:flutter/material.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';

class CropBox extends StatefulWidget {
  final Offset offset;
  final double cropWidth;
  final AspectRatioOption aspectRatio;
  final double videoAspect;
  final Rect videoRect;
  final Function(Offset offset, double width) onChanged;

  const CropBox({
    super.key,
    required this.offset,
    required this.cropWidth,
    required this.aspectRatio,
    required this.videoAspect,
    required this.videoRect,
    required this.onChanged,
  });

  @override
  State<CropBox> createState() => _CropBoxState();
}

class _CropBoxState extends State<CropBox> {
  Offset? _startOffset;
  Offset? _startFocalPoint;
  double? _startWidth;
  double? _handleWidth;

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

          // Lock gesture mode at start to avoid mixing move and scale.
          _isScaling = details.pointerCount >= 2;
        },

        onScaleUpdate: (details) {
          if (vr.width <= 0 || vr.height <= 0) return;

          // Keep handling only the initial gesture mode.
          if (_isScaling == false) {
            // Move mode.
            final startOffset = _startOffset ?? widget.offset;
            final startFocal = _startFocalPoint ?? details.focalPoint;

            final delta = details.focalPoint - startFocal;

            final newOffset = Offset(
              startOffset.dx + delta.dx / vr.width,
              startOffset.dy + delta.dy / vr.height,
            );

            widget.onChanged(newOffset, widget.cropWidth);
          } else {
            // Scale mode.
            const sensitivity = 0.2;

            final startWidth = _startWidth ?? widget.cropWidth;
            final adjustedScale = 1 + (details.scale - 1) * sensitivity;

            final newWidth = startWidth * adjustedScale;

            widget.onChanged(widget.offset, newWidth);
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

            Positioned(
              right: -20,
              bottom: -20,
              child: GestureDetector(
                onPanStart: (_) => _handleWidth = widget.cropWidth,
                onPanUpdate: (details) {
                  if (vr.width <= 0) return;

                  final current = _handleWidth ?? widget.cropWidth;
                  final newWidth = current + details.delta.dx / vr.width;

                  _handleWidth = newWidth;
                  widget.onChanged(widget.offset, newWidth);
                },
                child: Container(
                  width: context.responsiveSize(48, tabletSize: 52),
                  height: context.responsiveSize(48, tabletSize: 52),
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Container(
                    width: context.responsiveSize(26, tabletSize: 28),
                    height: context.responsiveSize(26, tabletSize: 28),
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
                    child: const Icon(
                      Icons.open_in_full_rounded,
                      size: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
