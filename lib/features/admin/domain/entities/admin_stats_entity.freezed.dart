// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_stats_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminStatsEntity _$AdminStatsEntityFromJson(Map<String, dynamic> json) {
  return _AdminStatsEntity.fromJson(json);
}

/// @nodoc
mixin _$AdminStatsEntity {
  int get totalUsers => throw _privateConstructorUsedError;
  int get totalSites => throw _privateConstructorUsedError;
  int get totalVisits => throw _privateConstructorUsedError;
  int get pendingModerations => throw _privateConstructorUsedError;
  List<SiteVisitCount> get popularSites => throw _privateConstructorUsedError;
  List<DailyVisitCount> get recentActivity =>
      throw _privateConstructorUsedError;

  /// Serializes this AdminStatsEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminStatsEntityCopyWith<AdminStatsEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminStatsEntityCopyWith<$Res> {
  factory $AdminStatsEntityCopyWith(
    AdminStatsEntity value,
    $Res Function(AdminStatsEntity) then,
  ) = _$AdminStatsEntityCopyWithImpl<$Res, AdminStatsEntity>;
  @useResult
  $Res call({
    int totalUsers,
    int totalSites,
    int totalVisits,
    int pendingModerations,
    List<SiteVisitCount> popularSites,
    List<DailyVisitCount> recentActivity,
  });
}

/// @nodoc
class _$AdminStatsEntityCopyWithImpl<$Res, $Val extends AdminStatsEntity>
    implements $AdminStatsEntityCopyWith<$Res> {
  _$AdminStatsEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? totalSites = null,
    Object? totalVisits = null,
    Object? pendingModerations = null,
    Object? popularSites = null,
    Object? recentActivity = null,
  }) {
    return _then(
      _value.copyWith(
            totalUsers: null == totalUsers
                ? _value.totalUsers
                : totalUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSites: null == totalSites
                ? _value.totalSites
                : totalSites // ignore: cast_nullable_to_non_nullable
                      as int,
            totalVisits: null == totalVisits
                ? _value.totalVisits
                : totalVisits // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingModerations: null == pendingModerations
                ? _value.pendingModerations
                : pendingModerations // ignore: cast_nullable_to_non_nullable
                      as int,
            popularSites: null == popularSites
                ? _value.popularSites
                : popularSites // ignore: cast_nullable_to_non_nullable
                      as List<SiteVisitCount>,
            recentActivity: null == recentActivity
                ? _value.recentActivity
                : recentActivity // ignore: cast_nullable_to_non_nullable
                      as List<DailyVisitCount>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminStatsEntityImplCopyWith<$Res>
    implements $AdminStatsEntityCopyWith<$Res> {
  factory _$$AdminStatsEntityImplCopyWith(
    _$AdminStatsEntityImpl value,
    $Res Function(_$AdminStatsEntityImpl) then,
  ) = __$$AdminStatsEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalUsers,
    int totalSites,
    int totalVisits,
    int pendingModerations,
    List<SiteVisitCount> popularSites,
    List<DailyVisitCount> recentActivity,
  });
}

/// @nodoc
class __$$AdminStatsEntityImplCopyWithImpl<$Res>
    extends _$AdminStatsEntityCopyWithImpl<$Res, _$AdminStatsEntityImpl>
    implements _$$AdminStatsEntityImplCopyWith<$Res> {
  __$$AdminStatsEntityImplCopyWithImpl(
    _$AdminStatsEntityImpl _value,
    $Res Function(_$AdminStatsEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? totalSites = null,
    Object? totalVisits = null,
    Object? pendingModerations = null,
    Object? popularSites = null,
    Object? recentActivity = null,
  }) {
    return _then(
      _$AdminStatsEntityImpl(
        totalUsers: null == totalUsers
            ? _value.totalUsers
            : totalUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSites: null == totalSites
            ? _value.totalSites
            : totalSites // ignore: cast_nullable_to_non_nullable
                  as int,
        totalVisits: null == totalVisits
            ? _value.totalVisits
            : totalVisits // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingModerations: null == pendingModerations
            ? _value.pendingModerations
            : pendingModerations // ignore: cast_nullable_to_non_nullable
                  as int,
        popularSites: null == popularSites
            ? _value._popularSites
            : popularSites // ignore: cast_nullable_to_non_nullable
                  as List<SiteVisitCount>,
        recentActivity: null == recentActivity
            ? _value._recentActivity
            : recentActivity // ignore: cast_nullable_to_non_nullable
                  as List<DailyVisitCount>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminStatsEntityImpl implements _AdminStatsEntity {
  const _$AdminStatsEntityImpl({
    required this.totalUsers,
    required this.totalSites,
    required this.totalVisits,
    required this.pendingModerations,
    required final List<SiteVisitCount> popularSites,
    required final List<DailyVisitCount> recentActivity,
  }) : _popularSites = popularSites,
       _recentActivity = recentActivity;

  factory _$AdminStatsEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminStatsEntityImplFromJson(json);

  @override
  final int totalUsers;
  @override
  final int totalSites;
  @override
  final int totalVisits;
  @override
  final int pendingModerations;
  final List<SiteVisitCount> _popularSites;
  @override
  List<SiteVisitCount> get popularSites {
    if (_popularSites is EqualUnmodifiableListView) return _popularSites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularSites);
  }

  final List<DailyVisitCount> _recentActivity;
  @override
  List<DailyVisitCount> get recentActivity {
    if (_recentActivity is EqualUnmodifiableListView) return _recentActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivity);
  }

  @override
  String toString() {
    return 'AdminStatsEntity(totalUsers: $totalUsers, totalSites: $totalSites, totalVisits: $totalVisits, pendingModerations: $pendingModerations, popularSites: $popularSites, recentActivity: $recentActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminStatsEntityImpl &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(other.totalSites, totalSites) ||
                other.totalSites == totalSites) &&
            (identical(other.totalVisits, totalVisits) ||
                other.totalVisits == totalVisits) &&
            (identical(other.pendingModerations, pendingModerations) ||
                other.pendingModerations == pendingModerations) &&
            const DeepCollectionEquality().equals(
              other._popularSites,
              _popularSites,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentActivity,
              _recentActivity,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalUsers,
    totalSites,
    totalVisits,
    pendingModerations,
    const DeepCollectionEquality().hash(_popularSites),
    const DeepCollectionEquality().hash(_recentActivity),
  );

  /// Create a copy of AdminStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminStatsEntityImplCopyWith<_$AdminStatsEntityImpl> get copyWith =>
      __$$AdminStatsEntityImplCopyWithImpl<_$AdminStatsEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminStatsEntityImplToJson(this);
  }
}

abstract class _AdminStatsEntity implements AdminStatsEntity {
  const factory _AdminStatsEntity({
    required final int totalUsers,
    required final int totalSites,
    required final int totalVisits,
    required final int pendingModerations,
    required final List<SiteVisitCount> popularSites,
    required final List<DailyVisitCount> recentActivity,
  }) = _$AdminStatsEntityImpl;

  factory _AdminStatsEntity.fromJson(Map<String, dynamic> json) =
      _$AdminStatsEntityImpl.fromJson;

  @override
  int get totalUsers;
  @override
  int get totalSites;
  @override
  int get totalVisits;
  @override
  int get pendingModerations;
  @override
  List<SiteVisitCount> get popularSites;
  @override
  List<DailyVisitCount> get recentActivity;

  /// Create a copy of AdminStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminStatsEntityImplCopyWith<_$AdminStatsEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SiteVisitCount _$SiteVisitCountFromJson(Map<String, dynamic> json) {
  return _SiteVisitCount.fromJson(json);
}

/// @nodoc
mixin _$SiteVisitCount {
  String get siteId => throw _privateConstructorUsedError;
  String get siteName => throw _privateConstructorUsedError;
  int get visitCount => throw _privateConstructorUsedError;

  /// Serializes this SiteVisitCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SiteVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SiteVisitCountCopyWith<SiteVisitCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SiteVisitCountCopyWith<$Res> {
  factory $SiteVisitCountCopyWith(
    SiteVisitCount value,
    $Res Function(SiteVisitCount) then,
  ) = _$SiteVisitCountCopyWithImpl<$Res, SiteVisitCount>;
  @useResult
  $Res call({String siteId, String siteName, int visitCount});
}

/// @nodoc
class _$SiteVisitCountCopyWithImpl<$Res, $Val extends SiteVisitCount>
    implements $SiteVisitCountCopyWith<$Res> {
  _$SiteVisitCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SiteVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? siteId = null,
    Object? siteName = null,
    Object? visitCount = null,
  }) {
    return _then(
      _value.copyWith(
            siteId: null == siteId
                ? _value.siteId
                : siteId // ignore: cast_nullable_to_non_nullable
                      as String,
            siteName: null == siteName
                ? _value.siteName
                : siteName // ignore: cast_nullable_to_non_nullable
                      as String,
            visitCount: null == visitCount
                ? _value.visitCount
                : visitCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SiteVisitCountImplCopyWith<$Res>
    implements $SiteVisitCountCopyWith<$Res> {
  factory _$$SiteVisitCountImplCopyWith(
    _$SiteVisitCountImpl value,
    $Res Function(_$SiteVisitCountImpl) then,
  ) = __$$SiteVisitCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String siteId, String siteName, int visitCount});
}

/// @nodoc
class __$$SiteVisitCountImplCopyWithImpl<$Res>
    extends _$SiteVisitCountCopyWithImpl<$Res, _$SiteVisitCountImpl>
    implements _$$SiteVisitCountImplCopyWith<$Res> {
  __$$SiteVisitCountImplCopyWithImpl(
    _$SiteVisitCountImpl _value,
    $Res Function(_$SiteVisitCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SiteVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? siteId = null,
    Object? siteName = null,
    Object? visitCount = null,
  }) {
    return _then(
      _$SiteVisitCountImpl(
        siteId: null == siteId
            ? _value.siteId
            : siteId // ignore: cast_nullable_to_non_nullable
                  as String,
        siteName: null == siteName
            ? _value.siteName
            : siteName // ignore: cast_nullable_to_non_nullable
                  as String,
        visitCount: null == visitCount
            ? _value.visitCount
            : visitCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SiteVisitCountImpl implements _SiteVisitCount {
  const _$SiteVisitCountImpl({
    required this.siteId,
    required this.siteName,
    required this.visitCount,
  });

  factory _$SiteVisitCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$SiteVisitCountImplFromJson(json);

  @override
  final String siteId;
  @override
  final String siteName;
  @override
  final int visitCount;

  @override
  String toString() {
    return 'SiteVisitCount(siteId: $siteId, siteName: $siteName, visitCount: $visitCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SiteVisitCountImpl &&
            (identical(other.siteId, siteId) || other.siteId == siteId) &&
            (identical(other.siteName, siteName) ||
                other.siteName == siteName) &&
            (identical(other.visitCount, visitCount) ||
                other.visitCount == visitCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, siteId, siteName, visitCount);

  /// Create a copy of SiteVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SiteVisitCountImplCopyWith<_$SiteVisitCountImpl> get copyWith =>
      __$$SiteVisitCountImplCopyWithImpl<_$SiteVisitCountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SiteVisitCountImplToJson(this);
  }
}

abstract class _SiteVisitCount implements SiteVisitCount {
  const factory _SiteVisitCount({
    required final String siteId,
    required final String siteName,
    required final int visitCount,
  }) = _$SiteVisitCountImpl;

  factory _SiteVisitCount.fromJson(Map<String, dynamic> json) =
      _$SiteVisitCountImpl.fromJson;

  @override
  String get siteId;
  @override
  String get siteName;
  @override
  int get visitCount;

  /// Create a copy of SiteVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SiteVisitCountImplCopyWith<_$SiteVisitCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyVisitCount _$DailyVisitCountFromJson(Map<String, dynamic> json) {
  return _DailyVisitCount.fromJson(json);
}

/// @nodoc
mixin _$DailyVisitCount {
  DateTime get date => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this DailyVisitCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyVisitCountCopyWith<DailyVisitCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyVisitCountCopyWith<$Res> {
  factory $DailyVisitCountCopyWith(
    DailyVisitCount value,
    $Res Function(DailyVisitCount) then,
  ) = _$DailyVisitCountCopyWithImpl<$Res, DailyVisitCount>;
  @useResult
  $Res call({DateTime date, int count});
}

/// @nodoc
class _$DailyVisitCountCopyWithImpl<$Res, $Val extends DailyVisitCount>
    implements $DailyVisitCountCopyWith<$Res> {
  _$DailyVisitCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyVisitCountImplCopyWith<$Res>
    implements $DailyVisitCountCopyWith<$Res> {
  factory _$$DailyVisitCountImplCopyWith(
    _$DailyVisitCountImpl value,
    $Res Function(_$DailyVisitCountImpl) then,
  ) = __$$DailyVisitCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int count});
}

/// @nodoc
class __$$DailyVisitCountImplCopyWithImpl<$Res>
    extends _$DailyVisitCountCopyWithImpl<$Res, _$DailyVisitCountImpl>
    implements _$$DailyVisitCountImplCopyWith<$Res> {
  __$$DailyVisitCountImplCopyWithImpl(
    _$DailyVisitCountImpl _value,
    $Res Function(_$DailyVisitCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? count = null}) {
    return _then(
      _$DailyVisitCountImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyVisitCountImpl implements _DailyVisitCount {
  const _$DailyVisitCountImpl({required this.date, required this.count});

  factory _$DailyVisitCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyVisitCountImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int count;

  @override
  String toString() {
    return 'DailyVisitCount(date: $date, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyVisitCountImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, count);

  /// Create a copy of DailyVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyVisitCountImplCopyWith<_$DailyVisitCountImpl> get copyWith =>
      __$$DailyVisitCountImplCopyWithImpl<_$DailyVisitCountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyVisitCountImplToJson(this);
  }
}

abstract class _DailyVisitCount implements DailyVisitCount {
  const factory _DailyVisitCount({
    required final DateTime date,
    required final int count,
  }) = _$DailyVisitCountImpl;

  factory _DailyVisitCount.fromJson(Map<String, dynamic> json) =
      _$DailyVisitCountImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get count;

  /// Create a copy of DailyVisitCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyVisitCountImplCopyWith<_$DailyVisitCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
