import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class StickerPreviewSheet extends StatelessWidget {
  final String webpPath;
  final VoidCallback onDelete;
  final Widget? previewContent;

  const StickerPreviewSheet({
    super.key,
    required this.webpPath,
    required this.onDelete,
    this.previewContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.responsiveSize(16, tabletSize: 20),
        0,
        context.responsiveSize(16, tabletSize: 20),
        context.responsiveSize(32, tabletSize: 36),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
          Container(
            width: context.responsiveSize(36, tabletSize: 40),
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: context.responsiveSize(16, tabletSize: 18)),
          Container(
            width: context.responsiveSize(140, tabletSize: 160),
            height: context.responsiveSize(140, tabletSize: 160),
            decoration: BoxDecoration(
              color: const Color(0xFF111114),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      previewContent ??
                      Image.file(
                        File(webpPath),
                        fit: BoxFit.contain,
                        width: context.responsiveSize(140, tabletSize: 160),
                        height: context.responsiveSize(140, tabletSize: 160),
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.textMuted,
                          size: 36,
                        ),
                      ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Builder(
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.loop_rounded,
                              size: 9,
                              color: AppColors.accent,
                            ),
                            SizedBox(
                              width: context.responsiveSize(3, tabletSize: 4),
                            ),
                            Text(
                              context.l10n.loop,
                              style: context.responsiveTextStyle(
                                mobileSize: 9,
                                tabletSize: 10,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveSize(16, tabletSize: 18)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsiveSize(16, tabletSize: 20),
              0,
              context.responsiveSize(16, tabletSize: 20),
              context.responsiveSize(8, tabletSize: 10),
            ),
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(14, tabletSize: 16),
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    SizedBox(width: context.responsiveSize(8, tabletSize: 10)),
                    Text(
                      context.l10n.deleteSticker,
                      style: context.responsiveTextStyle(
                        mobileSize: 14,
                        tabletSize: 15,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
