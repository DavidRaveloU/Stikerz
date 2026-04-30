import 'package:whaticker/data/models/sticker_model.dart';

/// Entidad limpia para usar en la UI y lógica de negocio
class Sticker {
  final int slotIndex;
  final String webpPath;
  final String sourceType; // 'tiktok' | 'local'
  final DateTime? createdAt;

  const Sticker({
    this.slotIndex = 0,
    this.webpPath = '',
    this.sourceType = 'local',
    this.createdAt,
  });

  Sticker copyWith({
    int? slotIndex,
    String? webpPath,
    String? sourceType,
    DateTime? createdAt,
  }) {
    return Sticker(
      slotIndex: slotIndex ?? this.slotIndex,
      webpPath: webpPath ?? this.webpPath,
      sourceType: sourceType ?? this.sourceType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Conversión desde el modelo de Isar
  factory Sticker.fromModel(StickerModel model) {
    return Sticker(
      slotIndex: model.slotIndex,
      webpPath: model.webpPath,
      sourceType: model.sourceType,
      createdAt: model.createdAt,
    );
  }

  // Conversión hacia el modelo de Isar
  StickerModel toModel() {
    return StickerModel(
      slotIndex: slotIndex,
      webpPath: webpPath,
      sourceType: sourceType,
      createdAt: createdAt,
    );
  }
}
