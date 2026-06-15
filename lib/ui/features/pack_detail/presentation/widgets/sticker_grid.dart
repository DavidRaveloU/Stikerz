import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_model.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

class StickerGrid extends StatelessWidget {
  final StickerPackModel pack;
  final Function(int index) onSlotTap;
  final Widget? thumbOverride;

  const StickerGrid({
    super.key,
    required this.pack,
    required this.onSlotTap,
    this.thumbOverride,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isTablet ? 6 : 5;
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sticker = pack.stickerAt(index);
        return _StickerSlot(
          index: index,
          sticker: sticker,
          onTap: () => onSlotTap(index),
          thumbOverride: thumbOverride,
        );
      }, childCount: 30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: context.responsiveSize(6, tabletSize: 8),
        mainAxisSpacing: context.responsiveSize(6, tabletSize: 8),
        childAspectRatio: 1,
      ),
    );
  }
}

// ─── Slot individual ──────────────────────────────────────────────────────
class _StickerSlot extends StatelessWidget {
  final int index;
  final StickerModel? sticker;
  final VoidCallback onTap;
  final Widget? thumbOverride;

  const _StickerSlot({
    required this.index,
    required this.sticker,
    required this.onTap,
    this.thumbOverride,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: sticker != null ? AppColors.surface : const Color(0xFF111114),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sticker != null ? AppColors.border : const Color(0xFF222226),
            width: sticker != null ? 1 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 5,
              child: Text(
                '${index + 1}',
                style: context.responsiveTextStyle(
                  mobileSize: 8,
                  tabletSize: 9,
                  color: const Color(0xFF333336),
                ),
              ),
            ),
            Center(
              child: sticker != null
                  ? _StickerThumb(
                      webpPath: sticker!.webpPath,
                      thumbOverride: thumbOverride,
                    )
                  : Icon(
                      Icons.add_rounded,
                      color: Color(0xFF2a2a2e),
                      size: context.responsiveSize(18, tabletSize: 20),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerThumb extends StatelessWidget {
  final String webpPath;
  final Widget? thumbOverride;

  const _StickerThumb({required this.webpPath, this.thumbOverride});

  @override
  Widget build(BuildContext context) {
    if (thumbOverride != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: thumbOverride,
      );
    }

    final file = File(webpPath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        file,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.gif_box_rounded,
            color: AppColors.textMuted,
            size: 24,
          ),
        ),
      ),
    );
  }
}
