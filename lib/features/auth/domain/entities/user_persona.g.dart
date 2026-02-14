// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_persona.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPersonaImpl _$$UserPersonaImplFromJson(Map<String, dynamic> json) =>
    _$UserPersonaImpl(
      gender: json['gender'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      churchRole: json['churchRole'] as String? ?? '',
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UserPersonaImplToJson(_$UserPersonaImpl instance) =>
    <String, dynamic>{
      'gender': instance.gender,
      'nickname': instance.nickname,
      'ageGroup': instance.ageGroup,
      'churchRole': instance.churchRole,
      'interests': instance.interests,
    };
