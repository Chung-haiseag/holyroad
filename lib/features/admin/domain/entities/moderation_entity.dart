import 'package:freezed_annotation/freezed_annotation.dart';

part 'moderation_entity.freezed.dart';
part 'moderation_entity.g.dart';

enum ModerationStatus { pending, approved, rejected }

@freezed
class ModerationEntity with _$ModerationEntity {
  const factory ModerationEntity({
    required String visitId,
    required String userId,
    required String userDisplayName,
    required String siteName,
    required String prayerMessage,
    required DateTime timestamp,
    @Default('') String photoUrl,
    @Default(ModerationStatus.pending) ModerationStatus status,
    @Default('') String moderatorNote,
  }) = _ModerationEntity;

  factory ModerationEntity.fromJson(Map<String, dynamic> json) =>
      _$ModerationEntityFromJson(json);
}
