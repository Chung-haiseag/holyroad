import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/features/admin/domain/repositories/admin_repository.dart';
import 'package:holyroad/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:holyroad/features/admin/domain/entities/moderation_entity.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';

part 'admin_providers.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<AdminStatsEntity> adminStats(AdminStatsRef ref) {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<HolySite>> adminSites(AdminSitesRef ref) {
  return ref.watch(adminRepositoryProvider).getAllSites();
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<UserEntity>> adminUsers(AdminUsersRef ref) {
  return ref.watch(adminRepositoryProvider).getAllUsers();
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<ModerationEntity>> adminModerations(AdminModerationsRef ref) {
  return ref.watch(adminRepositoryProvider).getPendingModerations();
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<VisitEntity>> adminUserVisits(AdminUserVisitsRef ref, String userId) {
  return ref.watch(adminRepositoryProvider).getUserVisits(userId);
}
