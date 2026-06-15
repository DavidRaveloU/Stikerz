import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/components/pack_card.dart';

class PackList extends StatelessWidget {
  final List<StickerPackModel> packs;
  final Function(StickerPackModel)? onDelete;
  final Function(StickerPackModel) onPackTap;
  final String searchQuery;
  final int totalCount;

  const PackList({
    super.key,
    required this.packs,
    this.onDelete,
    required this.onPackTap,
    required this.searchQuery,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isFiltering = searchQuery.trim().isNotEmpty;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final horizontal = context.responsiveSize(20, tabletSize: 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 10),
          child: Text(
            isFiltering
                ? context.l10n.packsFound(packs.length, totalCount)
                : context.l10n.packsCount(packs.length),
            style: context.responsiveTextStyle(
              mobileSize: 11,
              tabletSize: 12,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              0,
              horizontal,
              context.responsiveSize(100, tabletSize: 120) + bottomInset,
            ),
            itemCount: packs.length,
            separatorBuilder: (_, _) =>
                SizedBox(height: context.responsiveSize(10, tabletSize: 12)),
            itemBuilder: (context, index) {
              final pack = packs[index];
              return PackCard(
                pack: pack,
                onDelete: onDelete != null ? () => onDelete!(pack) : null,
                onTap: () => onPackTap(pack),
              );
            },
          ),
        ),
      ],
    );
  }
}
