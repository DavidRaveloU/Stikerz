import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/providers/share_provider.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/components/create_pack_modal.dart';
import 'package:stikerz/ui/features/home/presentation/providers/home_provider.dart';
import 'package:stikerz/ui/features/home/presentation/widgets/home_header.dart';
import 'package:stikerz/ui/features/home/presentation/widgets/home_search_bar.dart';
import 'package:stikerz/ui/features/home/presentation/widgets/pack_list.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/pages/pack_detail_page.dart';

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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.l10n.deletePackTitle,
          style: context.responsiveTextStyle(
            mobileSize: 18,
            tabletSize: 20,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          context.l10n.deletePackMessage(pack.name),
          style: context.responsiveTextStyle(
            mobileSize: 14,
            tabletSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              context.l10n.cancel,
              style: context.responsiveTextStyle(
                mobileSize: 14,
                tabletSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await PackRepository.instance.deletePack(pack.id);
            },
            child: Text(
              context.l10n.delete,
              style: context.responsiveTextStyle(
                mobileSize: 14,
                tabletSize: 15,
                color: Colors.redAccent,
              ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(16, tabletSize: 20),
                    vertical: context.responsiveSize(8, tabletSize: 10),
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
                      child: Padding(
                        padding: EdgeInsets.all(
                          context.responsiveSize(12, tabletSize: 14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              pending.isResolving
                                  ? Icons.hourglass_top_rounded
                                  : Icons.add_to_photos_rounded,
                              color: AppColors.accent,
                              size: context.responsiveSize(22, tabletSize: 24),
                            ),
                            SizedBox(
                              width: context.responsiveSize(12, tabletSize: 14),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _shareBannerTitle(pending, totalCount),
                                    style: context.responsiveTextStyle(
                                      mobileSize: 15,
                                      tabletSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(
                                    height: context.responsiveSize(
                                      2,
                                      tabletSize: 3,
                                    ),
                                  ),
                                  Text(
                                    _shareBannerSubtitle(pending, totalCount),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.responsiveTextStyle(
                                      mobileSize: 13,
                                      tabletSize: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: context.responsiveSize(8, tabletSize: 10),
                            ),
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
                    ? _buildEmptyState(context)
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
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: context.responsiveSize(48, tabletSize: 56),
            color: AppColors.textMuted,
          ),
          SizedBox(height: context.responsiveSize(16, tabletSize: 20)),
          Text(
            context.l10n.noPacksTitle,
            style: context.responsiveTextStyle(
              mobileSize: 18,
              tabletSize: 22,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
          Text(
            context.l10n.noPacksDesc,
            style: context.responsiveTextStyle(
              mobileSize: 13,
              tabletSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _shareBannerTitle(PendingShare pending, int totalCount) {
    if (pending.isResolving) return context.l10n.preparingVideo;
    if (totalCount == 0) return context.l10n.createPackFirst;
    return context.l10n.selectPackTitle;
  }

  String _shareBannerSubtitle(PendingShare pending, int totalCount) {
    if (pending.isResolving) return context.l10n.convertingLink;
    if (totalCount == 0) return context.l10n.createPackHint;
    return context.l10n.selectPackDesc;
  }

  String _shareBannerHint(PendingShare pending, int totalCount) {
    if (pending.isResolving) return context.l10n.preparingVideoHint;
    if (totalCount == 0) return context.l10n.createPackHint2;
    return context.l10n.selectPackHint;
  }

  Widget _buildFAB(BuildContext context) {
    // Fixed dimensions are fine here because this control has no text.
    final fabSize = context.responsiveSize(54, tabletSize: 60);
    final iconSize = context.responsiveSize(26, tabletSize: 28);

    return GestureDetector(
      onTap: _showCreatePackModal,
      child: Container(
        width: fabSize,
        height: fabSize,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          color: AppColors.background,
          size: iconSize,
        ),
      ),
    );
  }
}
