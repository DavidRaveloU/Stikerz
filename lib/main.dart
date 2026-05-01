// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/providers/share_provider.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/routes/app_router.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar MediaKit (NO es async, por eso sin await)
  MediaKit.ensureInitialized();

  // Inicializar Isar a través del Repository
  await PackRepository.init();

  runApp(ProviderScope(child: ShareIntentHandler()));
}

class ShareIntentHandler extends ConsumerStatefulWidget {
  const ShareIntentHandler({super.key});

  @override
  ConsumerState<ShareIntentHandler> createState() => _ShareIntentHandlerState();
}

class _ShareIntentHandlerState extends ConsumerState<ShareIntentHandler> {
  StreamSubscription<List<SharedMediaFile>>? _textSub;

  Future<void> _handleSharedItems(List<SharedMediaFile> items) async {
    if (items.isEmpty) return;

    final first = items.first;
    final rawText = first.mimeType != null && first.mimeType!.startsWith('text')
        ? first.path
        : (first.path.isNotEmpty ? first.path : first.message ?? '');

    final text = rawText.trim();
    if (text.isEmpty) return;

    final pending = PendingShare(
      rawText: text,
      source: detectShareSource(text),
      isResolving: true,
    );
    ref.read(pendingShareProvider.notifier).state = pending;

    final resolved = await resolvePendingShare(pending);
    if (!mounted) return;
    ref.read(pendingShareProvider.notifier).state = resolved;
  }

  @override
  void initState() {
    super.initState();

    // Obtener texto o media inicial (cold start)
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then(_handleSharedItems)
        .catchError((_) {});

    // Escuchar cuando la app ya está en foreground (media stream)
    _textSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handleSharedItems,
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _textSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Whaticker',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,

      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
        ),
      ),
    );
  }
}
