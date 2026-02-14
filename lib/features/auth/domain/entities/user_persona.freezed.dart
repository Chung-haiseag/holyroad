// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_persona.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserPersona _$UserPersonaFromJson(Map<String, dynamic> json) {
  return _UserPersona.fromJson(json);
}

/// @nodoc
mixin _$UserPersona {
  /// 호칭(성별): '형제' (남성) 또는 '자매' (여성)
  String get gender => throw _privateConstructorUsedError;

  /// 별명: 성경 인물이나 자유 입력 (예: '다윗', '에스더', '바울')
  /// AI가 "{별명} {호칭}님" 형태로 호칭합니다.
  String get nickname => throw _privateConstructorUsedError;

  /// 연령대: '10대', '20대', '30대', '40대', '50대', '60대 이상'
  String get ageGroup => throw _privateConstructorUsedError;

  /// 직분: '학생', '청년', '집사', '권사', '장로', '전도사', '목사'
  String get churchRole => throw _privateConstructorUsedError;

  /// 관심사항 (다중 선택): ['역사', '기도', '선교', '찬양', '성경공부', '묵상', '봉사', '성지순례']
  List<String> get interests => throw _privateConstructorUsedError;

  /// Serializes this UserPersona to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPersona
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPersonaCopyWith<UserPersona> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPersonaCopyWith<$Res> {
  factory $UserPersonaCopyWith(
    UserPersona value,
    $Res Function(UserPersona) then,
  ) = _$UserPersonaCopyWithImpl<$Res, UserPersona>;
  @useResult
  $Res call({
    String gender,
    String nickname,
    String ageGroup,
    String churchRole,
    List<String> interests,
  });
}

/// @nodoc
class _$UserPersonaCopyWithImpl<$Res, $Val extends UserPersona>
    implements $UserPersonaCopyWith<$Res> {
  _$UserPersonaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPersona
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gender = null,
    Object? nickname = null,
    Object? ageGroup = null,
    Object? churchRole = null,
    Object? interests = null,
  }) {
    return _then(
      _value.copyWith(
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            ageGroup: null == ageGroup
                ? _value.ageGroup
                : ageGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            churchRole: null == churchRole
                ? _value.churchRole
                : churchRole // ignore: cast_nullable_to_non_nullable
                      as String,
            interests: null == interests
                ? _value.interests
                : interests // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPersonaImplCopyWith<$Res>
    implements $UserPersonaCopyWith<$Res> {
  factory _$$UserPersonaImplCopyWith(
    _$UserPersonaImpl value,
    $Res Function(_$UserPersonaImpl) then,
  ) = __$$UserPersonaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String gender,
    String nickname,
    String ageGroup,
    String churchRole,
    List<String> interests,
  });
}

/// @nodoc
class __$$UserPersonaImplCopyWithImpl<$Res>
    extends _$UserPersonaCopyWithImpl<$Res, _$UserPersonaImpl>
    implements _$$UserPersonaImplCopyWith<$Res> {
  __$$UserPersonaImplCopyWithImpl(
    _$UserPersonaImpl _value,
    $Res Function(_$UserPersonaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPersona
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gender = null,
    Object? nickname = null,
    Object? ageGroup = null,
    Object? churchRole = null,
    Object? interests = null,
  }) {
    return _then(
      _$UserPersonaImpl(
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        ageGroup: null == ageGroup
            ? _value.ageGroup
            : ageGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        churchRole: null == churchRole
            ? _value.churchRole
            : churchRole // ignore: cast_nullable_to_non_nullable
                  as String,
        interests: null == interests
            ? _value._interests
            : interests // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPersonaImpl implements _UserPersona {
  const _$UserPersonaImpl({
    this.gender = '',
    this.nickname = '',
    this.ageGroup = '',
    this.churchRole = '',
    final List<String> interests = const [],
  }) : _interests = interests;

  factory _$UserPersonaImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPersonaImplFromJson(json);

  /// 호칭(성별): '형제' (남성) 또는 '자매' (여성)
  @override
  @JsonKey()
  final String gender;

  /// 별명: 성경 인물이나 자유 입력 (예: '다윗', '에스더', '바울')
  /// AI가 "{별명} {호칭}님" 형태로 호칭합니다.
  @override
  @JsonKey()
  final String nickname;

  /// 연령대: '10대', '20대', '30대', '40대', '50대', '60대 이상'
  @override
  @JsonKey()
  final String ageGroup;

  /// 직분: '학생', '청년', '집사', '권사', '장로', '전도사', '목사'
  @override
  @JsonKey()
  final String churchRole;

  /// 관심사항 (다중 선택): ['역사', '기도', '선교', '찬양', '성경공부', '묵상', '봉사', '성지순례']
  final List<String> _interests;

  /// 관심사항 (다중 선택): ['역사', '기도', '선교', '찬양', '성경공부', '묵상', '봉사', '성지순례']
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  @override
  String toString() {
    return 'UserPersona(gender: $gender, nickname: $nickname, ageGroup: $ageGroup, churchRole: $churchRole, interests: $interests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPersonaImpl &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.ageGroup, ageGroup) ||
                other.ageGroup == ageGroup) &&
            (identical(other.churchRole, churchRole) ||
                other.churchRole == churchRole) &&
            const DeepCollectionEquality().equals(
              other._interests,
              _interests,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gender,
    nickname,
    ageGroup,
    churchRole,
    const DeepCollectionEquality().hash(_interests),
  );

  /// Create a copy of UserPersona
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPersonaImplCopyWith<_$UserPersonaImpl> get copyWith =>
      __$$UserPersonaImplCopyWithImpl<_$UserPersonaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPersonaImplToJson(this);
  }
}

abstract class _UserPersona implements UserPersona {
  const factory _UserPersona({
    final String gender,
    final String nickname,
    final String ageGroup,
    final String churchRole,
    final List<String> interests,
  }) = _$UserPersonaImpl;

  factory _UserPersona.fromJson(Map<String, dynamic> json) =
      _$UserPersonaImpl.fromJson;

  /// 호칭(성별): '형제' (남성) 또는 '자매' (여성)
  @override
  String get gender;

  /// 별명: 성경 인물이나 자유 입력 (예: '다윗', '에스더', '바울')
  /// AI가 "{별명} {호칭}님" 형태로 호칭합니다.
  @override
  String get nickname;

  /// 연령대: '10대', '20대', '30대', '40대', '50대', '60대 이상'
  @override
  String get ageGroup;

  /// 직분: '학생', '청년', '집사', '권사', '장로', '전도사', '목사'
  @override
  String get churchRole;

  /// 관심사항 (다중 선택): ['역사', '기도', '선교', '찬양', '성경공부', '묵상', '봉사', '성지순례']
  @override
  List<String> get interests;

  /// Create a copy of UserPersona
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPersonaImplCopyWith<_$UserPersonaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
