import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

class PackCard extends StatelessWidget {
  final StickerPackModel pack;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PackCard({
    super.key,
    required this.pack,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (pack.filledCount / 30).clamp(0.0, 1.0);
    final isFull = pack.isFull;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'pack_cover_${pack.id}',
              placeholderBuilder: (context, size, child) => child,
              flightShuttleBuilder:
                  (
                    flightContext,
                    animation,
                    direction,
                    fromContext,
                    toContext,
                  ) {
                    return Material(
                      color: Colors.transparent,
                      child: toContext.widget,
                    );
                  },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: pack.hasCover
                      ? AppColors.accent.withOpacity(0.16)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: pack.hasCover
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(pack.coverImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.photo_library_rounded,
                            color: Colors.white38,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white38,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'por ${pack.author}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        isFull
                            ? AppColors.accent
                            : AppColors.accent.withOpacity(0.7),
                      ),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFull
                        ? '${pack.filledCount} / 30 — ¡Listo para WhatsApp!'
                        : '${pack.filledCount} / 30 stickers',
                    style: TextStyle(
                      fontSize: 11,
                      color: isFull ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
