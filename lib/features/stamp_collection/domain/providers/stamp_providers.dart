import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/core/providers/sites_provider.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';
import 'package:holyroad/features/stamp_collection/domain/entities/region_entity.dart';
import 'package:holyroad/features/stamp_collection/domain/services/stamp_collection_service.dart';

/// 스탬프 컬렉션 서비스 인스턴스
final stampCollectionServiceProvider = Provider<StampCollectionService>((ref) {
  return StampCollectionService();
});

/// 지역별 스탬프 데이터 (실시간 스트림)
final stampCollectionProvider =
    StreamProvider<List<RegionStampData>>((ref) async* {
  // 전체 성지 목록 로드
  final sitesAsync = ref.watch(allSitesProvider);
  final allSites = sitesAsync.valueOrNull;
  if (allSites == null || allSites.isEmpty) {
    yield [];
    return;
  }

  // 현재 사용자 확인
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield [];
    return;
  }

  // 사용자 방문 기록 스트림
  final repo = ref.watch(firestoreRepositoryProvider);
  final service = ref.watch(stampCollectionServiceProvider);

  yield* repo.getUserVisits(user.uid).map((visits) {
    return service.buildRegionStamps(
      allSites: allSites,
      userVisits: visits,
    );
  });
});

/// 전체 스탬프 통계
final stampOverallStatsProvider = Provider<StampOverallStats>((ref) {
  final regionData = ref.watch(stampCollectionProvider).valueOrNull ?? [];
  final service = ref.watch(stampCollectionServiceProvider);
  return service.buildOverallStats(regionData);
});

/// 완료된 지역 집합 (배지 체크용)
final completedRegionsProvider = Provider<Set<String>>((ref) {
  final regionData = ref.watch(stampCollectionProvider).valueOrNull ?? [];
  final service = ref.watch(stampCollectionServiceProvider);
  return service.getCompletedRegionNames(regionData);
});
