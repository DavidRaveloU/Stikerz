import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stikerz/core/providers/onboarding_provider.dart';
import 'package:stikerz/core/providers/share_provider.dart';
import 'package:stikerz/routes/route_paths.dart';
import 'package:stikerz/ui/components/app_ad_shell.dart';
import 'package:stikerz/ui/features/home/presentation/pages/home_page.dart';
import 'package:stikerz/ui/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:stikerz/ui/features/pack_detail/presentation/pages/pack_detail_page.dart';
import 'package:stikerz/ui/features/settings/presentation/pages/settings_page.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';
import 'package:stikerz/ui/features/video_picker/presentation/pages/video_picker_page.dart';

/// Route observer used to monitor navigation transitions.
final routeObserver = RouteObserver<PageRoute>();

/// Provides the app router and applies onboarding-based redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingNotifierProvider);
  ref.watch(shareFlowResetProvider);

  return GoRouter(
    initialLocation: onboardingCompleted
        ? RoutePaths.home
        : RoutePaths.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Redirect users to onboarding until it is completed.
      if (!onboardingCompleted && state.uri.path != RoutePaths.onboarding) {
        return RoutePaths.onboarding;
      }
      // Prevent navigating back to onboarding once completed.
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
      ShellRoute(
        builder: (context, state, child) => AppAdShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsPage(),
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
              final sourceType = state.pathParameters['sourceType']!;

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
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página no encontrada: ${state.uri}')),
    ),
  );
});

// Legacy static router kept for backward compatibility.
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,

  routes: [
    ShellRoute(
      builder: (context, state, child) => AppAdShell(child: child),
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
            final sourceType = state.pathParameters['sourceType']!;

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
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Página no encontrada: ${state.uri}'))),
);
