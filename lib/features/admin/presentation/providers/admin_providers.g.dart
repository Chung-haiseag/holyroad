// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminStatsHash() => r'eb63aaf9b04273384ec51d5c5294ef257ae13c02';

/// See also [adminStats].
@ProviderFor(adminStats)
final adminStatsProvider = AutoDisposeFutureProvider<AdminStatsEntity>.internal(
  adminStats,
  name: r'adminStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminStatsRef = AutoDisposeFutureProviderRef<AdminStatsEntity>;
String _$adminSitesHash() => r'9b0ee9928ed0a45c3fa781eb6ec15bb7f462851b';

/// See also [adminSites].
@ProviderFor(adminSites)
final adminSitesProvider = AutoDisposeFutureProvider<List<HolySite>>.internal(
  adminSites,
  name: r'adminSitesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminSitesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminSitesRef = AutoDisposeFutureProviderRef<List<HolySite>>;
String _$adminUsersHash() => r'1dcab262445ed7e51f0f21c275d053bb8df9bf0d';

/// See also [adminUsers].
@ProviderFor(adminUsers)
final adminUsersProvider = AutoDisposeFutureProvider<List<UserEntity>>.internal(
  adminUsers,
  name: r'adminUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUsersRef = AutoDisposeFutureProviderRef<List<UserEntity>>;
String _$adminModerationsHash() => r'5156b53d04925165f4a12518eec96a49098b5de9';

/// See also [adminModerations].
@ProviderFor(adminModerations)
final adminModerationsProvider =
    AutoDisposeFutureProvider<List<ModerationEntity>>.internal(
      adminModerations,
      name: r'adminModerationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminModerationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminModerationsRef =
    AutoDisposeFutureProviderRef<List<ModerationEntity>>;
String _$adminUserVisitsHash() => r'ff8535bcb9438241fa30c98d5e1b008358ccef1a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [adminUserVisits].
@ProviderFor(adminUserVisits)
const adminUserVisitsProvider = AdminUserVisitsFamily();

/// See also [adminUserVisits].
class AdminUserVisitsFamily extends Family<AsyncValue<List<VisitEntity>>> {
  /// See also [adminUserVisits].
  const AdminUserVisitsFamily();

  /// See also [adminUserVisits].
  AdminUserVisitsProvider call(String userId) {
    return AdminUserVisitsProvider(userId);
  }

  @override
  AdminUserVisitsProvider getProviderOverride(
    covariant AdminUserVisitsProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminUserVisitsProvider';
}

/// See also [adminUserVisits].
class AdminUserVisitsProvider
    extends AutoDisposeFutureProvider<List<VisitEntity>> {
  /// See also [adminUserVisits].
  AdminUserVisitsProvider(String userId)
    : this._internal(
        (ref) => adminUserVisits(ref as AdminUserVisitsRef, userId),
        from: adminUserVisitsProvider,
        name: r'adminUserVisitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminUserVisitsHash,
        dependencies: AdminUserVisitsFamily._dependencies,
        allTransitiveDependencies:
            AdminUserVisitsFamily._allTransitiveDependencies,
        userId: userId,
      );

  AdminUserVisitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<VisitEntity>> Function(AdminUserVisitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminUserVisitsProvider._internal(
        (ref) => create(ref as AdminUserVisitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VisitEntity>> createElement() {
    return _AdminUserVisitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserVisitsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminUserVisitsRef on AutoDisposeFutureProviderRef<List<VisitEntity>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _AdminUserVisitsProviderElement
    extends AutoDisposeFutureProviderElement<List<VisitEntity>>
    with AdminUserVisitsRef {
  _AdminUserVisitsProviderElement(super.provider);

  @override
  String get userId => (origin as AdminUserVisitsProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
