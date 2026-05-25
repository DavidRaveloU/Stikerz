import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/providers/pack_detail_provider.dart';

class PackDetailHero extends ConsumerWidget {
  final StickerPackModel pack;
  final String heroTag;
  final VoidCallback onCoverTap;
  final VoidCallback onOptionsTap;
  final Widget? coverPreview;

  const PackDetailHero({
    super.key,
    required this.pack,
    required this.heroTag,
    required this.onCoverTap,
    required this.onOptionsTap,
    this.coverPreview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A1A2E), AppColors.background],
          stops: const [0.0, 0.75],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildCoverRow(context),
            _buildProgressRow(context),
            _buildTabs(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(18, tabletSize: 22),
        context.responsiveSize(10, tabletSize: 12),
        context.responsiveSize(18, tabletSize: 22),
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ),
          _CircleButton(
            onTap: onOptionsTap,
            child: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(20, tabletSize: 24),
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onCoverTap,
            child: Hero(
              tag: heroTag,
              child: Stack(
                children: [
                  Container(
                    width: context.responsiveSize(80, tabletSize: 96),
                    height: context.responsiveSize(80, tabletSize: 96),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: pack.hasCover
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.accent.withValues(alpha: 0.4),
                        width: pack.hasCover ? 1.5 : 2,
                      ),
                    ),
                    child: pack.hasCover
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child:
                                coverPreview ??
                                Image.file(
                                  File(pack.coverImagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.broken_image_rounded,
                                    color: Colors.white54,
                                    size: 30,
                                  ),
                                ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_rounded,
                                color: AppColors.accent,
                                size: 22,
                              ),
                              SizedBox(
                                height: context.responsiveSize(
                                  4,
                                  tabletSize: 5,
                                ),
                              ),
                              Text(
                                context.l10n.packInfoCover,
                                style: context.responsiveTextStyle(
                                  mobileSize: 9,
                                  tabletSize: 10,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (pack.hasCover)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: context.responsiveSize(22, tabletSize: 24),
                        height: context.responsiveSize(22, tabletSize: 24),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: context.responsiveSize(11, tabletSize: 12),
                          color: AppColors.background,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: context.responsiveSize(18, tabletSize: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: context.responsiveTextStyle(
                    mobileSize: 22,
                    tabletSize: 26,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.responsiveSize(4, tabletSize: 6)),
                Text(
                  context.l10n.packCountByAuthor(pack.author),
                  style: context.responsiveTextStyle(
                    mobileSize: 12,
                    tabletSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: context.responsiveSize(10, tabletSize: 12)),
                Wrap(
                  spacing: context.responsiveSize(8, tabletSize: 10),
                  runSpacing: context.responsiveSize(8, tabletSize: 10),
                  children: [
                    _StatChip(
                      label: context.l10n.myStickers,
                      value: '${pack.filledCount}',
                    ),
                    _StatChip(
                      label: context.l10n.freeSlots,
                      value: '${30 - pack.filledCount}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(16, tabletSize: 18),
        context.responsiveSize(20, tabletSize: 24),
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pack.filledCount / 30,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  pack.isFull
                      ? AppColors.accent
                      : AppColors.accent.withValues(alpha: 0.7),
                ),
                minHeight: 4,
              ),
            ),
          ),
          SizedBox(width: context.responsiveSize(10, tabletSize: 12)),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: context.responsiveSize(11, tabletSize: 12),
                color: AppColors.textMuted,
              ),
              children: [
                TextSpan(
                  text: '${pack.filledCount}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: context.responsiveSize(11, tabletSize: 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' / 30'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, WidgetRef ref) {
    final tabs = [context.l10n.stickersTab, context.l10n.packInfoTab];
    final selectedTab = ref.watch(packDetailTabProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(16, tabletSize: 18),
        context.responsiveSize(20, tabletSize: 24),
        0,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == selectedTab;
          return Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => ref.read(packDetailTabProvider.notifier).state = i,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(16, tabletSize: 18),
                  vertical: context.responsiveSize(7, tabletSize: 8),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Text(
                  tabs[i],
                  style: context.responsiveTextStyle(
                    mobileSize: 12,
                    tabletSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.background
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Helper widgets.
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.responsiveSize(36, tabletSize: 40),
        height: context.responsiveSize(36, tabletSize: 40),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(10, tabletSize: 12),
        vertical: context.responsiveSize(5, tabletSize: 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: context.responsiveSize(11, tabletSize: 12),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.responsiveSize(11, tabletSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
