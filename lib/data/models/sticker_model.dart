import 'package:isar/isar.dart';

part 'sticker_model.g.dart';

@embedded
class StickerModel {
  int slotIndex;
  String webpPath;
  String sourceType;
  String stickerType;
  DateTime? createdAt;

  StickerModel({
    this.slotIndex = 0,
    this.webpPath = '',
    this.sourceType = 'local',
    this.stickerType = 'animated',
    this.createdAt,
  });
}
