
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/core/router/app_router.dart';
import 'package:holyroad/core/services/fcm_service.dart';
import 'package:holyroad/core/services/settings_service.dart';
import 'package:holyroad/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Ignore if .env is missing for now
  }
  // 네이버 지도 SDK 초기화 (NCP 인증)
  await FlutterNaverMap().init(
    clientId: 'wncoedbyc5',
    onAuthFailed: (ex) {
      debugPrint('[HolyRoad] Naver Map 인증 오류: $ex');
    },
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestore 오프라인 퍼시스턴스 설정
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // FCM은 모바일에서만 초기화 (웹은 서비스워커 필요)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FCMService().initialize();
  }

  runApp(const ProviderScope(child: HolyRoadApp()));
}

class HolyRoadApp extends ConsumerWidget {
  const HolyRoadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: 'Holy Road',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
