// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminStatsEntityImpl _$$AdminStatsEntityImplFromJson(
  Map<String, dynamic> json,
) => _$AdminStatsEntityImpl(
  totalUsers: (json['totalUsers'] as num).toInt(),
  totalSites: (json['totalSites'] as num).toInt(),
  totalVisits: (json['totalVisits'] as num).toInt(),
  pendingModerations: (json['pendingModerations'] as num).toInt(),
  popularSites: (json['popularSites'] as List<dynamic>)
      .map((e) => SiteVisitCount.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentActivity: (json['recentActivity'] as List<dynamic>)
      .map((e) => DailyVisitCount.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AdminStatsEntityImplToJson(
  _$AdminStatsEntityImpl instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'totalSites': instance.totalSites,
  'totalVisits': instance.totalVisits,
  'pendingModerations': instance.pendingModerations,
  'popularSites': instance.popularSites,
  'recentActivity': instance.recentActivity,
};

_$SiteVisitCountImpl _$$SiteVisitCountImplFromJson(Map<String, dynamic> json) =>
    _$SiteVisitCountImpl(
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String,
      visitCount: (json['visitCount'] as num).toInt(),
    );

Map<String, dynamic> _$$SiteVisitCountImplToJson(
  _$SiteVisitCountImpl instance,
) => <String, dynamic>{
  'siteId': instance.siteId,
  'siteName': instance.siteName,
  'visitCount': instance.visitCount,
};

_$DailyVisitCountImpl _$$DailyVisitCountImplFromJson(
  Map<String, dynamic> json,
) => _$DailyVisitCountImpl(
  date: DateTime.parse(json['date'] as String),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$DailyVisitCountImplToJson(
  _$DailyVisitCountImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'count': instance.count,
};
