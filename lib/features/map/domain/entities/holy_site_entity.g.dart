// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holy_site_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HolySiteImpl _$$HolySiteImplFromJson(Map<String, dynamic> json) =>
    _$HolySiteImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      siteType:
          $enumDecodeNullable(_$HolySiteTypeEnumMap, json['siteType']) ??
          HolySiteType.holySite,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$HolySiteImplToJson(_$HolySiteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'imageUrl': instance.imageUrl,
      'siteType': _$HolySiteTypeEnumMap[instance.siteType]!,
      'distanceKm': instance.distanceKm,
    };

const _$HolySiteTypeEnumMap = {
  HolySiteType.church: 'church',
  HolySiteType.school: 'school',
  HolySiteType.museum: 'museum',
  HolySiteType.memorial: 'memorial',
  HolySiteType.martyrdom: 'martyrdom',
  HolySiteType.holySite: 'holySite',
};
