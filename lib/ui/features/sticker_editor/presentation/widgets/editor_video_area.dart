import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_box.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_overlay.dart';

class EditorVideoArea extends StatelessWidget {
  final VideoController? videoController;
  final bool videoReady;
  final bool isBuffering;
  final String? thumbnailPath;
  final Offset cropOffset;
  final double cropWidth;
  final AspectRatioOption aspectRatio;
  final double videoAspect;
  final Function(Offset offset, double width) onCropChanged;
  final VoidCallback onTogglePlay;
  final bool isPlaying;

  const EditorVideoArea({
    super.key,
    this.videoController,
    required this.videoReady,
    this.isBuffering = false,
    this.thumbnailPath,
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
              if (videoReady && videoController != null)
                Positioned.fill(
                  child: Video(
                    controller: videoController!,
                    controls: NoVideoControls,
                    fit: BoxFit.contain,
                  ),
                )
              else
                // Show thumbnail if available so user sees immediate feedback.
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (thumbnailPath != null)
                          Positioned.fill(
                            child: thumbnailPath!.startsWith('http')
                                ? Image.network(
                                    thumbnailPath!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(thumbnailPath!),
                                    fit: BoxFit.cover,
                                  ),
                          )
                        else
                          const SizedBox(),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: context.responsiveSize(36, tabletSize: 40),
                              height: context.responsiveSize(
                                36,
                                tabletSize: 40,
                              ),
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                                strokeWidth: 3.5,
                              ),
                            ),
                            SizedBox(
                              height: context.responsiveSize(
                                12,
                                tabletSize: 14,
                              ),
                            ),
                            Text(
                              isBuffering
                                  ? 'Conexión lenta — reintentando…'
                                  : _getLoadingText(context),
                              style: context.responsiveTextStyle(
                                mobileSize: 16,
                                tabletSize: 18,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!isBuffering) ...[
                              SizedBox(
                                height: context.responsiveSize(
                                  6,
                                  tabletSize: 8,
                                ),
                              ),
                              Text(
                                _getLoadingNote(context),
                                style: context.responsiveTextStyle(
                                  mobileSize: 13,
                                  tabletSize: 14,
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              CropOverlay(
                cropOffset: cropOffset,
                cropSize: _getCropSize(cropWidth, aspectRatio, videoAspect),
                areaSize: areaSize,
                videoRect: videoRect,
              ),

              CropBox(
                offset: cropOffset,
                cropWidth: cropWidth,
                aspectRatio: aspectRatio,
                videoAspect: videoAspect,
                videoRect: videoRect,
                onChanged: onCropChanged,
              ),

              Positioned(
                top: context.responsiveSize(16, tabletSize: 20),
                right: context.responsiveSize(16, tabletSize: 20),
                child: GestureDetector(
                  onTap: onTogglePlay,
                  child: Container(
                    width: context.responsiveSize(42, tabletSize: 46),
                    height: context.responsiveSize(42, tabletSize: 46),
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
                      size: context.responsiveSize(22, tabletSize: 24),
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

  String _getLoadingText(BuildContext context) {
    try {
      return context.l10n.loadingVideo;
    } catch (_) {
      return 'Loading video...';
    }
  }

  String _getLoadingNote(BuildContext context) {
    try {
      return context.l10n.instagramLoadingNote;
    } catch (_) {
      return 'This may take a few seconds';
    }
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
