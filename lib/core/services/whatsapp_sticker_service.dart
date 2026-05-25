import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:stikerz/data/models/sticker_model.dart';
import 'package:stikerz/data/models/sticker_pack_model.dart';

class WhatsAppStickerException implements Exception {
  final String message;
  const WhatsAppStickerException(this.message);

  @override
  String toString() => message;
}

class WhatsAppStickerService {
  static const MethodChannel _channel = MethodChannel('stikerz/whatsapp');

  /// Sends a sticker pack to WhatsApp.
  static Future<void> sendPack(StickerPackModel pack) async {
    if (!pack.hasCover) {
      throw const WhatsAppStickerException('The pack requires a cover image.');
    }
    if (pack.stickers.length < 3) {
      throw const WhatsAppStickerException(
        'WhatsApp requires at least 3 stickers per pack.',
      );
    }

    final trayPath = await _generateTrayImage(pack.id, pack.coverImagePath!);

    final sortedStickers = List<StickerModel>.from(pack.stickers)
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    final payload = {
      'identifier': 'pack_${pack.id}',
      'name': pack.name,
      'publisher': pack.author,
      'trayImagePath': trayPath,
      'animated': true,
      'stickers': sortedStickers
          .map(
            (sticker) => {
              'filePath': sticker.webpPath,
              'emojis': const ['😀'],
            },
          )
          .toList(),
    };

    try {
      final success = await _channel.invokeMethod<bool>(
        'exportStickerPack',
        payload,
      );

      if (success != true) {
        throw const WhatsAppStickerException(
          'Unable to open WhatsApp to import the pack.',
        );
      }
    } on PlatformException catch (e) {
      throw WhatsAppStickerException(
        e.message ?? 'Native error communicating with WhatsApp.',
      );
    }
  }

  /// Generates the tray image required by WhatsApp.
  static Future<String> _generateTrayImage(
    int packId,
    String sourcePath,
  ) async {
    final srcFile = File(sourcePath);
    if (!await srcFile.exists()) {
      throw const WhatsAppStickerException('Pack cover image not found.');
    }

    final bytes = await srcFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw const WhatsAppStickerException(
        'Unable to process the cover image.',
      );
    }

    // Create a centered square crop from the source image.
    final side = image.width < image.height ? image.width : image.height;
    final cropped = img.copyCrop(
      image,
      x: (image.width - side) ~/ 2,
      y: (image.height - side) ~/ 2,
      width: side,
      height: side,
    );

    final resized = img.copyResize(
      cropped,
      width: 96,
      height: 96,
      interpolation: img.Interpolation.average,
    );

    // Save to a dedicated tray directory.
    final docsDir = await getApplicationDocumentsDirectory();
    final trayDir = Directory(
      '${docsDir.path}${Platform.pathSeparator}wa_tray',
    );

    if (!await trayDir.exists()) {
      await trayDir.create(recursive: true);
    }

    final outputPath =
        '${trayDir.path}${Platform.pathSeparator}pack_${packId}_tray.png';

    await File(outputPath).writeAsBytes(img.encodePng(resized));

    return outputPath;
  }
}
