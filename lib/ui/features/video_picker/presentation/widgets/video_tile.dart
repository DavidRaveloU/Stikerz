import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:whaticker/core/constants/app_colors.dart';

class VideoTile extends StatelessWidget {
  final AssetEntity asset;
  final bool isSelected;
  final String Function(Duration) formatDuration;
  final VoidCallback onTap;

  const VideoTile({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.formatDuration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(
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

          // Overlay selección
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            color: isSelected
                ? AppColors.accent.withOpacity(0.35)
                : Colors.black26,
          ),

          // Check
          if (isSelected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 22,
                height: 22,
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

          // Duración
          Positioned(
            bottom: 4,
            left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatDuration(asset.videoDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Icono play
          const Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white54,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
