import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/image_editor/presentation/models/crop_type.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/crop_provider.dart';

/// Sentinel usado por [ImageEditorState.copyWith] para distinguir entre
/// "parámetro omitido" (mantener valor actual) y "parámetro pasado como
/// null explícito" (limpiar el valor). Con el patrón `??` normal, ambos
/// casos son indistinguibles y un `null` explícito nunca sobrescribe
/// el valor previo — esa era la causa del bug del smart crop.
const Object _unset = Object();

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

  /// Ruta al PNG pre-procesado con fondo transparente (smart cutout).
  /// Se llena al seleccionar CropType.smart y completar el procesamiento.
  final String? smartCropPreviewPath;

  /// Indica si el procesamiento smart cutout está en curso.
  final bool isSmartProcessing;

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
    this.smartCropPreviewPath,
    this.isSmartProcessing = false,
  });

  double get cropHeight => (cropWidth * imageAspect) / 1.0;

  bool get hasFreeFormPoints => freeFormPoints.length >= 3;

  bool get canGenerate {
    if (isGenerating) return false;
    if (!imageLoaded) return false;
    if (selectedCrop == CropType.freeForm && !hasFreeFormPoints) return false;
    if (selectedCrop == CropType.smart) {
      // Bloqueado mientras se está detectando el sujeto, o si no hay
      // ningún recorte automático completado con éxito.
      if (isSmartProcessing) return false;
      if (smartCropPreviewPath == null) return false;
    }
    return true;
  }

  /// Indica si es seguro abrir la pantalla completa de recorte.
  ///
  /// Esta restricción SOLO aplica al modo smart (recorte automático):
  /// mientras se está procesando, o si no hay un recorte automático
  /// exitoso todavía, la pantalla completa queda deshabilitada. En
  /// cualquier otro modo de recorte (cuadrado, círculo, forma libre)
  /// siempre está disponible, sin restricciones adicionales.
  bool get canUseFullscreen {
    if (!imageLoaded) return false;
    if (selectedCrop == CropType.smart) {
      return !isSmartProcessing && smartCropPreviewPath != null;
    }
    return true;
  }

  ImageEditorState copyWith({
    CropType? selectedCrop,
    Offset? cropOffset,
    double? cropWidth,
    double? imageAspect,
    List<ui.Offset>? freeFormPoints,
    bool? isDrawing,
    Object? magnifierFocalPoint = _unset,
    bool? isGenerating,
    String? generationStatus,
    Object? generationProgress = _unset,
    bool? imageLoaded,
    Object? smartCropPreviewPath = _unset,
    bool? isSmartProcessing,
  }) {
    return ImageEditorState(
      selectedCrop: selectedCrop ?? this.selectedCrop,
      cropOffset: cropOffset ?? this.cropOffset,
      cropWidth: cropWidth ?? this.cropWidth,
      imageAspect: imageAspect ?? this.imageAspect,
      freeFormPoints: freeFormPoints ?? this.freeFormPoints,
      isDrawing: isDrawing ?? this.isDrawing,
      magnifierFocalPoint: magnifierFocalPoint == _unset
          ? this.magnifierFocalPoint
          : magnifierFocalPoint as ui.Offset?,
      isGenerating: isGenerating ?? this.isGenerating,
      generationStatus: generationStatus ?? this.generationStatus,
      generationProgress: generationProgress == _unset
          ? this.generationProgress
          : generationProgress as double?,
      imageLoaded: imageLoaded ?? this.imageLoaded,
      smartCropPreviewPath: smartCropPreviewPath == _unset
          ? this.smartCropPreviewPath
          : smartCropPreviewPath as String?,
      isSmartProcessing: isSmartProcessing ?? this.isSmartProcessing,
    );
  }
}

/// Notifier for the image editor state.
class ImageEditorNotifier extends StateNotifier<ImageEditorState> {
  ImageEditorNotifier() : super(const ImageEditorState());

  /// Resets only the crop-related state, keeping imageLoaded intact.
  void setSmartCropPreviewPath(String? path) {
    state = state.copyWith(smartCropPreviewPath: path);
  }

  void clearSmartCrop() {
    state = state.copyWith(
      smartCropPreviewPath: null,
      isSmartProcessing: false,
    );
  }

  void setSmartProcessing(bool processing) {
    state = state.copyWith(isSmartProcessing: processing);
  }

  void resetCropState() {
    state = state.copyWith(
      selectedCrop: CropType.square,
      cropOffset: const Offset(0.08, 0.10),
      cropWidth: 0.76,
      freeFormPoints: [],
      isDrawing: false,
      magnifierFocalPoint: null,
      smartCropPreviewPath: null,
      isSmartProcessing: false,
      // imageLoaded se mantiene como está
    );
  }

  void setImageAspect(double aspect) {
    state = state.copyWith(imageAspect: aspect, imageLoaded: true);
  }

  void setSelectedCrop(CropType crop) {
    state = state.copyWith(
      selectedCrop: crop,
      freeFormPoints: [],
      smartCropPreviewPath: crop != CropType.smart
          ? null
          : state.smartCropPreviewPath,
    );
  }

  void updateCrop(Offset offset, double width) {
    final normalized = CropProvider.normalizeCrop(
      rawOffset: offset,
      rawWidth: width,
      imageAspect: state.imageAspect,
      aspectRatio: 1.0,
    );
    state = state.copyWith(cropOffset: normalized.$1, cropWidth: normalized.$2);
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
      final normalized = CropProvider.normalizeCrop(
        rawOffset: cropOffset,
        rawWidth: cropWidth,
        imageAspect: state.imageAspect,
        aspectRatio: 1.0,
      );
      state = state.copyWith(
        cropOffset: normalized.$1,
        cropWidth: normalized.$2,
      );
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

/// Provider to check if fullscreen mode can be safely opened.
/// Solo bloquea en modo smart mientras se procesa o si no hay
/// un recorte automático completado.
final canUseFullscreenProvider = Provider<bool>((ref) {
  return ref.watch(imageEditorProvider).canUseFullscreen;
});
