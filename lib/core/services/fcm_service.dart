import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Cloud Messaging 서비스.
/// 푸시 알림 토큰 관리, 토픽 구독, 메시지 핸들링을 담당합니다.
class FCMService {
  static final FCMService _instance = FCMService._();
  factory FCMService() => _instance;
  FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FCM 초기화
  Future<void> initialize() async {
    // 1. 알림 권한 요청
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] 권한 상태: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // 2. FCM 토큰 가져오기
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      await _saveTokenToFirestore(token);

      // 3. 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

      // 4. 기본 토픽 구독
      await subscribeToDefaultTopics();
    }

    // 5. 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. 백그라운드/종료 상태에서 알림 탭 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 7. 앱이 종료 상태에서 알림으로 열린 경우
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// 기본 토픽 구독
  Future<void> subscribeToDefaultTopics() async {
    await _messaging.subscribeToTopic('community_prayers');
    await _messaging.subscribeToTopic('new_sites');
    debugPrint('[FCM] 기본 토픽 구독 완료');
  }

  /// 알림 활성화/비활성화
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await _messaging.subscribeToTopic('community_prayers');
      await _messaging.subscribeToTopic('new_sites');
    } else {
      await _messaging.unsubscribeFromTopic('community_prayers');
      await _messaging.unsubscribeFromTopic('new_sites');
    }
  }

  /// FCM 토큰을 Firestore에 저장
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FCM] 토큰 Firestore 저장 완료');
    } catch (e) {
      debugPrint('[FCM] 토큰 저장 실패 (무시): $e');
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] 포그라운드 메시지: ${message.notification?.title}');
    // 포그라운드에서는 기본적으로 알림이 표시되지 않으므로
    // 필요하면 로컬 알림으로 표시할 수 있음
  }

  /// 알림 탭으로 앱이 열린 경우 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] 알림 탭: ${message.data}');
    // TODO: message.data['route']에 따라 적절한 화면으로 네비게이션
  }
}

/// FCM 백그라운드 메시지 핸들러 (top-level 함수)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] 백그라운드 메시지: ${message.messageId}');
}
