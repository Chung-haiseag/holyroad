import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/core/services/real_location_service.dart';

part 'location_service.g.dart';

abstract class LocationService {
  Stream<List<HolySite>> getNearbySites(double radiusKm);
  Stream<bool> get isPilgrimageMode;
}

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
LocationService locationService(LocationServiceRef ref) {
  // 웹에서는 GPS 사용 불가 → Mock 사용
  if (kIsWeb) return MockLocationService();

  // 모바일/데스크톱에서는 실제 GPS 사용
  // 권한 처리는 RealLocationService 내부에서 수행
  return RealLocationService();
}

/// 개발/테스트/웹용 Mock 위치 서비스.
/// 하드코딩된 성지 데이터를 반환합니다.
class MockLocationService implements LocationService {
  @override
  Stream<List<HolySite>> getNearbySites(double radiusKm) {
    return Stream.value([
      const HolySite(
        id: '1',
        name: '서소문 순교 성지',
        description: '한국 천주교 최대의 순교 성지.',
        latitude: 37.563,
        longitude: 126.97,
        imageUrl: 'https://picsum.photos/seed/seosomun/400/200',
        distanceKm: 0.8,
      ),
      const HolySite(
        id: '2',
        name: '서울 명동 성당',
        description: '한국 천주교 공동체가 처음으로 탄생한 곳이자 한국 천주교의 상징.',
        latitude: 37.563,
        longitude: 126.98,
        imageUrl: 'https://picsum.photos/seed/myeongdong/400/200',
        distanceKm: 1.2,
      ),
      const HolySite(
        id: '3',
        name: '양화진 외국인 선교사 묘원',
        description: '조선을 사랑했던 외국인 선교사들이 잠들어 있는 곳.',
        latitude: 37.545,
        longitude: 126.91,
        imageUrl: 'https://picsum.photos/seed/yanghwajin/400/200',
        distanceKm: 4.5,
      ),
    ]);
  }

  @override
  Stream<bool> get isPilgrimageMode => Stream.value(false);
}
