
import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_entity.freezed.dart';
part 'visit_entity.g.dart';

@freezed
class VisitEntity with _$VisitEntity {
  const factory VisitEntity({
    required String id,
    required String userId,
    required String userDisplayName,
    required String userPhotoUrl,
    required String siteId,
    required String siteName,
    required DateTime timestamp,
    @Default('') String prayerMessage,
    @Default('') String photoUrl,
  }) = _VisitEntity;

  factory VisitEntity.fromJson(Map<String, dynamic> json) => _$VisitEntityFromJson(json);
}
