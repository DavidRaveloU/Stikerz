import 'dart:io';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/app_state_model.dart';
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

  /// Initialize Isar (should be called once from main.dart)
  static Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    try {
      final dir = Directory('/data/user/0/com.davidravelo.stikerz/files');

      _isar = await Isar.open(
        [StickerPackModelSchema, AppStateModelSchema],
        directory: dir.path,
        name: 'stikerz_db',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Isar? get db => _isar;

  Isar get _db {
    if (_isar == null || !_isar!.isOpen) {
      throw Exception(
        'PackRepository is not initialized. Call PackRepository.init() first.',
      );
    }
    return _isar!;
  }

  String _normalizePackName(String name) {
    return name.trim().toLowerCase();
  }

  // ── Reactive reads ─────────────────────────────────────────────────────

  Stream<List<StickerPackModel>> watchAllPacks() {
    return _db.stickerPackModels.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Stream<StickerPackModel?> watchPack(int id) {
    return _db.stickerPackModels.watchObject(id, fireImmediately: true);
  }

  // ── Basic CRUD ─────────────────────────────────────────────────────────

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
        'A pack with that name already exists.',
      );
    }

    final pack = StickerPackModel()
      ..name = safeName
      ..author = safeAuthor
      ..createdAt = DateTime.now()
      ..identifier = const Uuid().v4()
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
        'A pack with that name already exists.',
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

  Future<void> migrateMissingIdentifiers() async {
    final all = await _db.stickerPackModels.where().findAll();
    final toFix = all.where((p) => p.identifier.isEmpty).toList();

    if (toFix.isEmpty) return;

    await _db.writeTxn(() async {
      for (final pack in toFix) {
        pack.identifier = const Uuid().v4();
        await _db.stickerPackModels.put(pack);
      }
    });
  }
}
