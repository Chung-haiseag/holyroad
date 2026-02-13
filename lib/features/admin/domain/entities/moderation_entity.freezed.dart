// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moderation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ModerationEntity _$ModerationEntityFromJson(Map<String, dynamic> json) {
  return _ModerationEntity.fromJson(json);
}

/// @nodoc
mixin _$ModerationEntity {
  String get visitId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userDisplayName => throw _privateConstructorUsedError;
  String get siteName => throw _privateConstructorUsedError;
  String get prayerMessage => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get photoUrl => throw _privateConstructorUsedError;
  ModerationStatus get status => throw _privateConstructorUsedError;
  String get moderatorNote => throw _privateConstructorUsedError;

  /// Serializes this ModerationEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModerationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModerationEntityCopyWith<ModerationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModerationEntityCopyWith<$Res> {
  factory $ModerationEntityCopyWith(
    ModerationEntity value,
    $Res Function(ModerationEntity) then,
  ) = _$ModerationEntityCopyWithImpl<$Res, ModerationEntity>;
  @useResult
  $Res call({
    String visitId,
    String userId,
    String userDisplayName,
    String siteName,
    String prayerMessage,
    DateTime timestamp,
    String photoUrl,
    ModerationStatus status,
    String moderatorNote,
  });
}

/// @nodoc
class _$ModerationEntityCopyWithImpl<$Res, $Val extends ModerationEntity>
    implements $ModerationEntityCopyWith<$Res> {
  _$ModerationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModerationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitId = null,
    Object? userId = null,
    Object? userDisplayName = null,
    Object? siteName = null,
    Object? prayerMessage = null,
    Object? timestamp = null,
    Object? photoUrl = null,
    Object? status = null,
    Object? moderatorNote = null,
  }) {
    return _then(
      _value.copyWith(
            visitId: null == visitId
                ? _value.visitId
                : visitId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userDisplayName: null == userDisplayName
                ? _value.userDisplayName
                : userDisplayName // ignore: cast_nullable_to_non_nullable
                      as String,
            siteName: null == siteName
                ? _value.siteName
                : siteName // ignore: cast_nullable_to_non_nullable
                      as String,
            prayerMessage: null == prayerMessage
                ? _value.prayerMessage
                : prayerMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            photoUrl: null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ModerationStatus,
            moderatorNote: null == moderatorNote
                ? _value.moderatorNote
                : moderatorNote // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModerationEntityImplCopyWith<$Res>
    implements $ModerationEntityCopyWith<$Res> {
  factory _$$ModerationEntityImplCopyWith(
    _$ModerationEntityImpl value,
    $Res Function(_$ModerationEntityImpl) then,
  ) = __$$ModerationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String visitId,
    String userId,
    String userDisplayName,
    String siteName,
    String prayerMessage,
    DateTime timestamp,
    String photoUrl,
    ModerationStatus status,
    String moderatorNote,
  });
}

/// @nodoc
class __$$ModerationEntityImplCopyWithImpl<$Res>
    extends _$ModerationEntityCopyWithImpl<$Res, _$ModerationEntityImpl>
    implements _$$ModerationEntityImplCopyWith<$Res> {
  __$$ModerationEntityImplCopyWithImpl(
    _$ModerationEntityImpl _value,
    $Res Function(_$ModerationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModerationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitId = null,
    Object? userId = null,
    Object? userDisplayName = null,
    Object? siteName = null,
    Object? prayerMessage = null,
    Object? timestamp = null,
    Object? photoUrl = null,
    Object? status = null,
    Object? moderatorNote = null,
  }) {
    return _then(
      _$ModerationEntityImpl(
        visitId: null == visitId
            ? _value.visitId
            : visitId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userDisplayName: null == userDisplayName
            ? _value.userDisplayName
            : userDisplayName // ignore: cast_nullable_to_non_nullable
                  as String,
        siteName: null == siteName
            ? _value.siteName
            : siteName // ignore: cast_nullable_to_non_nullable
                  as String,
        prayerMessage: null == prayerMessage
            ? _value.prayerMessage
            : prayerMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        photoUrl: null == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ModerationStatus,
        moderatorNote: null == moderatorNote
            ? _value.moderatorNote
            : moderatorNote // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModerationEntityImpl implements _ModerationEntity {
  const _$ModerationEntityImpl({
    required this.visitId,
    required this.userId,
    required this.userDisplayName,
    required this.siteName,
    required this.prayerMessage,
    required this.timestamp,
    this.photoUrl = '',
    this.status = ModerationStatus.pending,
    this.moderatorNote = '',
  });

  factory _$ModerationEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModerationEntityImplFromJson(json);

  @override
  final String visitId;
  @override
  final String userId;
  @override
  final String userDisplayName;
  @override
  final String siteName;
  @override
  final String prayerMessage;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final String photoUrl;
  @override
  @JsonKey()
  final ModerationStatus status;
  @override
  @JsonKey()
  final String moderatorNote;

  @override
  String toString() {
    return 'ModerationEntity(visitId: $visitId, userId: $userId, userDisplayName: $userDisplayName, siteName: $siteName, prayerMessage: $prayerMessage, timestamp: $timestamp, photoUrl: $photoUrl, status: $status, moderatorNote: $moderatorNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModerationEntityImpl &&
            (identical(other.visitId, visitId) || other.visitId == visitId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName) &&
            (identical(other.siteName, siteName) ||
                other.siteName == siteName) &&
            (identical(other.prayerMessage, prayerMessage) ||
                other.prayerMessage == prayerMessage) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.moderatorNote, moderatorNote) ||
                other.moderatorNote == moderatorNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    visitId,
    userId,
    userDisplayName,
    siteName,
    prayerMessage,
    timestamp,
    photoUrl,
    status,
    moderatorNote,
  );

  /// Create a copy of ModerationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModerationEntityImplCopyWith<_$ModerationEntityImpl> get copyWith =>
      __$$ModerationEntityImplCopyWithImpl<_$ModerationEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ModerationEntityImplToJson(this);
  }
}

abstract class _ModerationEntity implements ModerationEntity {
  const factory _ModerationEntity({
    required final String visitId,
    required final String userId,
    required final String userDisplayName,
    required final String siteName,
    required final String prayerMessage,
    required final DateTime timestamp,
    final String photoUrl,
    final ModerationStatus status,
    final String moderatorNote,
  }) = _$ModerationEntityImpl;

  factory _ModerationEntity.fromJson(Map<String, dynamic> json) =
      _$ModerationEntityImpl.fromJson;

  @override
  String get visitId;
  @override
  String get userId;
  @override
  String get userDisplayName;
  @override
  String get siteName;
  @override
  String get prayerMessage;
  @override
  DateTime get timestamp;
  @override
  String get photoUrl;
  @override
  ModerationStatus get status;
  @override
  String get moderatorNote;

  /// Create a copy of ModerationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModerationEntityImplCopyWith<_$ModerationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
