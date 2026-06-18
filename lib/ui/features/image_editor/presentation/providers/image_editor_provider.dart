import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';

/// State for the image editor.
class ImageEditorState {
  final CropType selectedCrop;
  final Offset cropOffset;
  final double cropWidth;
  final double imageAspect;
  final List<ui.Offset> freeFormPoints;
  final bool isDrawing;
  final ui.Offset? magnifierFocalPoint;
  final bool isGenerating;
  final String generationStatus;
  final double? generationProgress;
  final bool imageLoaded;

  const ImageEditorState({
    this.selectedCrop = CropType.square,
    this.cropOffset = const Offset(0.08, 0.10),
    this.cropWidth = 0.76,
    this.imageAspect = 1.0,
    this.freeFormPoints = const [],
    this.isDrawing = false,
    this.magnifierFocalPoint,
    this.isGenerating = false,
    this.generationStatus = '',
    this.generationProgress,
    this.imageLoaded = false,
  });

  double get cropHeight => (cropWidth * imageAspect) / 1.0;

  bool get hasFreeFormPoints => freeFormPoints.length >= 3;

  bool get canGenerate {
    if (isGenerating) return false;
    if (!imageLoaded) return false;
    if (selectedCrop == CropType.freeForm && !hasFreeFormPoints) return false;
    if (selectedCrop == CropType.smart) return false;
    return true;
  }

  ImageEditorState copyWith({
    CropType? selectedCrop,
    Offset? cropOffset,
    double? cropWidth,
    double? imageAspect,
    List<ui.Offset>? freeFormPoints,
    bool? isDrawing,
    ui.Offset? magnifierFocalPoint,
    bool? isGenerating,
    String? generationStatus,
    double? generationProgress,
    bool? imageLoaded,
  }) {
    return ImageEditorState(
      selectedCrop: selectedCrop ?? this.selectedCrop,
      cropOffset: cropOffset ?? this.cropOffset,
      cropWidth: cropWidth ?? this.cropWidth,
      imageAspect: imageAspect ?? this.imageAspect,
      freeFormPoints: freeFormPoints ?? this.freeFormPoints,
      isDrawing: isDrawing ?? this.isDrawing,
      magnifierFocalPoint: magnifierFocalPoint ?? this.magnifierFocalPoint,
      isGenerating: isGenerating ?? this.isGenerating,
      generationStatus: generationStatus ?? this.generationStatus,
      generationProgress: generationProgress ?? this.generationProgress,
      imageLoaded: imageLoaded ?? this.imageLoaded,
    );
  }
}

/// Notifier for the image editor state.
class ImageEditorNotifier extends StateNotifier<ImageEditorState> {
  ImageEditorNotifier() : super(const ImageEditorState());

  /// Resets only the crop-related state, keeping imageLoaded intact.
  void resetCropState() {
    state = state.copyWith(
      selectedCrop: CropType.square,
      cropOffset: const Offset(0.08, 0.10),
      cropWidth: 0.76,
      freeFormPoints: [],
      isDrawing: false,
      magnifierFocalPoint: null,
      // imageLoaded se mantiene como está
    );
  }

  void setImageAspect(double aspect) {
    state = state.copyWith(imageAspect: aspect, imageLoaded: true);
  }

  void setSelectedCrop(CropType crop) {
    state = state.copyWith(selectedCrop: crop, freeFormPoints: []);
  }

  void updateCrop(Offset offset, double width) {
    state = state.copyWith(cropOffset: offset, cropWidth: width);
  }

  void setFreeFormPoints(List<ui.Offset> points) {
    state = state.copyWith(freeFormPoints: points);
  }

  void clearFreeFormPoints() {
    state = state.copyWith(freeFormPoints: []);
  }

  void startDrawing(ui.Offset focalPoint) {
    state = state.copyWith(isDrawing: true, magnifierFocalPoint: focalPoint);
  }

  void addFreeFormPoint(ui.Offset point) {
    final newPoints = List<ui.Offset>.from(state.freeFormPoints)..add(point);
    state = state.copyWith(freeFormPoints: newPoints);
  }

  void updateMagnifier(ui.Offset focalPoint) {
    state = state.copyWith(magnifierFocalPoint: focalPoint);
  }

  void endDrawing() {
    state = state.copyWith(isDrawing: false, magnifierFocalPoint: null);
  }

  void setGenerating({
    required bool generating,
    String status = '',
    double? progress,
  }) {
    state = state.copyWith(
      isGenerating: generating,
      generationStatus: status,
      generationProgress: progress,
    );
  }

  void resetGenerationState() {
    state = state.copyWith(
      isGenerating: false,
      generationStatus: '',
      generationProgress: null,
    );
  }

  void syncFromFullscreen({
    List<ui.Offset>? freeFormPoints,
    Offset? cropOffset,
    double? cropWidth,
    CropType? cropType,
  }) {
    if (freeFormPoints != null) {
      state = state.copyWith(
        freeFormPoints: freeFormPoints,
        selectedCrop: CropType.freeForm,
      );
    } else if (cropOffset != null && cropWidth != null) {
      state = state.copyWith(cropOffset: cropOffset, cropWidth: cropWidth);
    }
    if (cropType != null) {
      state = state.copyWith(selectedCrop: cropType);
    }
  }
}

/// Provider for the image editor state.
final imageEditorProvider =
    StateNotifierProvider<ImageEditorNotifier, ImageEditorState>(
      (ref) => ImageEditorNotifier(),
    );

/// Provider for the crop offset (derived state).
final cropOffsetProvider = Provider<Offset>((ref) {
  return ref.watch(imageEditorProvider).cropOffset;
});

/// Provider for the crop width (derived state).
final cropWidthProvider = Provider<double>((ref) {
  return ref.watch(imageEditorProvider).cropWidth;
});

/// Provider for the crop height (derived state).
final cropHeightProvider = Provider<double>((ref) {
  return ref.watch(imageEditorProvider).cropHeight;
});

/// Provider for the free-form points (derived state).
final freeFormPointsProvider = Provider<List<ui.Offset>>((ref) {
  return ref.watch(imageEditorProvider).freeFormPoints;
});

/// Provider to check if the editor can generate.
final canGenerateProvider = Provider<bool>((ref) {
  return ref.watch(imageEditorProvider).canGenerate;
});
