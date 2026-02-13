// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisitEntityImpl _$$VisitEntityImplFromJson(Map<String, dynamic> json) =>
    _$VisitEntityImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String,
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      prayerMessage: json['prayerMessage'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );

Map<String, dynamic> _$$VisitEntityImplToJson(_$VisitEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userDisplayName': instance.userDisplayName,
      'userPhotoUrl': instance.userPhotoUrl,
      'siteId': instance.siteId,
      'siteName': instance.siteName,
      'timestamp': instance.timestamp.toIso8601String(),
      'prayerMessage': instance.prayerMessage,
      'photoUrl': instance.photoUrl,
    };
