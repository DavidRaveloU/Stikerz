import 'package:stikerz/data/models/sticker_pack_model.dart';

import 'sticker.dart';

class StickerPack {
  final int? id;
  final String name;
  final String author;
  final String identifier;
  final String? coverImagePath;
  final DateTime createdAt;
  final List<Sticker> stickers;

  const StickerPack({
    this.id,
    required this.name,
    required this.author,
    required this.identifier,
    this.coverImagePath,
    required this.createdAt,
    required this.stickers,
  });

  int get filledCount => stickers.length;
  bool get hasCover => coverImagePath != null && coverImagePath!.isNotEmpty;
  bool get isFull => stickers.length >= 30;
  bool get canSendToWhatsApp => hasCover && stickers.length >= 3;

  Sticker? stickerAt(int slotIndex) {
    try {
      return stickers.firstWhere((s) => s.slotIndex == slotIndex);
    } catch (_) {
      return null;
    }
  }

  StickerPack copyWith({
    int? id,
    String? name,
    String? author,
    String? identifier,
    String? coverImagePath,
    DateTime? createdAt,
    List<Sticker>? stickers,
  }) {
    return StickerPack(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      identifier: identifier ?? this.identifier,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      createdAt: createdAt ?? this.createdAt,
      stickers: stickers ?? List.unmodifiable(this.stickers),
    );
  }

  factory StickerPack.fromModel(StickerPackModel model) {
    return StickerPack(
      id: model.id,
      name: model.name,
      author: model.author,
      identifier: model.identifier,
      coverImagePath: model.coverImagePath,
      createdAt: model.createdAt,
      stickers: model.stickers.map((s) => Sticker.fromModel(s)).toList(),
    );
  }
}
