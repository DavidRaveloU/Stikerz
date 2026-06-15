import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

/// Exposes the current pack stream by pack ID.
final packDetailProvider = StreamProvider.family<StickerPackModel?, int>((
  ref,
  packId,
) {
  return PackRepository.instance.watchPack(packId);
});

/// Holds the selected tab index (0 = stickers, 1 = info).
final packDetailTabProvider = StateProvider<int>((ref) => 0);
