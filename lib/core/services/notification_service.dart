import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// 알림 서비스.
/// 로컬 푸시 알림을 생성하고 관리합니다.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 알림 탭 콜백 (payload → route)
  void Function(String? payload)? onNotificationTap;

  /// 알림 이력 (앱 내 표시용)
  final List<NotificationRecord> _history = [];
  List<NotificationRecord> get history => List.unmodifiable(_history);

  /// 초기화
  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Android 13+ 알림 권한 요청
    if (!kIsWeb && Platform.isAndroid) {
      await _requestAndroidPermission();
    }

    _initialized = true;
  }

  /// Android 13+ 알림 권한 요청
  Future<void> _requestAndroidPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// 알림 응답 핸들러
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    onNotificationTap?.call(response.payload);
  }

  /// 성지 근접 알림 표시
  Future<void> showNearbyHolySiteNotification({
    required String siteId,
    required String siteName,
    required double distanceKm,
    String? description,
  }) async {
    if (kIsWeb || !_initialized) return;

    final distanceText = distanceKm < 1
        ? '${(distanceKm * 1000).toInt()}m'
        : '${distanceKm.toStringAsFixed(1)}km';

    final title = '⛪ $siteName 근처입니다!';
    final body = description ?? '$distanceText 거리에 있습니다. 성지 순례를 시작하시겠습니까?';

    const androidDetails = AndroidNotificationDetails(
      'holy_site_nearby',
      '성지 근접 알림',
      channelDescription: '근처에 성지가 있을 때 알림을 보냅니다',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    // 성지 ID를 payload로 전달
    await _plugin.show(
      id: siteId.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: '/pilgrimage?siteId=$siteId',
    );

    // 알림 이력 저장
    _history.insert(
      0,
      NotificationRecord(
        id: siteId.hashCode,
        title: title,
        body: body,
        siteId: siteId,
        siteName: siteName,
        timestamp: DateTime.now(),
      ),
    );

    // 최대 50개까지만 유지
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }
  }

  /// 순례 완료 알림
  Future<void> showPilgrimageCompleteNotification({
    required String siteName,
  }) async {
    if (kIsWeb || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'pilgrimage_complete',
      '순례 완료 알림',
      channelDescription: '순례를 완료했을 때 알림을 보냅니다',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🙏 순례를 완료했습니다!',
      body: '$siteName 순례가 기록되었습니다. 하나님의 은혜가 함께하시기를.',
      notificationDetails: details,
    );
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  /// 알림 이력 삭제
  void clearHistory() {
    _history.clear();
  }
}

/// 알림 이력 기록
class NotificationRecord {
  final int id;
  final String title;
  final String body;
  final String siteId;
  final String siteName;
  final DateTime timestamp;
  bool isRead;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.siteId,
    required this.siteName,
    required this.timestamp,
    this.isRead = false,
  });
}

/// 알림 서비스 프로바이더
@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
NotificationService notificationService(NotificationServiceRef ref) {
  final service = NotificationService();
  service.initialize();
  return service;
}
