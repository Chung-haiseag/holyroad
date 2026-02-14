import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/core/services/location_service.dart';
import 'package:holyroad/core/services/notification_service.dart';
import 'package:holyroad/core/services/settings_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

part 'geofence_notification_service.g.dart';

/// 지오펜스 알림 서비스.
/// 위치 서비스에서 근접 성지를 감시하고,
/// 일정 거리 이내에 진입하면 로컬 알림을 발송합니다.
/// 시간 기반 반복 알림을 지원합니다.
class GeofenceNotificationService {
  final LocationService _locationService;
  final NotificationService _notificationService;

  StreamSubscription<List<HolySite>>? _subscription;

  /// 성지별 마지막 알림 시각 기록 (시간 기반 반복 알림용)
  final Map<String, DateTime> _lastNotifiedTime = {};

  /// 알림 반복 주기 (분 단위, 설정에서 변경 가능)
  int _notificationIntervalMinutes = 60;

  /// 알림 트리거 거리 (설정에서 변경 가능)
  double _notifyRadiusKm = 1.0;

  /// 알림 초기화 거리 (트리거 거리의 3배)
  double get _resetRadiusKm => _notifyRadiusKm * 3.0;

  /// 감시 반경 (성지 목록 조회용, 트리거 거리의 5배)
  double get _watchRadiusKm => _notifyRadiusKm * 5.0;

  bool _isWatching = false;

  GeofenceNotificationService({
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _locationService = locationService,
        _notificationService = notificationService;

  /// 감시 여부
  bool get isWatching => _isWatching;

  /// 현재 알림 반복 주기 (분)
  int get notificationIntervalMinutes => _notificationIntervalMinutes;

  /// 현재 알림 트리거 반경 (km)
  double get notifyRadiusKm => _notifyRadiusKm;

  /// 설정값 업데이트 (Settings에서 호출)
  void updateSettings({
    double? notifyRadiusKm,
    int? intervalMinutes,
  }) {
    if (notifyRadiusKm != null) {
      _notifyRadiusKm = notifyRadiusKm;
      debugPrint('[Geofence] 알림 반경 업데이트: ${_notifyRadiusKm}km');
    }
    if (intervalMinutes != null) {
      _notificationIntervalMinutes = intervalMinutes;
      debugPrint('[Geofence] 알림 반복 주기 업데이트: ${_notificationIntervalMinutes}분');
    }
    // 감시 중이면 새 반경으로 재시작
    if (_isWatching && notifyRadiusKm != null) {
      stopWatching();
      startWatching();
    }
  }

  /// 감시 시작
  void startWatching() {
    if (_isWatching || kIsWeb) return;

    _isWatching = true;
    debugPrint('[Geofence] 성지 근접 감시를 시작합니다. (반경: ${_notifyRadiusKm}km, 반복: ${_notificationIntervalMinutes}분)');

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
    _lastNotifiedTime.clear();
  }

  /// 근접 성지 체크 및 알림 발송 (시간 기반 반복 알림)
  void _checkGeofences(List<HolySite> nearbySites) {
    final now = DateTime.now();
    final intervalDuration = Duration(minutes: _notificationIntervalMinutes);

    for (final site in nearbySites) {
      // 알림 트리거 거리 이내인 경우
      if (site.distanceKm <= _notifyRadiusKm) {
        final lastNotified = _lastNotifiedTime[site.id];

        // 첫 알림이거나, 반복 주기가 지난 경우 → 알림 발송
        if (lastNotified == null ||
            now.difference(lastNotified) >= intervalDuration) {
          _lastNotifiedTime[site.id] = now;
          _sendNotification(site, isRepeat: lastNotified != null);
          debugPrint(
            '[Geofence] 성지 "${site.name}" ${lastNotified != null ? "반복 " : ""}알림 발송 '
            '(${site.distanceKm.toStringAsFixed(2)}km, 다음 알림: ${_notificationIntervalMinutes}분 후)',
          );
        }
      }

      // 초기화 거리를 넘어가면 기록 삭제
      if (site.distanceKm > _resetRadiusKm &&
          _lastNotifiedTime.containsKey(site.id)) {
        _lastNotifiedTime.remove(site.id);
        debugPrint('[Geofence] 성지 "${site.name}" 알림 초기화 (${site.distanceKm.toStringAsFixed(2)}km)');
      }
    }

    // 감시 범위 밖으로 나간 성지도 초기화
    final nearbySiteIds = nearbySites.map((s) => s.id).toSet();
    _lastNotifiedTime.removeWhere((id, _) => !nearbySiteIds.contains(id));
  }

  /// 알림 발송
  void _sendNotification(HolySite site, {bool isRepeat = false}) {
    final prefix = isRepeat ? '📍 아직 근처에 계시네요! ' : '';
    _notificationService.showNearbyHolySiteNotification(
      siteId: site.id,
      siteName: site.name,
      distanceKm: site.distanceKm,
      description: '$prefix${site.description} 순례를 시작해 보세요!',
    );
  }

  /// 리소스 해제
  void dispose() {
    stopWatching();
  }
}

/// 지오펜스 알림 서비스 프로바이더.
/// 위치 서비스와 알림 서비스를 연결하고, 설정값을 반영합니다.
@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
GeofenceNotificationService geofenceNotificationService(
  GeofenceNotificationServiceRef ref,
) {
  final locationService = ref.watch(locationServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final settings = ref.watch(appSettingsProvider);

  final service = GeofenceNotificationService(
    locationService: locationService,
    notificationService: notificationService,
  );

  // 설정값 적용
  service.updateSettings(
    notifyRadiusKm: settings.geofenceRadiusKm,
    intervalMinutes: settings.notificationIntervalMinutes,
  );

  // 알림이 활성화된 경우에만 감시 시작
  if (settings.notificationsEnabled) {
    service.startWatching();
  }

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
