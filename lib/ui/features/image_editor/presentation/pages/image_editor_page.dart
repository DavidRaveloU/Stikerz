import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/core/services/ads_service.dart';
import 'package:stikerz/core/services/static_sticker_generation_service.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

enum CropType { square, circle, freeForm, smart }

class ImageEditorPage extends StatefulWidget {
  final int packId;
  final int slotIndex;
  final String imagePath;

  const ImageEditorPage({
    super.key,
    required this.packId,
    required this.slotIndex,
    required this.imagePath,
  });

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage>
    with TickerProviderStateMixin {
  CropType _selectedCrop = CropType.square;
  bool _isGenerating = false;
  String _generationStatus = '';
  double? _generationProgress;
  bool _imageLoaded = false;

  Offset _cropOffset = const Offset(0.08, 0.10);
  double _cropWidth = 0.76;
  double _imageAspect = 1.0;

  List<ui.Offset> _freeFormPoints = [];
  bool _isDrawing = false;
  ui.Offset? _magnifierFocalPoint;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null || !mounted) return;
      setState(() {
        _imageAspect = decoded.width / decoded.height;
        _imageLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${context.l10n.error}: $e')));
        Navigator.pop(context);
      }
    }
  }

  double get _effectiveAspect => _imageAspect > 0 ? _imageAspect : 1.0;

  (Offset, double) _normalizeCrop(Offset rawOffset, double rawWidth) {
    const aspectRatio = 1.0;
    final safeAspect = _effectiveAspect;

    double safeWidth = rawWidth.clamp(0.15, 1.0);
    double safeHeight = (safeWidth * safeAspect) / aspectRatio;

    if (safeHeight > 1.0) {
      safeHeight = 1.0;
      safeWidth = (safeHeight * aspectRatio / safeAspect).clamp(0.15, 1.0);
    }

    final maxDx = (1.0 - safeWidth).clamp(0.0, 1.0);
    final maxDy = (1.0 - safeHeight).clamp(0.0, 1.0);

    return (
      Offset(rawOffset.dx.clamp(0.0, maxDx), rawOffset.dy.clamp(0.0, maxDy)),
      safeWidth,
    );
  }

  void _updateCrop(Offset offset, double width) {
    final n = _normalizeCrop(offset, width);
    setState(() {
      _cropOffset = n.$1;
      _cropWidth = n.$2;
    });
  }

  double get _cropHeight => (_cropWidth * _effectiveAspect) / 1.0;

  Rect _calculateImageRect(Size areaSize) {
    if (areaSize.width <= 0 || areaSize.height <= 0) return Rect.zero;
    final aspect = _effectiveAspect;
    final areaAspect = areaSize.width / areaSize.height;
    if (areaAspect > aspect) {
      final h = areaSize.height;
      final w = h * aspect;
      return Rect.fromLTWH((areaSize.width - w) / 2, 0, w, h);
    } else {
      final w = areaSize.width;
      final h = w / aspect;
      return Rect.fromLTWH(0, (areaSize.height - h) / 2, w, h);
    }
  }

  void _openFullscreenEditor() async {
    final result = await Navigator.of(context).push<(Offset, double)>(
      MaterialPageRoute(
        builder: (_) => _FullscreenImageCropPage(
          imagePath: widget.imagePath,
          initialOffset: _cropOffset,
          initialCropWidth: _cropWidth,
          imageAspect: _imageAspect,
          cropType: _selectedCrop,
          freeFormPoints: _freeFormPoints,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result == null || !mounted) return;
    final n = _normalizeCrop(result.$1, result.$2);
    setState(() {
      _cropOffset = n.$1;
      _cropWidth = n.$2;
    });
  }

  Future<void> _generateSticker() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _generationStatus = context.l10n.processingImage;
      _generationProgress = 0.0;
    });

    try {
      double normX, normY, normW, normH;
      bool useCircularMask;
      List<ui.Offset>? freeFormPoints;

      switch (_selectedCrop) {
        case CropType.square:
          normX = _cropOffset.dx;
          normY = _cropOffset.dy;
          normW = _cropWidth;
          normH = _cropHeight;
          useCircularMask = false;
          freeFormPoints = null;
        case CropType.circle:
          normX = _cropOffset.dx;
          normY = _cropOffset.dy;
          normW = _cropWidth;
          normH = _cropHeight;
          useCircularMask = true;
          freeFormPoints = null;
        case CropType.freeForm:
          if (_freeFormPoints.length < 3) {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trace a shape first.')),
              );
            setState(() => _isGenerating = false);
            return;
          }
          normX = 0.0;
          normY = 0.0;
          normW = 1.0;
          normH = 1.0;
          useCircularMask = false;
          freeFormPoints = _freeFormPoints;
        case CropType.smart:
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.cropTypeSmartComingSoon)),
            );
          setState(() => _isGenerating = false);
          return;
      }

      final result = await StaticStickerGenerationService.generate(
        inputImagePath: widget.imagePath,
        packId: widget.packId,
        slotIndex: widget.slotIndex,
        normalizedCropX: normX,
        normalizedCropY: normY,
        normalizedCropWidth: normW,
        normalizedCropHeight: normH,
        useCircularMask: useCircularMask,
        freeFormPoints: freeFormPoints,
        rotationDegrees: 0.0,
        onStatus: (s, p) {
          if (mounted)
            setState(() {
              _generationStatus = s;
              _generationProgress = p;
            });
        },
      );

      if (!mounted) return;
      if (result.success && result.path != null) {
        await PackRepository.instance.addSticker(
          packId: widget.packId,
          slotIndex: widget.slotIndex,
          webpPath: result.path!,
          sourceType: 'image_gallery',
        );
        if (mounted) await _popWithAd();
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Could not create sticker.'),
            ),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${context.l10n.error}: $e')));
    } finally {
      if (mounted)
        setState(() {
          _isGenerating = false;
          _generationStatus = '';
          _generationProgress = null;
        });
    }
  }

  Future<void> _popWithAd() async {
    await AdsService().showInterstitialAd(
      onDismissed: () {
        if (mounted) Navigator.pop(context, 'generated');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _imageLoaded
            ? _buildEditorBody()
            : const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.l10n.imageEditorTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isGenerating)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: _generationProgress,
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditorBody() {
    return Column(
      children: [
        _buildToolBar(),
        Expanded(child: _buildImagePreview()),
        if (_isGenerating && _generationStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _generationStatus,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildToolBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSize(6, tabletSize: 8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12, tabletSize: 16),
        ),
        child: Row(
          children: [
            _ToolButton(
              icon: Icons.crop_square_rounded,
              label: context.l10n.cropTypeRectangle,
              isSelected: _selectedCrop == CropType.square,
              onTap: () => setState(() {
                _selectedCrop = CropType.square;
                _freeFormPoints = [];
              }),
            ),
            const SizedBox(width: 6),
            _ToolButton(
              icon: Icons.circle_outlined,
              label: context.l10n.cropTypeCircle,
              isSelected: _selectedCrop == CropType.circle,
              onTap: () => setState(() {
                _selectedCrop = CropType.circle;
                _freeFormPoints = [];
              }),
            ),
            const SizedBox(width: 6),
            _ToolButton(
              icon: Icons.gesture_rounded,
              label: context.l10n.cropTypeFreeForm,
              isSelected: _selectedCrop == CropType.freeForm,
              onTap: () => setState(() {
                _selectedCrop = CropType.freeForm;
                _freeFormPoints = [];
              }),
            ),
            const SizedBox(width: 6),
            _ToolButton(
              icon: Icons.auto_fix_high_rounded,
              label: context.l10n.cropTypeSmart,
              isSelected: false,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.cropTypeSmartComingSoon)),
              ),
            ),
            const SizedBox(width: 6),
            _ToolButton(
              icon: Icons.fullscreen_rounded,
              label: 'Full',
              isSelected: false,
              onTap: _openFullscreenEditor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _calculateImageRect(areaSize);

        if (_selectedCrop == CropType.freeForm) {
          return _buildFreeFormArea(areaSize, imageRect);
        }

        return _buildSquareCircleArea(areaSize, imageRect);
      },
    );
  }

  Widget _buildFreeFormArea(Size areaSize, Rect imageRect) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(
          rect: imageRect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
          ),
        ),
        Positioned.fromRect(
          rect: imageRect,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDrawing = true;
                _magnifierFocalPoint = details.localPosition;
                _freeFormPoints = [
                  ui.Offset(
                    details.localPosition.dx / imageRect.width,
                    details.localPosition.dy / imageRect.height,
                  ),
                ];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _magnifierFocalPoint = details.localPosition;
                if (_isDrawing) {
                  _freeFormPoints.add(
                    ui.Offset(
                      details.localPosition.dx / imageRect.width,
                      details.localPosition.dy / imageRect.height,
                    ),
                  );
                }
              });
            },
            onPanEnd: (_) => setState(() {
              _isDrawing = false;
              _magnifierFocalPoint = null;
            }),
            child: CustomPaint(
              size: Size(imageRect.width, imageRect.height),
              painter: _FreeFormCropPainter(
                points: _freeFormPoints
                    .map(
                      (p) => ui.Offset(
                        p.dx * imageRect.width,
                        p.dy * imageRect.height,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        if (_freeFormPoints.isEmpty && !_isDrawing)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Trace the outline without lifting your finger',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        if (_isDrawing &&
            _magnifierFocalPoint != null &&
            _freeFormPoints.length > 5)
          _buildMagnifier(imageRect, areaSize),
      ],
    );
  }

  Widget _buildMagnifier(Rect imageRect, Size areaSize) {
    if (_magnifierFocalPoint == null || imageRect.isEmpty) {
      return const SizedBox.shrink();
    }

    const double diameter = 120.0;
    const double zoomFactor = 2.5;
    const double margin = 16.0;

    final Offset fp = _magnifierFocalPoint!;

    final double absX = imageRect.left + fp.dx;
    final double absY = imageRect.top + fp.dy;

    double mx = absX.clamp(
      diameter / 2 + margin,
      areaSize.width - diameter / 2 - margin,
    );
    double my = (absY - diameter - margin).clamp(
      margin,
      areaSize.height - diameter - margin,
    );

    final double fx = (fp.dx / imageRect.width).clamp(0.0, 1.0);
    final double fy = (fp.dy / imageRect.height).clamp(0.0, 1.0);

    return Positioned(
      left: mx - diameter / 2,
      top: my,
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
                  left: (diameter / 2) - (fx * imageRect.width * zoomFactor),
                  top: (diameter / 2) - (fy * imageRect.height * zoomFactor),
                  width: imageRect.width * zoomFactor,
                  height: imageRect.height * zoomFactor,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCircleArea(Size areaSize, Rect imageRect) {
    final left = imageRect.left + (_cropOffset.dx * imageRect.width);
    final top = imageRect.top + (_cropOffset.dy * imageRect.height);
    final w = _cropWidth * imageRect.width;
    final h = _cropHeight * imageRect.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(
          rect: imageRect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DimOverlayPainter(
              cropRect: Rect.fromLTWH(left, top, w, h),
              isCircle: _selectedCrop == CropType.circle,
            ),
          ),
        ),
        _ImageCropBox(
          offset: _cropOffset,
          cropWidth: _cropWidth,
          imageAspect: _effectiveAspect,
          imageRect: imageRect,
          onChanged: _updateCrop,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(16, tabletSize: 20),
        context.responsiveSize(8, tabletSize: 10),
        context.responsiveSize(16, tabletSize: 20),
        context.responsiveSize(24, tabletSize: 28),
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: context.responsiveSize(48, tabletSize: 52),
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generateSticker,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: context.responsiveTextStyle(
                mobileSize: 15,
                tabletSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2,
                    ),
                  )
                : Text(context.l10n.generateStaticSticker),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
            case 2:
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy =
                  widget.offset.dy -
                  (nw - widget.cropWidth) * (_height / widget.cropWidth);
            case 3:
              nw = (widget.cropWidth - deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx + (widget.cropWidth - nw);
              noy = widget.offset.dy;
            case 4:
              nw = (widget.cropWidth + deltaX).clamp(0.15, 1.0);
              nox = widget.offset.dx;
              noy = widget.offset.dy;
          }
          final mx = (1.0 - nw).clamp(0.0, 1.0);
          final my = (1.0 - _height).clamp(0.0, 1.0);
          widget.onChanged(Offset(nox.clamp(0, mx), noy.clamp(0, my)), nw);
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

class _DimOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final bool isCircle;
  _DimOverlayPainter({required this.cropRect, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    if (isCircle) {
      canvas.save();
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(
          Rect.fromCircle(center: cropRect.center, radius: cropRect.width / 2),
        )
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, fill);
      canvas.restore();
      canvas.drawCircle(
        cropRect.center,
        cropRect.width / 2,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), fill);
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          cropRect.bottom,
          size.width,
          size.height - cropRect.bottom,
        ),
        fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
        fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          cropRect.right,
          cropRect.top,
          size.width - cropRect.right,
          cropRect.height,
        ),
        fill,
      );
      canvas.drawRect(
        cropRect,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DimOverlayPainter o) =>
      o.cropRect != cropRect || o.isCircle != isCircle;
}

class _FreeFormCropPainter extends CustomPainter {
  final List<ui.Offset> points;
  _FreeFormCropPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final pp = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fp = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, fp);
    canvas.drawPath(path, pp);
  }

  @override
  bool shouldRepaint(covariant _FreeFormCropPainter o) => o.points != points;
}

class _FullscreenImageCropPage extends StatefulWidget {
  final String imagePath;
  final Offset initialOffset;
  final double initialCropWidth;
  final double imageAspect;
  final CropType cropType;
  final List<ui.Offset> freeFormPoints;

  const _FullscreenImageCropPage({
    required this.imagePath,
    required this.initialOffset,
    required this.initialCropWidth,
    required this.imageAspect,
    required this.cropType,
    required this.freeFormPoints,
  });

  @override
  State<_FullscreenImageCropPage> createState() =>
      _FullscreenImageCropPageState();
}

class _FullscreenImageCropPageState extends State<_FullscreenImageCropPage> {
  late Offset _cropOffset;
  late double _cropWidth;

  @override
  void initState() {
    super.initState();
    _cropOffset = widget.initialOffset;
    _cropWidth = widget.initialCropWidth;
  }

  double get _height => (_cropWidth * widget.imageAspect) / 1.0;

  void _updateCrop(Offset o, double w) {
    const a = 1.0;
    final sa = widget.imageAspect > 0 ? widget.imageAspect : 1.0;
    double sw = w.clamp(0.15, 1.0);
    double sh = (sw * sa) / a;
    if (sh > 1.0) {
      sh = 1.0;
      sw = (sh * a / sa).clamp(0.15, 1.0);
    }
    final mx = (1.0 - sw).clamp(0.0, 1.0);
    final my = (1.0 - sh).clamp(0.0, 1.0);
    setState(() {
      _cropOffset = Offset(o.dx.clamp(0, mx), o.dy.clamp(0, my));
      _cropWidth = sw;
    });
  }

  Rect _calcRect(Size area) {
    final a = widget.imageAspect;
    return area.width / area.height > a
        ? Rect.fromLTWH(
            (area.width - area.height * a) / 2,
            0,
            area.height * a,
            area.height,
          )
        : Rect.fromLTWH(
            0,
            (area.height - area.width / a) / 2,
            area.width,
            area.width / a,
          );
  }

  @override
  Widget build(BuildContext context) {
    final isFreeForm = widget.cropType == CropType.freeForm;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.pop(context, (_cropOffset, _cropWidth)),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      isFreeForm ? 'Trace shape' : 'Adjust crop',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final area = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final vr = _calcRect(area);

                    if (isFreeForm) {
                      return _FullscreenFreeFormArea(
                        imagePath: widget.imagePath,
                        imageRect: vr,
                        areaSize: area,
                      );
                    }

                    final left = vr.left + (_cropOffset.dx * vr.width);
                    final top = vr.top + (_cropOffset.dy * vr.height);
                    final w = _cropWidth * vr.width;
                    final h = _height * vr.height;

                    return Stack(
                      children: [
                        Positioned.fromRect(
                          rect: vr,
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DimOverlayPainter(
                              cropRect: Rect.fromLTWH(left, top, w, h),
                              isCircle: widget.cropType == CropType.circle,
                            ),
                          ),
                        ),
                        _ImageCropBox(
                          offset: _cropOffset,
                          cropWidth: _cropWidth,
                          imageAspect: widget.imageAspect,
                          imageRect: vr,
                          onChanged: _updateCrop,
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

class _FullscreenFreeFormArea extends StatefulWidget {
  final String imagePath;
  final Rect imageRect;
  final Size areaSize;

  const _FullscreenFreeFormArea({
    required this.imagePath,
    required this.imageRect,
    required this.areaSize,
  });

  @override
  State<_FullscreenFreeFormArea> createState() =>
      _FullscreenFreeFormAreaState();
}

class _FullscreenFreeFormAreaState extends State<_FullscreenFreeFormArea> {
  List<ui.Offset> _points = [];
  bool _isDrawing = false;
  ui.Offset? _magnifierFocalPoint;

  @override
  Widget build(BuildContext context) {
    final imageRect = widget.imageRect;

    return Stack(
      children: [
        Positioned.fromRect(
          rect: imageRect,
          child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
        ),
        Positioned.fromRect(
          rect: imageRect,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDrawing = true;
                _magnifierFocalPoint = details.localPosition;
                _points = [
                  ui.Offset(
                    details.localPosition.dx / imageRect.width,
                    details.localPosition.dy / imageRect.height,
                  ),
                ];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _magnifierFocalPoint = details.localPosition;
                if (_isDrawing) {
                  _points.add(
                    ui.Offset(
                      details.localPosition.dx / imageRect.width,
                      details.localPosition.dy / imageRect.height,
                    ),
                  );
                }
              });
            },
            onPanEnd: (_) => setState(() {
              _isDrawing = false;
              _magnifierFocalPoint = null;
            }),
            child: CustomPaint(
              size: Size(imageRect.width, imageRect.height),
              painter: _FreeFormCropPainter(
                points: _points
                    .map(
                      (p) => ui.Offset(
                        p.dx * imageRect.width,
                        p.dy * imageRect.height,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        if (_points.isEmpty && !_isDrawing)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Trace the outline',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        if (_isDrawing && _magnifierFocalPoint != null && _points.length > 5)
          _buildMagnifier(imageRect),
      ],
    );
  }

  Widget _buildMagnifier(Rect imageRect) {
    if (_magnifierFocalPoint == null || imageRect.isEmpty) {
      return const SizedBox.shrink();
    }

    const double d = 120.0;
    const double z = 2.5;
    const double m = 16.0;

    final Offset fp = _magnifierFocalPoint!;

    final double absX = imageRect.left + fp.dx;
    final double absY = imageRect.top + fp.dy;

    final double mx = absX.clamp(d / 2 + m, widget.areaSize.width - d / 2 - m);
    final double my = (absY - d - m).clamp(m, widget.areaSize.height - d - m);

    final double fx = (fp.dx / imageRect.width).clamp(0.0, 1.0);
    final double fy = (fp.dy / imageRect.height).clamp(0.0, 1.0);

    return Positioned(
      left: mx - d / 2,
      top: my,
      child: IgnorePointer(
        child: Container(
          width: d,
          height: d,
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
                  left: (d / 2) - (fx * imageRect.width * z),
                  top: (d / 2) - (fy * imageRect.height * z),
                  width: imageRect.width * z,
                  height: imageRect.height * z,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                Center(
                  child: Container(
                    width: 1,
                    height: d,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                Center(
                  child: Container(
                    width: d,
                    height: 1,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
