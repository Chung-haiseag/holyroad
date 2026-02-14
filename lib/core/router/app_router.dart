
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
import 'package:holyroad/features/search/presentation/search_screen.dart';
import 'package:holyroad/features/onboarding/presentation/splash_screen.dart';
import 'package:holyroad/features/onboarding/presentation/onboarding_screen.dart';
import 'package:holyroad/features/settings/presentation/settings_screen.dart';
import 'package:holyroad/features/profile/presentation/persona_edit_screen.dart';
import 'package:holyroad/features/stamp_collection/presentation/stamp_collection_screen.dart';
import 'package:holyroad/features/verse_gacha/presentation/verse_gacha_screen.dart';
import 'package:holyroad/features/verse_gacha/presentation/verse_collection_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
GoRouter appRouter(AppRouterRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: kIsWeb ? '/admin' : '/splash',
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
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/persona-edit',
        builder: (context, state) => const PersonaEditScreen(),
      ),
      GoRoute(
        path: '/stamp-collection',
        builder: (context, state) => const StampCollectionScreen(),
      ),
      GoRoute(
        path: '/verse-gacha',
        builder: (context, state) => const VerseGachaScreen(),
      ),
      GoRoute(
        path: '/verse-collection',
        builder: (context, state) => const VerseCollectionScreen(),
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

