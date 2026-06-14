import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:media_kit/media_kit.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:stikerz/core/config/ads_config.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/providers/settings_provider.dart';
import 'package:stikerz/core/providers/share_provider.dart';
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

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('In-app update check failed: $e');
    }
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
