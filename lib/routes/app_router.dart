import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whaticker/routes/route_paths.dart';
import 'package:whaticker/ui/features/home/presentation/pages/home_page.dart';
import 'package:whaticker/ui/features/pack_detail/presentation/pages/pack_detail_page.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';
import 'package:whaticker/ui/features/video_picker/presentation/pages/video_picker_page.dart';

/// GlobalRouteObserver para detectar cambios de rutas de navegación
final routeObserver = RouteObserver<PageRoute>();

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
