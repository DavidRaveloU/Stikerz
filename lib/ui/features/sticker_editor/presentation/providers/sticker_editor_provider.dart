import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';

/// Immutable state for the sticker editor flow.
class StickerEditorState {
  final AspectRatioOption aspectRatio;
  final double startPoint;
  final double duration;
  final bool isPlaying;
  final bool isGenerating;
  final String generationStatus;
  final double? generationProgress;

  const StickerEditorState({
    required this.aspectRatio,
    required this.startPoint,
    required this.duration,
    required this.isPlaying,
    required this.isGenerating,
    required this.generationStatus,
    this.generationProgress,
  });

  StickerEditorState copyWith({
    AspectRatioOption? aspectRatio,
    double? startPoint,
    double? duration,
    bool? isPlaying,
    bool? isGenerating,
    String? generationStatus,
    double? generationProgress,
  }) {
    return StickerEditorState(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      startPoint: startPoint ?? this.startPoint,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isGenerating: isGenerating ?? this.isGenerating,
      generationStatus: generationStatus ?? this.generationStatus,
      generationProgress: generationProgress ?? this.generationProgress,
    );
  }
}

/// State notifier provider for sticker editor state.
final stickerEditorProvider =
    StateNotifierProvider<StickerEditorNotifier, StickerEditorState>(
      (ref) => StickerEditorNotifier(),
    );

class StickerEditorNotifier extends StateNotifier<StickerEditorState> {
  StickerEditorNotifier()
    : super(
        const StickerEditorState(
          aspectRatio: AspectRatioOption.square,
          startPoint: 0.0,
          duration: 5.0,
          isPlaying: false,
          isGenerating: false,
          generationStatus: '',
          generationProgress: null,
        ),
      );

  void updateAspectRatio(AspectRatioOption aspect) {
    state = state.copyWith(aspectRatio: aspect);
  }

  void updateStartPoint(double value) {
    state = state.copyWith(startPoint: value);
  }

  void updateDuration(double value) {
    state = state.copyWith(duration: value);
  }

  void togglePlaying() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void setGenerating(bool value, {String status = '', double? progress}) {
    state = state.copyWith(
      isGenerating: value,
      generationStatus: status,
      generationProgress: progress,
    );
  }
}
