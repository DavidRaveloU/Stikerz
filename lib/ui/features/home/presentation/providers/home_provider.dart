import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

/// Exposes a stream with all sticker packs.
final packsStreamProvider = StreamProvider<List<StickerPackModel>>((ref) {
  return PackRepository.instance.watchAllPacks();
});

/// Holds the current home search query.
final homeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Returns packs filtered by the current search query.
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

/// Returns the total number of packs without filtering.
final totalPacksCountProvider = Provider<int>((ref) {
  final packsAsync = ref.watch(packsStreamProvider);
  return packsAsync.when(
    data: (packs) => packs.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});
