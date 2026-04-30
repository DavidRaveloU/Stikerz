import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/data/models/sticker_model.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

class StickerGrid extends StatelessWidget {
  final StickerPackModel pack;
  final Function(int index) onSlotTap;

  const StickerGrid({super.key, required this.pack, required this.onSlotTap});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sticker = pack.stickerAt(index);
        return _StickerSlot(
          index: index,
          sticker: sticker,
          onTap: () => onSlotTap(index),
        );
      }, childCount: 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
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

  const _StickerSlot({
    required this.index,
    required this.sticker,
    required this.onTap,
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
                style: const TextStyle(fontSize: 8, color: Color(0xFF333336)),
              ),
            ),
            Center(
              child: sticker != null
                  ? _StickerThumb(webpPath: sticker!.webpPath)
                  : const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF2a2a2e),
                      size: 18,
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

  const _StickerThumb({required this.webpPath});

  @override
  Widget build(BuildContext context) {
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
