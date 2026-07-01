import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_box.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_magnifier.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/crop_overlay.dart';

class FullscreenCropPage extends StatefulWidget {
  final VideoController videoController;
  final Offset initialOffset;
  final double initialCropWidth;
  final AspectRatioOption aspectRatio;
  final double videoAspect;

  const FullscreenCropPage({
    super.key,
    required this.videoController,
    required this.initialOffset,
    required this.initialCropWidth,
    required this.aspectRatio,
    required this.videoAspect,
  });

  @override
  State<FullscreenCropPage> createState() => _FullscreenCropPageState();
}

class _FullscreenCropPageState extends State<FullscreenCropPage> {
  late Offset _cropOffset;
  late double _cropWidth;
  Offset? _magnifierFocalPoint;
  bool _isResizing = false;
  ResizeHandle? _activeHandle;

  @override
  void initState() {
    super.initState();
    _cropOffset = widget.initialOffset;
    _cropWidth = widget.initialCropWidth;
  }

  double get _height =>
      (_cropWidth * widget.videoAspect) / widget.aspectRatio.ratio;

  (Offset, double) _normalizeCrop(Offset rawOffset, double rawWidth) {
    final safeAspect = widget.videoAspect > 0 ? widget.videoAspect : 1.0;
    double safeWidth = rawWidth.clamp(0.15, 1.0);
    double safeHeight = (safeWidth * safeAspect) / widget.aspectRatio.ratio;

    if (safeHeight > 1.0) {
      safeHeight = 1.0;
      safeWidth = (safeHeight * widget.aspectRatio.ratio / safeAspect).clamp(
        0.15,
        1.0,
      );
    }

    final maxDx = (1.0 - safeWidth).clamp(0.0, 1.0);
    final maxDy = (1.0 - safeHeight).clamp(0.0, 1.0);

    final safeOffset = Offset(
      rawOffset.dx.clamp(0.0, maxDx),
      rawOffset.dy.clamp(0.0, maxDy),
    );

    return (safeOffset, safeWidth);
  }

  void _updateCrop(Offset offset, double width) {
    final n = _normalizeCrop(offset, width);
    setState(() {
      _cropOffset = n.$1;
      _cropWidth = n.$2;
    });
  }

  Rect _calculateVideoRect(Size areaSize) {
    if (areaSize.width <= 0 || areaSize.height <= 0) return Rect.zero;

    final videoAspect = widget.videoAspect;
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

  Size _getCropSize() {
    return Size(_cropWidth, _height);
  }

  void _saveAndClose() {
    Navigator.of(context).pop((_cropOffset, _cropWidth));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(16, tabletSize: 20),
                  vertical: context.responsiveSize(10, tabletSize: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _saveAndClose,
                      child: Container(
                        width: context.responsiveSize(36, tabletSize: 40),
                        height: context.responsiveSize(36, tabletSize: 40),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: context.responsiveSize(20, tabletSize: 22),
                        ),
                      ),
                    ),
                    Text(
                      l10n.imageEditorAdjustCrop,
                      style: context.responsiveTextStyle(
                        mobileSize: 16,
                        tabletSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final areaSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final videoRect = _calculateVideoRect(areaSize);

                    return Stack(
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: widget.videoAspect,
                            child: Video(
                              controller: widget.videoController,
                              controls: NoVideoControls,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        CropOverlay(
                          cropOffset: _cropOffset,
                          cropSize: _getCropSize(),
                          areaSize: areaSize,
                          videoRect: videoRect,
                        ),
                        CropBox(
                          offset: _cropOffset,
                          cropWidth: _cropWidth,
                          aspectRatio: widget.aspectRatio,
                          videoAspect: widget.videoAspect,
                          videoRect: videoRect,
                          onChanged: _updateCrop,
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
                            _activeHandle != null)
                          CropMagnifier(
                            videoController: widget.videoController,
                            focalPoint: _magnifierFocalPoint!,
                            videoRect: videoRect,
                            areaSize: areaSize,
                            activeHandle: _activeHandle!,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
