import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

class PackCard extends StatelessWidget {
  final StickerPackModel pack;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Widget? coverPreview;

  const PackCard({
    super.key,
    required this.pack,
    required this.onTap,
    required this.onDelete,
    this.coverPreview,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (pack.filledCount / 30).clamp(0.0, 1.0);
    final isFull = pack.isFull;

    final thumbnailSize = context.responsiveSize(52, tabletSize: 58);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: EdgeInsets.all(context.responsiveSize(14, tabletSize: 16)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'pack_cover_${pack.id}',
              child: Container(
                width: thumbnailSize,
                height: thumbnailSize,
                decoration: BoxDecoration(
                  color: pack.hasCover
                      ? AppColors.accent.withValues(alpha: 0.16)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: pack.hasCover
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child:
                            coverPreview ??
                            Image.file(
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
            SizedBox(width: context.responsiveSize(14, tabletSize: 16)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pack.name,
                    style: context.responsiveTextStyle(
                      mobileSize: 15,
                      tabletSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.responsiveSize(2, tabletSize: 3)),
                  Text(
                    context.l10n.packCountByAuthor(pack.author),
                    style: context.responsiveTextStyle(
                      mobileSize: 12,
                      tabletSize: 13,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        isFull
                            ? AppColors.accent
                            : AppColors.accent.withValues(alpha: 0.7),
                      ),
                      minHeight: 3,
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(4, tabletSize: 5)),
                  Text(
                    isFull
                        ? context.l10n.stickerCountStatus(pack.filledCount)
                        : context.l10n.stickerCountSimple(pack.filledCount),
                    style: context.responsiveTextStyle(
                      mobileSize: 11,
                      tabletSize: 12,
                      color: isFull ? AppColors.accent : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: context.responsiveSize(20, tabletSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
