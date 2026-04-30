import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/data/models/sticker_model.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/providers/pack_detail_provider.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/add_sticker_sheet.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/pack_detail_hero.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/pack_info.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/pack_options_sheet.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/rename_pack_modal.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/sticker_grid.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/sticker_preview_sheet.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/widgets/whatsapp_button.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';
import 'package:whaticker/ui/features/video_picker/presentation/pages/video_picker_page.dart';

class PackDetailPage extends ConsumerStatefulWidget {
  final int packId;
  final String heroTag;

  const PackDetailPage({
    super.key,
    required this.packId,
    required this.heroTag,
  });

  @override
  ConsumerState<PackDetailPage> createState() => _PackDetailPageState();
}

class _PackDetailPageState extends ConsumerState<PackDetailPage> {
  final ImagePicker _imagePicker = ImagePicker();

  // ── Acciones ─────────────────────────────────────────────────────────────

  Future<void> _onCoverTap(StickerPackModel pack) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked == null) return;

    final processedPath = await _createCenteredSquareCover(
      inputPath: picked.path,
      packId: widget.packId,
    );

    if (processedPath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo procesar la portada.')),
      );
      return;
    }

    await PackRepository.instance.updateCover(widget.packId, processedPath);

    final oldCover = pack.coverImagePath;
    if (oldCover != null &&
        oldCover != processedPath &&
        oldCover.contains(
          '${Platform.pathSeparator}pack_covers${Platform.pathSeparator}',
        )) {
      await _safeDeleteFile(oldCover);
    }
  }

  Future<String?> _createCenteredSquareCover({
    required String inputPath,
    required int packId,
  }) async {
    try {
      final inputBytes = await File(inputPath).readAsBytes();
      final decoded = img.decodeImage(inputBytes);
      if (decoded == null) return null;

      final side = math.min(decoded.width, decoded.height);
      final offsetX = ((decoded.width - side) / 2).floor();
      final offsetY = ((decoded.height - side) / 2).floor();

      final square = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: side,
        height: side,
      );
      final normalized = img.copyResize(
        square,
        width: 512,
        height: 512,
        interpolation: img.Interpolation.average,
      );

      final docsDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(
        '${docsDir.path}${Platform.pathSeparator}pack_covers',
      );
      if (!await coversDir.exists()) await coversDir.create(recursive: true);

      final fileName =
          'pack_${packId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputPath = '${coversDir.path}${Platform.pathSeparator}$fileName';
      final outFile = File(outputPath);
      await outFile.writeAsBytes(img.encodeJpg(normalized, quality: 90));
      return outputPath;
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeDeleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  void _onSlotTap(StickerPackModel pack, int index) {
    final sticker = pack.stickerAt(index);
    if (sticker != null) {
      _showStickerPreviewSheet(sticker);
    } else {
      _showAddStickerSheet(index);
    }
  }

  void _showStickerPreviewSheet(StickerModel sticker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StickerPreviewSheet(
        webpPath: sticker.webpPath,
        onDelete: () async {
          Navigator.pop(context);
          await PackRepository.instance.removeSticker(
            widget.packId,
            sticker.slotIndex,
          );
        },
      ),
    );
  }

  void _showAddStickerSheet(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddStickerSheet(
        onLocal: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VideoPickerPage()),
          ).then((videoPath) {
            if (videoPath == null || !mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StickerEditorPage(
                  packId: widget.packId,
                  slotIndex: index,
                  sourceType: 'local',
                  videoPath: videoPath,
                ),
              ),
            );
          });
        },
        onTikTokUrl: (videoUrl) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StickerEditorPage(
                packId: widget.packId,
                slotIndex: index,
                sourceType: 'tiktok',
                videoPath: videoUrl,
              ),
            ),
          );
        },
        onInstagramUrl: (videoUrl) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StickerEditorPage(
                packId: widget.packId,
                slotIndex: index,
                sourceType: 'instagram',
                videoPath: videoUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPackOptions(StickerPackModel pack) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PackOptionsSheet(
        onRename: () {
          Navigator.pop(context);
          _showRenameModal(pack);
        },
        onDelete: () async {
          Navigator.pop(context);
          await PackRepository.instance.deletePack(widget.packId);
        },
      ),
    );
  }

  void _showRenameModal(StickerPackModel pack) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RenamePackModal(
        currentName: pack.name,
        currentAuthor: pack.author,
        onSave: (name, author) async {
          await PackRepository.instance.renamePack(widget.packId, name, author);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packAsync = ref.watch(packDetailProvider(widget.packId));

    return packAsync.when(
      data: (pack) {
        if (pack == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const Scaffold(backgroundColor: AppColors.background);
        }

        return _buildScreen(pack);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildScreen(StickerPackModel pack) {
    final selectedTab = ref.watch(packDetailTabProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PackDetailHero(
                    pack: pack,
                    heroTag: widget.heroTag,
                    onCoverTap: () => _onCoverTap(pack),
                    onOptionsTap: () => _showPackOptions(pack),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: selectedTab == 0
                      ? StickerGrid(
                          pack: pack,
                          onSlotTap: (index) => _onSlotTap(pack, index),
                        )
                      : SliverToBoxAdapter(child: PackInfo(pack: pack)),
                ),
              ],
            ),
            Positioned(
              bottom: 35,
              left: 0,
              right: 0,
              child: Center(child: WhatsAppButton(pack: pack)),
            ),
          ],
        ),
      ),
    );
  }
}
