import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stikerz/core/constants/app_colors.dart';

import 'crop_box.dart';

class CropMagnifier extends StatelessWidget {
  final VideoController videoController;
  final Offset focalPoint;
  final Rect videoRect;
  final Size areaSize;
  final ResizeHandle activeHandle;

  static const double diameter = 120;
  static const double zoomFactor = 2.5;
  static const double margin = 16;

  const CropMagnifier({
    super.key,
    required this.videoController,
    required this.focalPoint,
    required this.videoRect,
    required this.areaSize,
    required this.activeHandle,
  });

  @override
  Widget build(BuildContext context) {
    if (videoRect.width <= 0 || videoRect.height <= 0) {
      return const SizedBox.shrink();
    }

    final position = _resolveOppositePosition();

    final fx = ((focalPoint.dx - videoRect.left) / videoRect.width).clamp(
      0.0,
      1.0,
    );
    final fy = ((focalPoint.dy - videoRect.top) / videoRect.height).clamp(
      0.0,
      1.0,
    );

    final zoomedWidth = videoRect.width * zoomFactor;
    final zoomedHeight = videoRect.height * zoomFactor;

    final dx = (diameter / 2) - (fx * zoomedWidth);
    final dy = (diameter / 2) - (fy * zoomedHeight);

    return Positioned(
      left: position.dx - diameter / 2,
      top: position.dy,
      child: IgnorePointer(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                Container(color: Colors.black),
                Positioned(
                  left: dx,
                  top: dy,
                  width: zoomedWidth,
                  height: zoomedHeight,
                  child: Video(
                    controller: videoController,
                    controls: NoVideoControls,
                    fit: BoxFit.fill,
                  ),
                ),
                Center(
                  child: Container(
                    width: 1,
                    height: diameter,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                Center(
                  child: Container(
                    width: diameter,
                    height: 1,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                Center(
                  child: Container(
                    width: diameter - 20,
                    height: diameter - 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular((diameter - 20) / 2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _resolveOppositePosition() {
    double dx = focalPoint.dx;
    double dy = focalPoint.dy;

    final minX = diameter / 2 + margin;
    final maxX = areaSize.width - diameter / 2 - margin;

    final minY = margin;
    final maxY = areaSize.height - diameter - margin;

    switch (activeHandle) {
      case ResizeHandle.topLeft:
        dx = (dx + areaSize.width / 2).clamp(minX, maxX);
        dy = (dy + areaSize.height / 2).clamp(minY, maxY);
        break;
      case ResizeHandle.topRight:
        dx = (dx - areaSize.width / 2).clamp(minX, maxX);
        dy = (dy + areaSize.height / 2).clamp(minY, maxY);
        break;
      case ResizeHandle.bottomLeft:
        dx = (dx + areaSize.width / 2).clamp(minX, maxX);
        dy = (dy - areaSize.height / 2).clamp(minY, maxY);
        break;
      case ResizeHandle.bottomRight:
        dx = (dx - areaSize.width / 2).clamp(minX, maxX);
        dy = (dy - areaSize.height / 2).clamp(minY, maxY);
        break;
    }

    return Offset(dx, dy);
  }
}
