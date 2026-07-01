import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_box.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_magnifier.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_overlay.dart';

class EditorVideoArea extends StatefulWidget {
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
  final bool isMuted;
  final VoidCallback onToggleMute;
  final VoidCallback? onOpenFullscreenCrop;

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
    required this.isMuted,
    required this.onToggleMute,
    this.onOpenFullscreenCrop,
  });

  @override
  State<EditorVideoArea> createState() => _EditorVideoAreaState();
}

class _EditorVideoAreaState extends State<EditorVideoArea> {
  Offset? _magnifierFocalPoint;
  bool _isResizing = false;
  ResizeHandle? _activeHandle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
        final videoRect = _calculateVideoRect(areaSize, widget.videoAspect);

        return Container(
          width: areaSize.width,
          height: areaSize.height,
          color: Colors.black,
          child: Stack(
            children: [
              if (widget.videoReady && widget.videoController != null)
                Positioned.fill(
                  child: Video(
                    controller: widget.videoController!,
                    controls: NoVideoControls,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.thumbnailPath != null)
                          Positioned.fill(
                            child: widget.thumbnailPath!.startsWith('http')
                                ? Image.network(
                                    widget.thumbnailPath!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(widget.thumbnailPath!),
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
                              widget.isBuffering
                                  ? context.l10n.editorSlowConnectionRetrying
                                  : _getLoadingText(context),
                              style: context.responsiveTextStyle(
                                mobileSize: 16,
                                tabletSize: 18,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!widget.isBuffering) ...[
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
                cropOffset: widget.cropOffset,
                cropSize: _getCropSize(
                  widget.cropWidth,
                  widget.aspectRatio,
                  widget.videoAspect,
                ),
                areaSize: areaSize,
                videoRect: videoRect,
              ),

              CropBox(
                offset: widget.cropOffset,
                cropWidth: widget.cropWidth,
                aspectRatio: widget.aspectRatio,
                videoAspect: widget.videoAspect,
                videoRect: videoRect,
                onChanged: widget.onCropChanged,
                onDragStart: () {
                  setState(() {
                    _isResizing = false;
                    _magnifierFocalPoint = null;
                    _activeHandle = null;
                  });
                },
                onResizeStart: () {
                  setState(() {
                    _isResizing = true;
                  });
                },
                onResizeHandleChanged: (handle) {
                  setState(() {
                    _activeHandle = handle;
                  });
                },
                onDragUpdate: (point) {
                  if (_isResizing) {
                    setState(() => _magnifierFocalPoint = point);
                  }
                },
                onDragEnd: () {
                  setState(() {
                    _magnifierFocalPoint = null;
                    _isResizing = false;
                    _activeHandle = null;
                  });
                },
              ),

              if (_magnifierFocalPoint != null &&
                  _isResizing &&
                  _activeHandle != null &&
                  widget.videoReady &&
                  widget.videoController != null)
                CropMagnifier(
                  videoController: widget.videoController!,
                  focalPoint: _magnifierFocalPoint!,
                  videoRect: videoRect,
                  areaSize: areaSize,
                  activeHandle: _activeHandle!,
                ),

              Positioned(
                top: context.responsiveSize(16, tabletSize: 20),
                right: context.responsiveSize(16, tabletSize: 20),
                child: GestureDetector(
                  onTap: widget.onTogglePlay,
                  child: Container(
                    width: context.responsiveSize(42, tabletSize: 46),
                    height: context.responsiveSize(42, tabletSize: 46),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      widget.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: context.responsiveSize(22, tabletSize: 24),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: context.responsiveSize(16, tabletSize: 20),
                right: context.responsiveSize(66, tabletSize: 72),
                child: GestureDetector(
                  onTap: widget.onToggleMute,
                  child: Container(
                    width: context.responsiveSize(42, tabletSize: 46),
                    height: context.responsiveSize(42, tabletSize: 46),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      widget.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: context.responsiveSize(22, tabletSize: 24),
                    ),
                  ),
                ),
              ),
              if (widget.onOpenFullscreenCrop != null)
                Positioned(
                  top: context.responsiveSize(16, tabletSize: 20),
                  right: context.responsiveSize(116, tabletSize: 124),
                  child: GestureDetector(
                    onTap: widget.onOpenFullscreenCrop,
                    child: Container(
                      width: context.responsiveSize(42, tabletSize: 46),
                      height: context.responsiveSize(42, tabletSize: 46),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(
                        Icons.fullscreen_rounded,
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
