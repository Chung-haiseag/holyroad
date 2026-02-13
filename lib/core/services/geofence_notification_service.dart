import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/core/services/location_service.dart';
import 'package:holyroad/core/services/notification_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

part 'geofence_notification_service.g.dart';

/// 지오펜스 알림 서비스.
/// 위치 서비스에서 근접 성지를 감시하고,
/// 일정 거리 이내에 진입하면 로컬 알림을 발송합니다.
class GeofenceNotificationService {
  final LocationService _locationService;
  final NotificationService _notificationService;

  StreamSubscription<List<HolySite>>? _subscription;

  /// 알림을 보낸 성지 ID 기록 (중복 방지)
  final Set<String> _notifiedSiteIds = {};

  /// 알림 트리거 거리 (기본 1km)
  static const double _notifyRadiusKm = 1.0;

  /// 알림 초기화 거리 (이 거리를 넘어가면 다시 알림 가능)
  static const double _resetRadiusKm = 3.0;

  /// 감시 반경 (성지 목록 조회용)
  static const double _watchRadiusKm = 5.0;

  bool _isWatching = false;

  GeofenceNotificationService({
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _locationService = locationService,
        _notificationService = notificationService;

  /// 감시 여부
  bool get isWatching => _isWatching;

  /// 감시 시작
  void startWatching() {
    if (_isWatching || kIsWeb) return;

    _isWatching = true;
    debugPrint('[Geofence] 성지 근접 감시를 시작합니다.');

    _subscription = _locationService
        .getNearbySites(_watchRadiusKm)
        .listen(
      (sites) {
        _checkGeofences(sites);
      },
      onError: (error) {
        debugPrint('[Geofence] 위치 감시 오류: $error');
      },
    );
  }

  /// 감시 중지
  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    _isWatching = false;
    debugPrint('[Geofence] 성지 근접 감시를 중지합니다.');
  }

  /// 알림 기록 초기화 (모든 성지에 대해 다시 알림 가능)
  void resetNotifications() {
    _notifiedSiteIds.clear();
  }

  /// 근접 성지 체크 및 알림 발송
  void _checkGeofences(List<HolySite> nearbySites) {
    for (final site in nearbySites) {
      // 알림 트리거 거리 이내이고, 아직 알림을 보내지 않은 경우
      if (site.distanceKm <= _notifyRadiusKm &&
          !_notifiedSiteIds.contains(site.id)) {
        _notifiedSiteIds.add(site.id);
        _sendNotification(site);
        debugPrint('[Geofence] 성지 "${site.name}" 근접 알림 발송 (${site.distanceKm.toStringAsFixed(2)}km)');
      }

      // 초기화 거리를 넘어가면 다시 알림 가능하도록
      if (site.distanceKm > _resetRadiusKm &&
          _notifiedSiteIds.contains(site.id)) {
        _notifiedSiteIds.remove(site.id);
        debugPrint('[Geofence] 성지 "${site.name}" 알림 초기화 (${site.distanceKm.toStringAsFixed(2)}km)');
      }
    }

    // 감시 범위 밖으로 나간 성지도 초기화
    final nearbySiteIds = nearbySites.map((s) => s.id).toSet();
    _notifiedSiteIds.removeWhere((id) => !nearbySiteIds.contains(id));
  }

  /// 알림 발송
  void _sendNotification(HolySite site) {
    _notificationService.showNearbyHolySiteNotification(
      siteId: site.id,
      siteName: site.name,
      distanceKm: site.distanceKm,
      description: '${site.description} 순례를 시작해 보세요!',
    );
  }

  /// 리소스 해제
  void dispose() {
    stopWatching();
  }
}

/// 지오펜스 알림 서비스 프로바이더.
/// 위치 서비스와 알림 서비스를 연결합니다.
@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
GeofenceNotificationService geofenceNotificationService(
  GeofenceNotificationServiceRef ref,
) {
  final locationService = ref.watch(locationServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  final service = GeofenceNotificationService(
    locationService: locationService,
    notificationService: notificationService,
  );

  // 자동 감시 시작
  service.startWatching();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
