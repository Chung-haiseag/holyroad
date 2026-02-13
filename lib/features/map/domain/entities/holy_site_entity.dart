
import 'package:freezed_annotation/freezed_annotation.dart';

part 'holy_site_entity.freezed.dart';
part 'holy_site_entity.g.dart';

@freezed
class HolySite with _$HolySite {
  const factory HolySite({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String imageUrl,
    @Default(0.0) double distanceKm, // Calculated distance from user
  }) = _HolySite;

  factory HolySite.fromJson(Map<String, dynamic> json) => _$HolySiteFromJson(json);
}
