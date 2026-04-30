import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

/// Provider que expone el stream del paquete actual por ID
final packDetailProvider = StreamProvider.family<StickerPackModel?, int>((
  ref,
  packId,
) {
  return PackRepository.instance.watchPack(packId);
});

/// Provider para el tab seleccionado (0 = Stickers, 1 = Info)
final packDetailTabProvider = StateProvider<int>((ref) => 0);
