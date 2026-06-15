import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class EditorTimeline extends StatelessWidget {
  final double startPoint;
  final double duration;
  final double playheadPosition;
  final double videoDurationSecs;
  final double? bufferedFraction;

  const EditorTimeline({
    super.key,
    required this.startPoint,
    required this.duration,
    required this.playheadPosition,
    required this.videoDurationSecs,
    this.bufferedFraction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.responsiveSize(48, tabletSize: 54),
      color: const Color(0xFF111114),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final startX = startPoint * w;
          final endX = startX + (duration / videoDurationSecs) * w;
          final playX = playheadPosition * w;

          return Stack(
            children: [
              // Buffered range indicator (light overlay)
              if (bufferedFraction != null)
                Positioned(
                  left: startX,
                  width:
                      ((videoDurationSecs * bufferedFraction!) /
                                  videoDurationSecs *
                                  w -
                              startX)
                          .clamp(0.0, w - startX),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColors.accent.withValues(alpha: 0.08),
                  ),
                ),
              Row(
                children: List.generate(
                  14,
                  (i) => Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: const Color(0xFF1a1a1e)),
                        ),
                        gradient: LinearGradient(
                          colors: i.isEven
                              ? [
                                  const Color(0xFF0f1b10),
                                  const Color(0xFF0a1020),
                                ]
                              : [
                                  const Color(0xFF1a0a25),
                                  const Color(0xFF0a1520),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: startX,
                width: (endX - startX).clamp(0.0, w - startX),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    border: Border.symmetric(
                      vertical: BorderSide(color: AppColors.accent, width: 2.5),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: playX.clamp(0.0, w - 3),
                top: 0,
                bottom: 0,
                child: Container(
                  width: context.responsiveSize(3, tabletSize: 4),
                  color: AppColors.accent,
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
