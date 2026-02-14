
import 'package:freezed_annotation/freezed_annotation.dart';

part 'holy_site_entity.freezed.dart';
part 'holy_site_entity.g.dart';

/// 성지 유형
enum HolySiteType {
  church,    // 교회
  school,    // 학교
  museum,    // 박물관
  memorial,  // 기념관
  martyrdom, // 순교지
  holySite,  // 성지
}

@freezed
class HolySite with _$HolySite {
  const factory HolySite({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String imageUrl,
    @Default(HolySiteType.holySite) HolySiteType siteType,
    @Default(0.0) double distanceKm, // Calculated distance from user
  }) = _HolySite;

  factory HolySite.fromJson(Map<String, dynamic> json) => _$HolySiteFromJson(json);
}
