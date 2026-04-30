import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:whaticker/data/models/sticker_model.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

class WhatsAppStickerException implements Exception {
  final String message;
  const WhatsAppStickerException(this.message);

  @override
  String toString() => message;
}

class WhatsAppStickerService {
  static const MethodChannel _channel = MethodChannel('whaticker/whatsapp');

  /// Envía un paquete de stickers a WhatsApp
  static Future<void> sendPack(StickerPackModel pack) async {
    if (!pack.hasCover) {
      throw const WhatsAppStickerException('El pack necesita una portada.');
    }
    if (pack.stickers.length < 3) {
      throw const WhatsAppStickerException(
        'WhatsApp requiere al menos 3 stickers por paquete.',
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
          'No se pudo abrir WhatsApp para importar el paquete.',
        );
      }
    } on PlatformException catch (e) {
      throw WhatsAppStickerException(
        e.message ?? 'Error nativo al comunicarse con WhatsApp.',
      );
    }
  }

  /// Genera la imagen de portada (tray) requerida por WhatsApp
  static Future<String> _generateTrayImage(
    int packId,
    String sourcePath,
  ) async {
    final srcFile = File(sourcePath);
    if (!await srcFile.exists()) {
      throw const WhatsAppStickerException(
        'No se encontró la portada del pack.',
      );
    }

    final bytes = await srcFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw const WhatsAppStickerException(
        'No se pudo procesar la imagen de portada.',
      );
    }

    // Crear imagen cuadrada centrada
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

    // Guardar en directorio dedicado
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
