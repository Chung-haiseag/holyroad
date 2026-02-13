import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_stats_entity.freezed.dart';
part 'admin_stats_entity.g.dart';

@freezed
class AdminStatsEntity with _$AdminStatsEntity {
  const factory AdminStatsEntity({
    required int totalUsers,
    required int totalSites,
    required int totalVisits,
    required int pendingModerations,
    required List<SiteVisitCount> popularSites,
    required List<DailyVisitCount> recentActivity,
  }) = _AdminStatsEntity;

  factory AdminStatsEntity.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsEntityFromJson(json);
}

@freezed
class SiteVisitCount with _$SiteVisitCount {
  const factory SiteVisitCount({
    required String siteId,
    required String siteName,
    required int visitCount,
  }) = _SiteVisitCount;

  factory SiteVisitCount.fromJson(Map<String, dynamic> json) =>
      _$SiteVisitCountFromJson(json);
}

@freezed
class DailyVisitCount with _$DailyVisitCount {
  const factory DailyVisitCount({
    required DateTime date,
    required int count,
  }) = _DailyVisitCount;

  factory DailyVisitCount.fromJson(Map<String, dynamic> json) =>
      _$DailyVisitCountFromJson(json);
}
