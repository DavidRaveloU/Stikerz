import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

import 'aspect_ratio_selector.dart';
import 'editor_slider.dart';

class EditorControls extends StatelessWidget {
  final double startPoint;
  final double duration;
  final double videoDurationSecs;
  final bool isGenerating;
  final String generationStatus;
  final double? generationProgress;
  final AspectRatioOption aspectRatio;
  final ValueChanged<AspectRatioOption> onAspectChanged;
  final ValueChanged<double> onStartPointChanged;
  final ValueChanged<double> onDurationChanged;
  final VoidCallback onGenerate;

  const EditorControls({
    super.key,
    required this.startPoint,
    required this.duration,
    required this.videoDurationSecs,
    required this.isGenerating,
    required this.generationStatus,
    required this.generationProgress,
    required this.aspectRatio,
    required this.onAspectChanged,
    required this.onStartPointChanged,
    required this.onDurationChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final startSecs = startPoint * videoDurationSecs;
    final maxDuration = (videoDurationSecs - startSecs).clamp(0.1, 5.0);

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiempo actual y total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.startTime(_formatTime(startSecs)),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                context.l10n.totalDuration(_formatTime(videoDurationSecs)),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Slider: Punto de inicio
          EditorSlider(
            label: context.l10n.startPointLabel,
            valueLabel: _formatTime(startSecs),
            value: startPoint,
            min: 0,
            max: 1,
            onChanged: onStartPointChanged,
          ),
          const SizedBox(height: 14),

          // Slider: Duración
          EditorSlider(
            label: context.l10n.durationLabel,
            valueLabel: context.l10n.durationValue(duration.toStringAsFixed(1)),
            value: duration,
            min: 0.1,
            max: maxDuration,
            onChanged: onDurationChanged,
          ),
          const SizedBox(height: 20),

          // Botón Generar
          GestureDetector(
            onTap: isGenerating ? null : onGenerate,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: isGenerating
                    ? AppColors.accent.withOpacity(0.6)
                    : AppColors.accent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGenerating)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.background,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.background,
                      size: 18,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    isGenerating
                        ? context.l10n.creatingSticker
                        : context.l10n.generateAnimatedSticker,
                    style: const TextStyle(
                      color: AppColors.background,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isGenerating && generationProgress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: generationProgress,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              generationStatus,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 8),
          Text(
            context.l10n.stickerLimits,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatTime(double secs) {
    final clamped = secs.clamp(0.0, 999.0);
    final m = clamped ~/ 60;
    final s = (clamped % 60).toStringAsFixed(1);
    return '${m.toString().padLeft(2, '0')}:${s.padLeft(4, '0')}';
  }
}
