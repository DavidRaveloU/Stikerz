import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/providers/pack_detail_provider.dart';

class PackDetailHero extends ConsumerWidget {
  final StickerPackModel pack;
  final String heroTag;
  final VoidCallback onCoverTap;
  final VoidCallback onOptionsTap;

  const PackDetailHero({
    super.key,
    required this.pack,
    required this.heroTag,
    required this.onCoverTap,
    required this.onOptionsTap,
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
            _buildProgressRow(),
            _buildTabs(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: pack.hasCover
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.accent.withOpacity(0.4),
                        width: pack.hasCover ? 1.5 : 2,
                      ),
                    ),
                    child: pack.hasCover
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(pack.coverImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_rounded,
                                color: Colors.white54,
                                size: 30,
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                color: AppColors.accent,
                                size: 22,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Portada',
                                style: TextStyle(
                                  fontSize: 9,
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
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 11,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'por ${pack.author}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatChip(label: 'stickers', value: '${pack.filledCount}'),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'libres',
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

  Widget _buildProgressRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                      : AppColors.accent.withOpacity(0.7),
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              children: [
                TextSpan(
                  text: '${pack.filledCount}',
                  style: const TextStyle(
                    color: AppColors.accent,
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

  Widget _buildTabs(WidgetRef ref) {
    const tabs = ['Stickers', 'Info del pack'];
    final selectedTab = ref.watch(packDetailTabProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == selectedTab;
          return Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => ref.read(packDetailTabProvider.notifier).state = i,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
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
                  style: TextStyle(
                    fontSize: 12,
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

// ── Widgets auxiliares ───────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
