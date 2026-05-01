import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/crop_box.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/crop_overlay.dart';

class EditorVideoArea extends StatelessWidget {
  final VideoController videoController;
  final bool videoReady;
  final Offset cropOffset;
  final double cropWidth;
  final AspectRatioOption aspectRatio;
  final double videoAspect;
  final Function(Offset offset, double width) onCropChanged;
  final VoidCallback onTogglePlay;
  final bool isPlaying;

  const EditorVideoArea({
    super.key,
    required this.videoController,
    required this.videoReady,
    required this.cropOffset,
    required this.cropWidth,
    required this.aspectRatio,
    required this.videoAspect,
    required this.onCropChanged,
    required this.onTogglePlay,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
        final videoRect = _calculateVideoRect(areaSize, videoAspect);

        return Container(
          width: areaSize.width,
          height: areaSize.height,
          color: Colors.black,
          child: Stack(
            children: [
              // Video Player
              if (videoReady)
                Positioned.fill(
                  child: Video(
                    controller: videoController,
                    controls: NoVideoControls,
                    fit: BoxFit.contain,
                  ),
                )
              else
                // Loading mejorado para Instagram
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 3.5,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Cargando video...',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Esto puede tardar unos segundos con Instagram',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Overlay de crop
              CropOverlay(
                cropOffset: cropOffset,
                cropSize: _getCropSize(cropWidth, aspectRatio, videoAspect),
                areaSize: areaSize,
                videoRect: videoRect,
              ),

              // Crop Box interactivo
              CropBox(
                offset: cropOffset,
                cropWidth: cropWidth,
                aspectRatio: aspectRatio,
                videoAspect: videoAspect,
                videoRect: videoRect,
                onChanged: onCropChanged,
              ),

              // Botón Play/Pause
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: onTogglePlay,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Size _getCropSize(double width, AspectRatioOption ratio, double videoAspect) {
    final height = (width * videoAspect) / ratio.ratio;
    return Size(width, height);
  }

  Rect _calculateVideoRect(Size areaSize, double videoAspect) {
    if (areaSize.width <= 0 || areaSize.height <= 0) return Rect.zero;

    final areaAspect = areaSize.width / areaSize.height;

    if (areaAspect > videoAspect) {
      final height = areaSize.height;
      final width = height * videoAspect;
      final left = (areaSize.width - width) / 2;
      return Rect.fromLTWH(left, 0, width, height);
    } else {
      final width = areaSize.width;
      final height = width / videoAspect;
      final top = (areaSize.height - height) / 2;
      return Rect.fromLTWH(0, top, width, height);
    }
  }
}
