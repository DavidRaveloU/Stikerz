import 'package:whaticker/data/models/sticker_pack_model.dart';

import 'sticker.dart';

/// Entidad limpia para usar en UI y lógica de negocio
class StickerPack {
  final int? id;
  final String name;
  final String author;
  final String? coverImagePath;
  final DateTime createdAt;
  final List<Sticker> stickers;

  const StickerPack({
    this.id,
    required this.name,
    required this.author,
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
    String? coverImagePath,
    DateTime? createdAt,
    List<Sticker>? stickers,
  }) {
    return StickerPack(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
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
      coverImagePath: model.coverImagePath,
      createdAt: model.createdAt,
      stickers: model.stickers.map((s) => Sticker.fromModel(s)).toList(),
    );
  }
}
