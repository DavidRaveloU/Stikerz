import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class VideoTile extends StatelessWidget {
  final AssetEntity? asset;
  final bool isSelected;
  final String Function(Duration) formatDuration;
  final VoidCallback onTap;
  final Uint8List? thumbnailDataOverride;
  final Duration? videoDurationOverride;

  const VideoTile({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.formatDuration,
    required this.onTap,
    this.thumbnailDataOverride,
    this.videoDurationOverride,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Allow overriding thumbnail data in tests to avoid calling
          // platform-dependent PhotoManager APIs.
          if (thumbnailDataOverride != null)
            Image.memory(thumbnailDataOverride!, fit: BoxFit.cover)
          else
            FutureBuilder<Uint8List?>(
              future: asset?.thumbnailDataWithSize(
                const ThumbnailSize.square(200),
              ),
              builder: (_, snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.video_file_rounded,
                        color: AppColors.textMuted,
                        size: 28,
                      ),
                    ),
                  );
                }
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              },
            ),

          // Selection overlay.
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.35)
                : Colors.black26,
          ),

          if (isSelected)
            Positioned(
              top: context.responsiveSize(6, tabletSize: 8),
              right: context.responsiveSize(6, tabletSize: 8),
              child: Container(
                width: context.responsiveSize(22, tabletSize: 24),
                height: context.responsiveSize(22, tabletSize: 24),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.background,
                ),
              ),
            ),

          // Duration badge.
          Positioned(
            bottom: context.responsiveSize(4, tabletSize: 6),
            left: context.responsiveSize(5, tabletSize: 6),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(5, tabletSize: 6),
                vertical: context.responsiveSize(2, tabletSize: 3),
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatDuration(
                  videoDurationOverride ??
                      asset?.videoDuration ??
                      Duration.zero,
                ),
                style: context.responsiveTextStyle(
                  mobileSize: 10,
                  tabletSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Play icon overlay.
          Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white54,
              size: context.responsiveSize(28, tabletSize: 32),
            ),
          ),
        ],
      ),
    );
  }
}
