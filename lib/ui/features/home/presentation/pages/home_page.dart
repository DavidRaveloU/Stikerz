import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';
import 'package:whaticker/core/providers/share_provider.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';
import 'package:whaticker/ui/components/create_pack_modal.dart';
import 'package:whaticker/ui/features/home/presentation/providers/home_provider.dart';
import 'package:whaticker/ui/features/home/presentation/widgets/home_header.dart';
import 'package:whaticker/ui/features/home/presentation/widgets/home_search_bar.dart';
import 'package:whaticker/ui/features/home/presentation/widgets/pack_list.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/pages/pack_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreatePackModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CreatePackModal(),
    );
  }

  void _showDeleteDialog(StickerPackModel pack) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.l10n.deletePackTitle,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(context.l10n.deletePackMessage(pack.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PackRepository.instance.deletePack(pack.id);
            },
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingShareProvider);
    final filteredPacks = ref.watch(filteredPacksProvider);
    final totalCount = ref.watch(totalPacksCountProvider);
    final isLoading = ref.watch(packsStreamProvider).isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              if (pending != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _shareBannerHint(pending, totalCount),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              pending.isResolving
                                  ? Icons.hourglass_top_rounded
                                  : Icons.add_to_photos_rounded,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _shareBannerTitle(pending, totalCount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _shareBannerSubtitle(pending, totalCount),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (pending.isResolving)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  ref
                                          .read(pendingShareProvider.notifier)
                                          .state =
                                      null;
                                },
                                child: Text(context.l10n.discard),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              HomeSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(homeSearchQueryProvider.notifier).state = value;
                },
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : filteredPacks.isEmpty && totalCount == 0
                    ? _buildEmptyState()
                    : PackList(
                        packs: filteredPacks,
                        searchQuery: ref.watch(homeSearchQueryProvider),
                        totalCount: totalCount,
                        onDelete: _showDeleteDialog,
                        onPackTap: (pack) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PackDetailPage(
                                packId: pack.id,
                                heroTag: 'pack_cover_${pack.id}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noPacksTitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.noPacksDesc,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _shareBannerTitle(PendingShare pending, int totalCount) {
    if (pending.isResolving) {
      return context.l10n.preparingVideo;
    }

    if (totalCount == 0) {
      return context.l10n.createPackFirst;
    }

    return context.l10n.selectPackTitle;
  }

  String _shareBannerSubtitle(PendingShare pending, int totalCount) {
    if (pending.isResolving) {
      return context.l10n.convertingLink;
    }

    if (totalCount == 0) {
      return context.l10n.createPackHint;
    }

    return context.l10n.selectPackDesc;
  }

  String _shareBannerHint(PendingShare pending, int totalCount) {
    if (pending.isResolving) {
      return context.l10n.preparingVideoHint;
    }

    if (totalCount == 0) {
      return context.l10n.createPackHint2;
    }

    return context.l10n.selectPackHint;
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showCreatePackModal,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.background,
          size: 26,
        ),
      ),
    );
  }
}
