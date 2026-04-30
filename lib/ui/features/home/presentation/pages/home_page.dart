import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/constants/app_colors.dart';
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
        title: const Text(
          'Eliminar paquete',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Eliminar "${pack.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PackRepository.instance.deletePack(pack.id);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 16),
          Text(
            'No tienes paquetes aún',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Toca el botón + para crear tu primer paquete',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
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
