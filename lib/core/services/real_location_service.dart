import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:holyroad/core/services/location_service.dart';
import 'package:holyroad/core/services/location_permission_service.dart';
import 'package:holyroad/core/services/firestore_seed_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 위치 서비스 관련 예외.
/// UI에서 권한 상태에 따라 적절한 복구 액션을 제공할 수 있도록
/// [permissionStatus]를 함께 전달합니다.
class LocationServiceException implements Exception {
  final String message;
  final LocationPermissionStatus? permissionStatus;

  LocationServiceException(this.message, {this.permissionStatus});

  @override
  String toString() => 'LocationServiceException: $message';
}

class RealLocationService implements LocationService {
  final FirestoreSeedService _seedService = FirestoreSeedService();

  /// 하드코딩 폴백 데이터 - Firestore 접근 실패 시 사용
  static const List<HolySite> _fallbackSites = [
    HolySite(
      id: 'seosomun',
      name: '서소문 순교 성지',
      description: '한국 천주교 최대의 순교 성지.',
      latitude: 37.5608,
      longitude: 126.9724,
      imageUrl: 'https://picsum.photos/seed/seosomun/400/200',
    ),
    HolySite(
      id: 'myeongdong',
      name: '서울 명동 성당',
      description: '한국 천주교 공동체가 처음으로 탄생한 곳이자 한국 천주교의 상징.',
      latitude: 37.5633,
      longitude: 126.9872,
      imageUrl: 'https://picsum.photos/seed/myeongdong/400/200',
    ),
    HolySite(
      id: 'yanghwajin',
      name: '양화진 외국인 선교사 묘원',
      description: '조선을 사랑했던 외국인 선교사들이 잠들어 있는 곳.',
      latitude: 37.5448,
      longitude: 126.9102,
      imageUrl: 'https://picsum.photos/seed/yanghwajin/400/200',
    ),
    HolySite(
      id: 'jeoldusan',
      name: '절두산 순교 성지',
      description: '병인박해 때 수많은 천주교 신자들이 순교한 곳.',
      latitude: 37.5433,
      longitude: 126.9080,
      imageUrl: 'https://picsum.photos/seed/jeoldusan/400/200',
    ),
    HolySite(
      id: 'haemi',
      name: '해미 순교 성지',
      description: '천주교 박해 시기 1,000여 명이 순교한 성지.',
      latitude: 36.7141,
      longitude: 126.5512,
      imageUrl: 'https://picsum.photos/seed/haemi/400/200',
    ),
    HolySite(
      id: 'jeonju',
      name: '전주 전동 성당',
      description: '호남 지역 최초의 서양식 건축물이자 천주교 성지.',
      latitude: 35.8138,
      longitude: 127.1531,
      imageUrl: 'https://picsum.photos/seed/jeonju/400/200',
    ),
  ];

  /// Firestore에서 성지 목록 로드 (실패 시 폴백)
  Future<List<HolySite>> _loadSites() async {
    try {
      // 먼저 시드 실행 (비어있으면 자동으로 데이터 삽입)
      await _seedService.seedIfEmpty();
      // Firestore에서 로드
      final sites = await _seedService.getAllSites();
      if (sites.isNotEmpty) return sites;
    } catch (_) {
      // Firestore 실패 시 폴백
    }
    return _fallbackSites;
  }

  @override
  Stream<List<HolySite>> getNearbySites(double radiusKm) async* {
    // 1. 권한 확인 및 요청
    final status = await LocationPermissionService.checkAndRequestPermission();

    if (status != LocationPermissionStatus.granted) {
      throw LocationServiceException(
        _getErrorMessage(status),
        permissionStatus: status,
      );
    }

    // 2. Firestore에서 성지 목록 로드
    final allSites = await _loadSites();

    // 3. 마지막으로 알려진 위치를 먼저 확인 (가장 빠름)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        yield _computeNearbySites(lastKnown, radiusKm, allSites);
      }
    } catch (e) {
      // 무시
    }

    // 4. 현재 위치를 시도 (정확함, 약간 느림)
    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // High -> Medium으로 변경하여 속도 개선
          timeLimit: Duration(seconds: 5), // 10초 -> 5초로 단축
        ),
      );
      yield _computeNearbySites(currentPosition, radiusKm, allSites);
    } catch (e) {
      // 현재 위치 실패 시에도 스트림으로 계속 진행
    }

    // 5. 실시간 위치 업데이트 스트림
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // 100m 이동 시마다 업데이트
    );

    yield* Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (Position position) => _computeNearbySites(position, radiusKm, allSites),
    );
  }

  /// 현재 위치에서 반경 내 성지를 계산합니다.
  List<HolySite> _computeNearbySites(
    Position position,
    double radiusKm,
    List<HolySite> allSites,
  ) {
    final nearby = <HolySite>[];

    for (final site in allSites) {
      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        site.latitude,
        site.longitude,
      );

      final distanceKm = distanceMeters / 1000;

      if (distanceKm <= radiusKm) {
        nearby.add(site.copyWith(distanceKm: distanceKm));
      }
    }

    // 거리순 정렬
    nearby.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return nearby;
  }

  /// 권한 상태에 따른 한국어 에러 메시지
  String _getErrorMessage(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.serviceDisabled:
        return '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 켜주세요.';
      case LocationPermissionStatus.denied:
        return '위치 권한이 거부되었습니다.\n주변 성지를 찾으려면 위치 권한이 필요합니다.';
      case LocationPermissionStatus.deniedForever:
        return '위치 권한이 영구적으로 거부되었습니다.\n앱 설정에서 위치 권한을 허용해주세요.';
      case LocationPermissionStatus.granted:
        return '';
    }
  }

  @override
  Stream<bool> get isPilgrimageMode {
    // 100m 이내에 성지가 있으면 순례 모드 활성화
    return getNearbySites(0.1).map((sites) => sites.isNotEmpty);
  }
}
