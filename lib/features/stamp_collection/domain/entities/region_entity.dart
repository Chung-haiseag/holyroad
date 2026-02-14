import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 한국 지역 구분
enum KoreanRegion {
  seoul('서울', '🏛', 24),
  gyeonggiIncheon('경기/인천', '🏘', 6),
  chungcheong('충청권', '⛰', 11),
  gyeongsang('경상권', '🌊', 20),
  jeolla('전라권', '🌿', 13),
  gangwon('강원권', '🏔', 13),
  jeju('제주', '🏝', 4),
  bukhan('북한 (역사)', '📜', 5),
  special('기념관·교육기관', '🏫', 16);

  final String displayName;
  final String emoji;
  final int expectedCount;

  const KoreanRegion(this.displayName, this.emoji, this.expectedCount);
}

/// 개별 성지의 스탬프 상태
class SiteStamp {
  final HolySite site;
  final bool isVisited;
  final DateTime? firstVisitDate;

  const SiteStamp({
    required this.site,
    required this.isVisited,
    this.firstVisitDate,
  });
}

/// 지역별 스탬프 데이터
class RegionStampData {
  final KoreanRegion region;
  final List<SiteStamp> stamps;
  final int totalSites;
  final int visitedSites;

  const RegionStampData({
    required this.region,
    required this.stamps,
    required this.totalSites,
    required this.visitedSites,
  });

  bool get isComplete => visitedSites == totalSites && totalSites > 0;
  double get completionRate => totalSites > 0 ? visitedSites / totalSites : 0;
}

/// 전체 스탬프 통계
class StampOverallStats {
  final int totalSites;
  final int visitedSites;
  final int completedRegions;
  final int totalRegions;

  const StampOverallStats({
    required this.totalSites,
    required this.visitedSites,
    required this.completedRegions,
    required this.totalRegions,
  });

  double get completionRate => totalSites > 0 ? visitedSites / totalSites : 0;
}
