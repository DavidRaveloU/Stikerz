import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whaticker/core/providers/onboarding_provider.dart';
import 'package:whaticker/routes/route_paths.dart';
import 'package:whaticker/ui/features/home/presentation/pages/home_page.dart';
import 'package:whaticker/ui/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/pages/pack_detail_page.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';
import 'package:whaticker/ui/features/video_picker/presentation/pages/video_picker_page.dart';

/// GlobalRouteObserver para detectar cambios de rutas de navegación
final routeObserver = RouteObserver<PageRoute>();

/// Provider para el GoRouter dinámico basado en onboarding state
final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: onboardingCompleted
        ? RoutePaths.home
        : RoutePaths.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Si el onboarding no está completado, redirigir al onboarding
      if (!onboardingCompleted && state.uri.path != RoutePaths.onboarding) {
        return RoutePaths.onboarding;
      }
      // Si el onboarding está completado y estamos en onboarding, ir a home
      if (onboardingCompleted && state.uri.path == RoutePaths.onboarding) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '${RoutePaths.details}/:packId',
        builder: (context, state) {
          final packId = int.parse(state.pathParameters['packId']!);
          final heroTag = 'pack_cover_$packId';
          return PackDetailPage(packId: packId, heroTag: heroTag);
        },
      ),
      GoRoute(
        path: '${RoutePaths.editor}/:packId/:slotIndex/:sourceType',
        builder: (context, state) {
          final packId = int.parse(state.pathParameters['packId']!);
          final slotIndex = int.parse(state.pathParameters['slotIndex']!);
          final sourceType =
              state.pathParameters['sourceType']!; // 'tiktok' o 'local'

          return StickerEditorPage(
            packId: packId,
            slotIndex: slotIndex,
            sourceType: sourceType,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.picker,
        builder: (context, state) => const VideoPickerPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página no encontrada: ${state.uri}')),
    ),
  );
});

// Router estático (legacy - mantener por compatibilidad)
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,

  routes: [
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '${RoutePaths.details}/:packId',
      builder: (context, state) {
        final packId = int.parse(state.pathParameters['packId']!);
        final heroTag = 'pack_cover_$packId';
        return PackDetailPage(packId: packId, heroTag: heroTag);
      },
    ),
    GoRoute(
      path: '${RoutePaths.editor}/:packId/:slotIndex/:sourceType',
      builder: (context, state) {
        final packId = int.parse(state.pathParameters['packId']!);
        final slotIndex = int.parse(state.pathParameters['slotIndex']!);
        final sourceType =
            state.pathParameters['sourceType']!; // 'tiktok' o 'local'

        return StickerEditorPage(
          packId: packId,
          slotIndex: slotIndex,
          sourceType: sourceType,
        );
      },
    ),
    GoRoute(
      path: RoutePaths.picker,
      builder: (context, state) => const VideoPickerPage(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Página no encontrada: ${state.uri}'))),
);
