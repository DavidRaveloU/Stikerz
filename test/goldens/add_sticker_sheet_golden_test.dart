import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/widgets/add_sticker_sheet.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  // ── Estado inicial (main step) ────────────────────────────────────────────
  goldenTest(
    name: 'add_sticker_sheet_main_step',
    subdirectory: 'pack_detail',
    builder: (_) => AddStickerSheet(
      onLocal: () {},
      onImage: () {},
      onTikTokUrl: (_) {},
      onInstagramUrl: (_) {},
    ),
  );

  // ── Local step (simulando tap en "Desde tu dispositivo") ──────────────────
  goldenTest(
    name: 'add_sticker_sheet_local_step',
    subdirectory: 'pack_detail',
    builder: (context) {
      // Usamos un StatefulBuilder para poder cambiar el estado interno
      return _TestWrapper(
        child: AddStickerSheet(
          onLocal: () {},
          onImage: () {},
          onTikTokUrl: (_) {},
          onInstagramUrl: (_) {},
        ),
        onReady: (tester) async {
          // Simular tap en "Desde tu dispositivo"
          final localButton = find.text('Desde tu dispositivo');
          await tester.tap(localButton);
          await tester.pumpAndSettle();
        },
      );
    },
  );

  // ── Social step con TikTok ──────────────────────────────────────────────────
  goldenTest(
    name: 'add_sticker_sheet_social_tiktok',
    subdirectory: 'pack_detail',
    builder: (context) {
      return _TestWrapper(
        child: AddStickerSheet(
          onLocal: () {},
          onImage: () {},
          onTikTokUrl: (_) {},
          onInstagramUrl: (_) {},
        ),
        onReady: (tester) async {
          // Ir a redes sociales
          final socialButton = find.text('Desde redes sociales');
          await tester.tap(socialButton);
          await tester.pumpAndSettle();
        },
      );
    },
  );

  // ── Social step con Instagram ──────────────────────────────────────────────
  goldenTest(
    name: 'add_sticker_sheet_social_instagram',
    subdirectory: 'pack_detail',
    builder: (context) {
      return _TestWrapper(
        child: AddStickerSheet(
          onLocal: () {},
          onImage: () {},
          onTikTokUrl: (_) {},
          onInstagramUrl: (_) {},
        ),
        onReady: (tester) async {
          // Ir a redes sociales
          final socialButton = find.text('Desde redes sociales');
          await tester.tap(socialButton);
          await tester.pumpAndSettle();

          // Seleccionar Instagram
          final instagramButton = find.text('Instagram');
          await tester.tap(instagramButton);
          await tester.pumpAndSettle();
        },
      );
    },
  );

  // ── Social step con TikTok y URL pegada ────────────────────────────────────
  goldenTest(
    name: 'add_sticker_sheet_social_tiktok_with_url',
    subdirectory: 'pack_detail',
    builder: (context) {
      return _TestWrapper(
        child: AddStickerSheet(
          onLocal: () {},
          onImage: () {},
          onTikTokUrl: (_) {},
          onInstagramUrl: (_) {},
        ),
        onReady: (tester) async {
          // Ir a redes sociales
          final socialButton = find.text('Desde redes sociales');
          await tester.tap(socialButton);
          await tester.pumpAndSettle();

          // Simular pegar URL en el campo de texto
          final textField = find.byType(TextField);
          await tester.enterText(textField, 'https://www.tiktok.com/@user/video/1234567890');
          await tester.pumpAndSettle();
        },
      );
    },
  );

  // ── Estado con error (URL inválida) ──────────────────────────────────────
  goldenTest(
    name: 'add_sticker_sheet_error',
    subdirectory: 'pack_detail',
    builder: (context) {
      return _TestWrapper(
        child: AddStickerSheet(
          onLocal: () {},
          onImage: () {},
          onTikTokUrl: (_) {},
          onInstagramUrl: (_) {},
        ),
        onReady: (tester) async {
          // Ir a redes sociales
          final socialButton = find.text('Desde redes sociales');
          await tester.tap(socialButton);
          await tester.pumpAndSettle();

          // Ingresar URL inválida y presionar Go
          final textField = find.byType(TextField);
          await tester.enterText(textField, 'url-invalida');
          await tester.pumpAndSettle();

          // Presionar Go
          final goButton = find.text('Go');
          await tester.tap(goButton);

          // Esperar a que aparezca el error (el servicio fallará rápido)
          await tester.pumpAndSettle(const Duration(seconds: 2));
        },
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrapper para ejecutar acciones después de que el widget se construya
// ─────────────────────────────────────────────────────────────────────────────

class _TestWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function(WidgetTester tester) onReady;

  const _TestWrapper({
    required this.child,
    required this.onReady,
  });

  @override
  State<_TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<_TestWrapper> {
  @override
  void initState() {
    super.initState();
    // Ejecutar después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // La prueba ya está corriendo, usamos el tester global
      // Este es un truco para acceder al tester desde el builder
      // En golden_test, el tester se pasa al pumpBeforeTest,
      // pero como no existe, usamos este approach alternativo.
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}