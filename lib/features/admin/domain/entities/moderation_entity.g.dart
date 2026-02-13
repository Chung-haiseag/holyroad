// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModerationEntityImpl _$$ModerationEntityImplFromJson(
  Map<String, dynamic> json,
) => _$ModerationEntityImpl(
  visitId: json['visitId'] as String,
  userId: json['userId'] as String,
  userDisplayName: json['userDisplayName'] as String,
  siteName: json['siteName'] as String,
  prayerMessage: json['prayerMessage'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  photoUrl: json['photoUrl'] as String? ?? '',
  status:
      $enumDecodeNullable(_$ModerationStatusEnumMap, json['status']) ??
      ModerationStatus.pending,
  moderatorNote: json['moderatorNote'] as String? ?? '',
);

Map<String, dynamic> _$$ModerationEntityImplToJson(
  _$ModerationEntityImpl instance,
) => <String, dynamic>{
  'visitId': instance.visitId,
  'userId': instance.userId,
  'userDisplayName': instance.userDisplayName,
  'siteName': instance.siteName,
  'prayerMessage': instance.prayerMessage,
  'timestamp': instance.timestamp.toIso8601String(),
  'photoUrl': instance.photoUrl,
  'status': _$ModerationStatusEnumMap[instance.status]!,
  'moderatorNote': instance.moderatorNote,
};

const _$ModerationStatusEnumMap = {
  ModerationStatus.pending: 'pending',
  ModerationStatus.approved: 'approved',
  ModerationStatus.rejected: 'rejected',
};
