import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/providers/share_provider.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/generated_l10n/app_localizations.dart';
import 'package:whaticker/routes/app_router.dart' show appRouterProvider;

Future<void> main(List<String> args) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      MediaKit.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await PackRepository.init();

      runApp(const ProviderScope(child: ShareIntentHandler()));
    },
    (error, stack) {
      debugPrint("ZONED ERROR: $error");
      debugPrintStack(stackTrace: stack);
    },
  );
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

    try {
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then(_handleSharedItems)
          .catchError((e) {
            debugPrint("ERROR getInitialMedia: $e");
          });

      _textSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        _handleSharedItems,
        onError: (e) {
          debugPrint("ERROR mediaStream: $e");
        },
      );
    } catch (e) {
      debugPrint("ERROR INIT INTENT: $e");
    }
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
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: _getLocale(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
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

  static Locale _getLocale() {
    // Get device locale from PlatformDispatcher
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final deviceLanguage = deviceLocale.languageCode.toLowerCase();

    // Supported languages
    const supportedLanguages = ['en', 'es', 'pt'];

    // If device language matches one of our supported languages, use it
    if (supportedLanguages.contains(deviceLanguage)) {
      return Locale(deviceLanguage);
    }

    // Default to English if not supported
    return const Locale('en');
  }
}
