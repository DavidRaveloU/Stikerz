import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';
import 'package:whaticker/ui/components/pack_card.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            isFiltering
                ? '${packs.length} resultado${packs.length == 1 ? '' : 's'} de $totalCount'
                : '${packs.length} paquete${packs.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 100 + bottomInset),
            itemCount: packs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
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
