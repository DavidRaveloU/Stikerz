import 'package:isar/isar.dart';

import 'sticker_model.dart';

part 'sticker_pack_model.g.dart';

@collection
class StickerPackModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String author;
  String? coverImagePath;
  late DateTime createdAt;

  List<StickerModel> stickers = [];

  // ── Helpers ──────────────────────────────────────────────────────────────

  StickerModel? stickerAt(int slotIndex) {
    try {
      return stickers.firstWhere((s) => s.slotIndex == slotIndex);
    } catch (_) {
      return null;
    }
  }

  int get filledCount => stickers.length;
  bool get hasCover => coverImagePath != null && coverImagePath!.isNotEmpty;
  bool get isFull => stickers.length >= 30;
  bool get canSendToWhatsApp => hasCover && stickers.length >= 3;
}
