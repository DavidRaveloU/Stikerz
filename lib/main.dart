// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:whaticker/core/constants/app_colors.dart';
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

  runApp(const ProviderScope(child: App()));
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
