import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/providers/settings_provider.dart';
import 'package:stikerz/core/providers/share_provider.dart';
import 'package:stikerz/core/providers/update_provider.dart';
import 'package:stikerz/core/repositories/app_state_repository.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/core/services/ads_service.dart';
import 'package:stikerz/generated_l10n/app_localizations.dart';
import 'package:stikerz/routes/app_router.dart' show appRouterProvider;

Future<void> main(List<String> args) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      MediaKit.ensureInitialized();
      if (AdsConfig.adsEnabled) {
        await AdsService().initialize();
      }

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await PackRepository.init();
      await PackRepository.instance.migrateMissingIdentifiers();
      await AppStateRepository.instance.isOnboardingCompleted();

      runApp(const ProviderScope(child: ShareIntentHandler()));
    },
    (error, stack) {
      if (kDebugMode) debugPrint("ZONED ERROR: $error");
      if (kDebugMode) debugPrintStack(stackTrace: stack);
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
  int _shareRequestEpoch = 0;

  String _extractSharedText(List<SharedMediaFile> items) {
    if (items.isEmpty) return '';

    final first = items.first;
    final rawText = first.mimeType != null && first.mimeType!.startsWith('text')
        ? first.path
        : (first.path.isNotEmpty ? first.path : first.message ?? '');

    return rawText.trim();
  }

  Future<void> _handleSharedItemsInitial(List<SharedMediaFile> items) async {
    final text = _extractSharedText(items);
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

    // Después de resolver el share, verificar actualizaciones en segundo plano
    _checkForUpdateAfterShare();
  }

  Future<void> _handleSharedItemsStream(List<SharedMediaFile> items) async {
    final text = _extractSharedText(items);
    if (text.isEmpty) return;

    final requestEpoch = ++_shareRequestEpoch;
    ref.read(pendingShareProvider.notifier).state = null;
    ref.read(shareFlowResetProvider.notifier).state++;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || requestEpoch != _shareRequestEpoch) return;

    final pending = PendingShare(
      rawText: text,
      source: detectShareSource(text),
      isResolving: true,
    );

    ref.read(pendingShareProvider.notifier).state = pending;

    final resolved = await resolvePendingShare(pending);

    if (!mounted || requestEpoch != _shareRequestEpoch) return;

    ref.read(pendingShareProvider.notifier).state = resolved;

    // Después de resolver el share, verificar actualizaciones en segundo plano
    _checkForUpdateAfterShare();
  }

  /// Verifica actualizaciones en segundo plano después de resolver el share
  void _checkForUpdateAfterShare() {
    // Esperar un momento para no interferir con el flujo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(silentUpdateCheckProvider);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    try {
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then(_handleSharedItemsInitial)
          .catchError((e) {
            if (kDebugMode) debugPrint("ERROR getInitialMedia: $e");
          });

      _textSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (items) {
          _handleSharedItemsStream(items);
        },
        onError: (e) {
          if (kDebugMode) debugPrint("ERROR mediaStream: $e");
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint("ERROR INIT INTENT: $e");
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

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  bool _updateCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Verificar actualizaciones al inicio normal
    _checkForUpdateOnStartup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve a primer plano, verificar si hay actualización
    if (state == AppLifecycleState.resumed) {
      _checkForUpdateOnResume();
    }
  }

  Future<void> _checkForUpdateOnStartup() async {
    // Verificación silenciosa al inicio
    final updateService = ref.read(updateServiceProvider);
    await updateService.checkForUpdateSilent();

    // Si hay actualización, mostrarla después de un breve momento
    // (cuando el usuario ya haya visto la UI)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && ref.read(updateAvailableProvider)) {
        _showUpdateIfAvailable();
      }
    });
  }

  void _checkForUpdateOnResume() {
    if (_updateCheckScheduled) return;
    _updateCheckScheduled = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      _updateCheckScheduled = false;
      if (mounted) {
        ref.read(silentUpdateCheckProvider);
        // Si hay actualización disponible, mostrarla
        if (ref.read(updateAvailableProvider)) {
          _showUpdateIfAvailable();
        }
      }
    });
  }

  void _showUpdateIfAvailable() {
    // Usamos un pequeño delay para no interrumpir ninguna animación o transición
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(updateServiceProvider).showUpdateIfAvailable();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final selectedLang = ref.watch(settingsProvider);
    final locale = selectedLang == null ? null : Locale(selectedLang);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
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
}
