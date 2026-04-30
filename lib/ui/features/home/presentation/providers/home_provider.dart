import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

/// Provider que expone el stream de todos los paquetes
final packsStreamProvider = StreamProvider<List<StickerPackModel>>((ref) {
  return PackRepository.instance.watchAllPacks();
});

/// Provider para el estado de búsqueda (query)
final homeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider derivado: paquetes filtrados según la búsqueda
final filteredPacksProvider = Provider<List<StickerPackModel>>((ref) {
  final packsAsync = ref.watch(packsStreamProvider);
  final searchQuery = ref.watch(homeSearchQueryProvider);

  return packsAsync.when(
    data: (packs) {
      if (searchQuery.trim().isEmpty) {
        return packs;
      }

      final query = searchQuery.trim().toLowerCase();
      return packs
          .where((pack) => pack.name.toLowerCase().contains(query))
          .toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider para contar total de paquetes (sin filtro)
final totalPacksCountProvider = Provider<int>((ref) {
  final packsAsync = ref.watch(packsStreamProvider);
  return packsAsync.when(
    data: (packs) => packs.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});
