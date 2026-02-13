
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/features/auth/domain/repositories/auth_repository.dart';
import 'package:holyroad/features/auth/presentation/login_screen.dart';
import 'package:holyroad/features/home/presentation/home_screen.dart';
import 'package:holyroad/features/pilgrimage/presentation/pilgrimage_screen.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/map/presentation/map_screen.dart';
import 'package:holyroad/features/admin/presentation/admin_shell_screen.dart';
import 'package:holyroad/features/notifications/presentation/notifications_screen.dart';
import 'package:holyroad/features/profile/presentation/profile_screen.dart';
import 'package:holyroad/features/guestbook/presentation/guestbook_screen.dart';
import 'package:holyroad/features/ai_chat/presentation/ai_chat_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
GoRouter appRouter(AppRouterRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: kIsWeb ? '/admin' : '/', // Force Admin on Web
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      // For now, we allow access to everything even if not logged in (Guest Mode handling)
      // But purely for auth flow:
      // final isLoggedIn = ... check current user from auth repo ...
      // If we want to force login:
      /*
      final isLoggingIn = state.uri.path == '/login';
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      */
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/pilgrimage',
        builder: (context, state) {
          final site = state.extra as HolySite?;
          return PilgrimageScreen(site: site);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/guestbook',
        builder: (context, state) => const GuestbookScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShellScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

