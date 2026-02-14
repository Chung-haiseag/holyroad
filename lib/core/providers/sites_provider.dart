import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/core/services/firestore_seed_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 앱 전역에서 사용하는 전체 성지 목록 Provider.
/// Firestore + 누락된 시드 데이터를 자동 병합합니다.
final allSitesProvider = FutureProvider<List<HolySite>>((ref) async {
  final service = FirestoreSeedService();
  await service.seedIfEmpty();
  final sites = await service.getAllSites();
  if (sites.isNotEmpty) {
    debugPrint('[HolyRoad] 총 ${sites.length}개 성지 로드');
    return sites;
  }
  return FirestoreSeedService.seedSites;
});
