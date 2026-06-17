import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/providers/share_provider.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/core/services/ads_service.dart';
import 'package:stikerz/core/services/video_preparation_service.dart';
import 'package:stikerz/core/utils/error_localization.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/data/models/sticker_model.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';
import 'package:stikerz/ui/features/image_editor/presentation/pages/image_editor_page.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/providers/pack_detail_provider.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/add_sticker_sheet.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/pack_detail_hero.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/pack_info.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/pack_options_sheet.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/rename_pack_modal.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/sticker_grid.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/sticker_preview_sheet.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/whatsapp_button.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/pages/video_preparation_page.dart';
import 'package:stikerz/ui/features/video_picker/presentation/pages/video_picker_page.dart';

class PackDetailPage extends ConsumerStatefulWidget {
  final int packId;
  final String heroTag;
  final VoidCallback? preloadInterstitialAd;
  final Widget? heroCoverPreview;

  const PackDetailPage({
    super.key,
    required this.packId,
    required this.heroTag,
    this.preloadInterstitialAd,
    this.heroCoverPreview,
  });

  @override
  ConsumerState<PackDetailPage> createState() => _PackDetailPageState();
}

class _PackDetailPageState extends ConsumerState<PackDetailPage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _lastFullPackWarningKey;

  @override
  void initState() {
    super.initState();
    // Preload interstitial so it is ready after sticker creation.
    (widget.preloadInterstitialAd ?? AdsService().loadInterstitialAd)();
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.processCoverError)));
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
            _openEditorWhenReady(
              videoPath: videoPath,
              slotIndex: index,
              sourceType: 'local',
            );
          });
        },
        onImage: () async {
          Navigator.pop(context);
          final picked = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 95,
          );
          if (picked == null || !mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageEditorPage(
                packId: widget.packId,
                slotIndex: index,
                imagePath: picked.path,
              ),
            ),
          );
        },
        onTikTokUrl: (videoUrl) {
          _openEditorWhenReady(
            videoPath: videoUrl,
            slotIndex: index,
            sourceType: 'tiktok',
          );
        },
        onInstagramUrl: (videoUrl) {
          _openEditorWhenReady(
            videoPath: videoUrl,
            slotIndex: index,
            sourceType: 'instagram',
          );
        },
      ),
    );
  }

  void _openEditorWhenReady({
    required String videoPath,
    required int slotIndex,
    required String sourceType,
  }) {
    final route = VideoPreparationService.isRemoteVideoSource(videoPath)
        ? MaterialPageRoute(
            builder: (_) => VideoPreparationPage(
              packId: widget.packId,
              slotIndex: slotIndex,
              sourceType: sourceType,
              videoPath: videoPath,
            ),
          )
        : MaterialPageRoute(
            builder: (_) => StickerEditorPage(
              packId: widget.packId,
              slotIndex: slotIndex,
              sourceType: sourceType,
              videoPath: videoPath,
            ),
          );

    Navigator.push(context, route);
  }

  void _showPackOptions(StickerPackModel pack) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => PackOptionsSheet(
        onRename: () {
          Navigator.of(dialogContext).pop();
          _showRenameModal(pack);
        },
        onDelete: () async {
          Navigator.of(dialogContext).pop();
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
    final pendingShare = ref.watch(pendingShareProvider);

    return packAsync.when(
      data: (pack) {
        if (pack == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const Scaffold(backgroundColor: AppColors.background);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final currentPending = ref.read(pendingShareProvider);
          if (currentPending == null) return;

          if (currentPending.error != null) {
            final display = localizeServiceError(context, currentPending.error);
            ref.read(pendingShareProvider.notifier).state = null;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(display)));
            return;
          }

          if (!currentPending.hasResolvedVideo || currentPending.isResolving) {
            return;
          }

          int? empty;
          for (var i = 0; i < 30; i++) {
            if (pack.stickerAt(i) == null) {
              empty = i;
              break;
            }
          }

          if (empty == null) {
            final warningKey = '${widget.packId}:${currentPending.rawText}';
            if (_lastFullPackWarningKey != warningKey) {
              _lastFullPackWarningKey = warningKey;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.fullPackWarning)),
              );
            }
            return;
          }

          final videoUrl = currentPending.resolvedVideoUrl!;
          final int slotIndex = empty;
          ref.read(pendingShareProvider.notifier).state = null;
          _openEditorWhenReady(
            videoPath: videoUrl,
            slotIndex: slotIndex,
            sourceType: currentPending.source,
          );
        });

        return _buildScreen(pack, pendingShare: pendingShare);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('${context.l10n.error}: $error')),
      ),
    );
  }

  Widget _buildScreen(StickerPackModel pack, {PendingShare? pendingShare}) {
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
                    coverPreview: widget.heroCoverPreview,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsiveSize(16, tabletSize: 20),
                    context.responsiveSize(16, tabletSize: 20),
                    context.responsiveSize(16, tabletSize: 20),
                    context.responsiveSize(120, tabletSize: 132),
                  ),
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
              bottom: context.responsiveSize(35, tabletSize: 42),
              left: 0,
              right: 0,
              child: Center(child: WhatsAppButton(pack: pack)),
            ),
            if (pendingShare != null && pendingShare.isResolving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.72),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                        SizedBox(
                          height: context.responsiveSize(16, tabletSize: 20),
                        ),
                        Text(
                          context.l10n.resolvingSharedVideo,
                          style: context.responsiveTextStyle(
                            mobileSize: 14,
                            tabletSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
