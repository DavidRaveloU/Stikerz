import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

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
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(14, tabletSize: 16),
        context.responsiveSize(20, tabletSize: 24),
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.startTime(_formatTime(startSecs)),
                style: context.responsiveTextStyle(
                  mobileSize: 12,
                  tabletSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                context.l10n.totalDuration(_formatTime(videoDurationSecs)),
                style: context.responsiveTextStyle(
                  mobileSize: 12,
                  tabletSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSize(14, tabletSize: 16)),

          EditorSlider(
            label: context.l10n.startPointLabel,
            valueLabel: _formatTime(startSecs),
            value: startPoint,
            min: 0,
            max: 1,
            onChanged: onStartPointChanged,
          ),
          SizedBox(height: context.responsiveSize(14, tabletSize: 16)),

          EditorSlider(
            label: context.l10n.durationLabel,
            valueLabel: context.l10n.durationValue(duration.toStringAsFixed(1)),
            value: duration,
            min: 0.1,
            max: maxDuration,
            onChanged: onDurationChanged,
          ),
          SizedBox(height: context.responsiveSize(20, tabletSize: 24)),

          // Keep button height adaptive using vertical padding.
          GestureDetector(
            onTap: isGenerating ? null : onGenerate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: context.responsiveSize(16, tabletSize: 18),
              ),
              decoration: BoxDecoration(
                color: isGenerating
                    ? AppColors.accent.withValues(alpha: 0.6)
                    : AppColors.accent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGenerating)
                    SizedBox(
                      width: context.responsiveSize(18, tabletSize: 20),
                      height: context.responsiveSize(18, tabletSize: 20),
                      child: const CircularProgressIndicator(
                        color: AppColors.background,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.background,
                      size: context.responsiveSize(18, tabletSize: 20),
                    ),
                  SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
                  Text(
                    isGenerating
                        ? context.l10n.creatingSticker
                        : context.l10n.generateAnimatedSticker,
                    style: context.responsiveTextStyle(
                      mobileSize: 15,
                      tabletSize: 16,
                      color: AppColors.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isGenerating && generationProgress != null) ...[
            SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: generationProgress,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            SizedBox(height: context.responsiveSize(6, tabletSize: 8)),
            Text(
              generationStatus,
              style: context.responsiveTextStyle(
                mobileSize: 11,
                tabletSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
          Text(
            context.l10n.stickerLimits,
            style: context.responsiveTextStyle(
              mobileSize: 11,
              tabletSize: 12,
              color: AppColors.textMuted,
            ),
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
