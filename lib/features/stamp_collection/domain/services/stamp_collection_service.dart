import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/stamp_collection/data/region_mapping.dart';
import 'package:holyroad/features/stamp_collection/domain/entities/region_entity.dart';

/// 성지 방문 데이터를 지역별 스탬프 컬렉션으로 변환하는 서비스.
class StampCollectionService {
  /// 전체 성지 목록과 사용자 방문 기록을 교차 대조하여
  /// 지역별 스탬프 데이터를 생성합니다.
  List<RegionStampData> buildRegionStamps({
    required List<HolySite> allSites,
    required List<VisitEntity> userVisits,
  }) {
    // 방문한 siteId 집합 + 최초 방문 날짜 맵
    final visitedSiteIds = <String>{};
    final firstVisitDates = <String, DateTime>{};

    for (final visit in userVisits) {
      visitedSiteIds.add(visit.siteId);
      final existing = firstVisitDates[visit.siteId];
      if (existing == null || visit.timestamp.isBefore(existing)) {
        firstVisitDates[visit.siteId] = visit.timestamp;
      }
    }

    // 지역별 그룹핑
    final regionSitesMap = <KoreanRegion, List<SiteStamp>>{};
    for (final region in KoreanRegion.values) {
      regionSitesMap[region] = [];
    }

    for (final site in allSites) {
      final region = siteRegionMap[site.id];
      if (region == null) continue; // 매핑에 없는 사이트는 건너뜀

      final isVisited = visitedSiteIds.contains(site.id);
      regionSitesMap[region]!.add(SiteStamp(
        site: site,
        isVisited: isVisited,
        firstVisitDate: firstVisitDates[site.id],
      ));
    }

    // RegionStampData 리스트 생성
    final result = <RegionStampData>[];
    for (final region in KoreanRegion.values) {
      final stamps = regionSitesMap[region] ?? [];
      // 방문한 스탬프를 먼저, 미방문을 뒤에 (방문한 것 중 최근 방문 먼저)
      stamps.sort((a, b) {
        if (a.isVisited && !b.isVisited) return -1;
        if (!a.isVisited && b.isVisited) return 1;
        if (a.isVisited && b.isVisited) {
          final aDate = a.firstVisitDate ?? DateTime(2000);
          final bDate = b.firstVisitDate ?? DateTime(2000);
          return bDate.compareTo(aDate); // 최근 방문 먼저
        }
        return a.site.name.compareTo(b.site.name); // 미방문은 이름순
      });

      result.add(RegionStampData(
        region: region,
        stamps: stamps,
        totalSites: stamps.length,
        visitedSites: stamps.where((s) => s.isVisited).length,
      ));
    }

    return result;
  }

  /// 전체 통계를 계산합니다.
  StampOverallStats buildOverallStats(List<RegionStampData> regionData) {
    int totalSites = 0;
    int visitedSites = 0;
    int completedRegions = 0;

    for (final data in regionData) {
      totalSites += data.totalSites;
      visitedSites += data.visitedSites;
      if (data.isComplete) completedRegions++;
    }

    return StampOverallStats(
      totalSites: totalSites,
      visitedSites: visitedSites,
      completedRegions: completedRegions,
      totalRegions: KoreanRegion.values.length,
    );
  }

  /// 완료된 지역 이름 집합을 반환합니다 (배지 체크용).
  Set<String> getCompletedRegionNames(List<RegionStampData> regionData) {
    return regionData
        .where((d) => d.isComplete)
        .map((d) => d.region.name)
        .toSet();
  }
}
