import 'dart:io';

import 'package:isar/isar.dart';

import '../../data/models/sticker_model.dart';
import '../../data/models/sticker_pack_model.dart';

class DuplicatePackNameException implements Exception {
  final String message;
  const DuplicatePackNameException(this.message);

  @override
  String toString() => message;
}

class PackRepository {
  static PackRepository? _instance;
  static Isar? _isar;

  // Singleton
  static PackRepository get instance {
    _instance ??= PackRepository._();
    return _instance!;
  }

  PackRepository._();

  /// Inicializa Isar (debe llamarse una sola vez en main.dart)
  static Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    try {
      print("ISAR: INIT START");

      final dir = Directory('/data/user/0/com.davidravelo.whaticker/files');
      print("ISAR: DIR = ${dir.path}");

      _isar = await Isar.open(
        [StickerPackModelSchema],
        directory: dir.path,
        name: 'whaticker_db',
      );

      print("ISAR: INIT OK");
    } catch (e, stack) {
      print("ISAR ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  Isar get _db {
    if (_isar == null || !_isar!.isOpen) {
      throw Exception(
        'PackRepository no está inicializado. Llama a PackRepository.init() primero.',
      );
    }
    return _isar!;
  }

  String _normalizePackName(String name) {
    return name.trim().toLowerCase();
  }

  // ── Lectura Reactiva ─────────────────────────────────────────────────────

  Stream<List<StickerPackModel>> watchAllPacks() {
    return _db.stickerPackModels.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Stream<StickerPackModel?> watchPack(int id) {
    return _db.stickerPackModels.watchObject(id, fireImmediately: true);
  }

  // ── CRUD Básico ─────────────────────────────────────────────────────────

  Future<StickerPackModel> createPack({
    required String name,
    required String author,
  }) async {
    final normalizedName = _normalizePackName(name);
    final safeName = name.trim();
    final safeAuthor = author.trim();

    final existing = await _db.stickerPackModels.where().findAll();
    final duplicate = existing.any(
      (p) => _normalizePackName(p.name) == normalizedName,
    );

    if (duplicate) {
      throw const DuplicatePackNameException(
        'Ya existe un paquete con ese nombre.',
      );
    }

    final pack = StickerPackModel()
      ..name = safeName
      ..author = safeAuthor
      ..createdAt = DateTime.now()
      ..stickers = [];

    await _db.writeTxn(() => _db.stickerPackModels.put(pack));
    return pack;
  }

  Future<void> deletePack(int id) async {
    await _db.writeTxn(() => _db.stickerPackModels.delete(id));
  }

  Future<void> renamePack(int id, String name, String author) async {
    final normalizedName = _normalizePackName(name);
    final safeName = name.trim();
    final safeAuthor = author.trim();

    final existing = await _db.stickerPackModels.where().findAll();
    final duplicate = existing.any(
      (p) => p.id != id && _normalizePackName(p.name) == normalizedName,
    );

    if (duplicate) {
      throw const DuplicatePackNameException(
        'Ya existe un paquete con ese nombre.',
      );
    }

    final pack = await _db.stickerPackModels.get(id);
    if (pack == null) return;

    pack.name = safeName;
    pack.author = safeAuthor;

    await _db.writeTxn(() => _db.stickerPackModels.put(pack));
  }

  Future<void> updateCover(int id, String? imagePath) async {
    final pack = await _db.stickerPackModels.get(id);
    if (pack == null) return;

    pack.coverImagePath = imagePath;
    await _db.writeTxn(() => _db.stickerPackModels.put(pack));
  }

  // ── Stickers ────────────────────────────────────────────────────────────

  Future<void> addSticker({
    required int packId,
    required int slotIndex,
    required String webpPath,
    required String sourceType,
  }) async {
    final pack = await _db.stickerPackModels.get(packId);
    if (pack == null) return;

    final stickers = List<StickerModel>.from(pack.stickers)
      ..removeWhere((s) => s.slotIndex == slotIndex)
      ..add(
        StickerModel(
          slotIndex: slotIndex,
          webpPath: webpPath,
          sourceType: sourceType,
          createdAt: DateTime.now(),
        ),
      );

    pack.stickers = stickers;

    await _db.writeTxn(() => _db.stickerPackModels.put(pack));
  }

  Future<void> removeSticker(int packId, int slotIndex) async {
    final pack = await _db.stickerPackModels.get(packId);
    if (pack == null) return;

    final stickers = List<StickerModel>.from(pack.stickers)
      ..removeWhere((s) => s.slotIndex == slotIndex);

    pack.stickers = stickers;

    await _db.writeTxn(() => _db.stickerPackModels.put(pack));
  }

  Future<StickerPackModel?> getPackById(int id) async {
    return await _db.stickerPackModels.get(id);
  }
}
