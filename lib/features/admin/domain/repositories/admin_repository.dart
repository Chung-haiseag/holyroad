import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:holyroad/features/admin/domain/entities/moderation_entity.dart';
import 'package:holyroad/features/admin/data/repositories/real_admin_repository.dart';

part 'admin_repository.g.dart';

abstract class AdminRepository {
  // Holy Site CRUD
  Future<List<HolySite>> getAllSites();
  Future<void> createSite(HolySite site);
  Future<void> updateSite(HolySite site);
  Future<void> deleteSite(String siteId);

  // User Management
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateUserRole(String uid, String role);
  Future<List<VisitEntity>> getUserVisits(String userId);

  // Moderation
  Future<List<ModerationEntity>> getPendingModerations();
  Future<void> approveModerationItem(String visitId);
  Future<void> rejectModerationItem(String visitId, String note);

  // Statistics
  Future<AdminStatsEntity> getDashboardStats();
}

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
AdminRepository adminRepository(AdminRepositoryRef ref) {
  // return MockAdminRepository();
  return RealAdminRepository();
}

class MockAdminRepository implements AdminRepository {
  final _sites = <HolySite>[
    const HolySite(
      id: '1',
      name: '서소문 순교 성지',
      description: '한국 천주교 최대의 순교 성지. 44명의 성인과 수많은 순교자가 이곳에서 신앙을 증거하였습니다.',
      latitude: 37.5630,
      longitude: 126.9700,
      imageUrl: 'https://picsum.photos/seed/seosomun/400/200',
    ),
    const HolySite(
      id: '2',
      name: '서울 명동 성당',
      description: '한국 천주교 공동체가 처음으로 탄생한 곳이자 한국 천주교의 상징.',
      latitude: 37.5633,
      longitude: 126.9870,
      imageUrl: 'https://picsum.photos/seed/myeongdong/400/200',
    ),
    const HolySite(
      id: '3',
      name: '양화진 외국인 선교사 묘원',
      description: '조선을 사랑했던 외국인 선교사들이 잠들어 있는 곳.',
      latitude: 37.5450,
      longitude: 126.9100,
      imageUrl: 'https://picsum.photos/seed/yanghwajin/400/200',
    ),
    const HolySite(
      id: '4',
      name: '절두산 순교 성지',
      description: '병인박해 때 수많은 천주교 신자들이 순교한 장소.',
      latitude: 37.5470,
      longitude: 126.9080,
      imageUrl: 'https://picsum.photos/seed/jeoldusan/400/200',
    ),
    const HolySite(
      id: '5',
      name: '해미 순교 성지',
      description: '충남 서산시에 위치한 천주교 순교 성지. 1천여 명의 교우가 순교.',
      latitude: 36.7140,
      longitude: 126.5690,
      imageUrl: 'https://picsum.photos/seed/haemi/400/200',
    ),
    const HolySite(
      id: '6',
      name: '전주 전동 성당',
      description: '호남 지역 최초의 서양식 건물이자 로마네스크 양식의 아름다운 성당.',
      latitude: 35.8126,
      longitude: 127.1530,
      imageUrl: 'https://picsum.photos/seed/jeonju/400/200',
    ),
  ];

  final _users = <UserEntity>[
    const UserEntity(uid: 'admin1', email: 'admin@holyroad.com', displayName: '관리자', level: 10, role: 'admin'),
    const UserEntity(uid: 'u1', email: 'maria.kim@example.com', displayName: '김마리아', photoUrl: 'https://picsum.photos/seed/u1/100', level: 5, role: 'user'),
    const UserEntity(uid: 'u2', email: 'john.lee@example.com', displayName: '이요한', photoUrl: 'https://picsum.photos/seed/u2/100', level: 3, role: 'user'),
    const UserEntity(uid: 'u3', email: 'peter.park@example.com', displayName: '박베드로', photoUrl: 'https://picsum.photos/seed/u3/100', level: 7, role: 'user'),
    const UserEntity(uid: 'u4', email: 'theresa.choi@example.com', displayName: '최데레사', photoUrl: 'https://picsum.photos/seed/u4/100', level: 2, role: 'user'),
    const UserEntity(uid: 'u5', email: 'anna.jung@example.com', displayName: '정안나', photoUrl: 'https://picsum.photos/seed/u5/100', level: 4, role: 'user'),
  ];

  late final List<VisitEntity> _visits = [
    VisitEntity(id: 'v1', userId: 'u1', userDisplayName: '김마리아', userPhotoUrl: '', siteId: '2', siteName: '명동성당', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), prayerMessage: '주님, 오늘 명동성당에서 드린 기도가 하늘에 닿기를 바랍니다. 평화를 주소서.'),
    VisitEntity(id: 'v2', userId: 'u2', userDisplayName: '이요한', userPhotoUrl: '', siteId: '3', siteName: '양화진', timestamp: DateTime.now().subtract(const Duration(minutes: 30)), prayerMessage: '선교사님들의 숭고한 희생을 묵상합니다.'),
    VisitEntity(id: 'v3', userId: 'u3', userDisplayName: '박베드로', userPhotoUrl: '', siteId: '1', siteName: '서소문 순교 성지', timestamp: DateTime.now().subtract(const Duration(hours: 1)), prayerMessage: '순교자들의 용기에 감사드립니다. 저도 흔들리지 않는 믿음을 갖겠습니다.'),
    VisitEntity(id: 'v4', userId: 'u4', userDisplayName: '최데레사', userPhotoUrl: '', siteId: '4', siteName: '절두산 순교 성지', timestamp: DateTime.now().subtract(const Duration(hours: 2)), prayerMessage: '이곳에서 기도하니 마음이 평화롭습니다.'),
    VisitEntity(id: 'v5', userId: 'u1', userDisplayName: '김마리아', userPhotoUrl: '', siteId: '1', siteName: '서소문 순교 성지', timestamp: DateTime.now().subtract(const Duration(hours: 5)), prayerMessage: '두 번째 방문입니다. 매번 새로운 은혜를 느낍니다.'),
    VisitEntity(id: 'v6', userId: 'u5', userDisplayName: '정안나', userPhotoUrl: '', siteId: '6', siteName: '전주 전동 성당', timestamp: DateTime.now().subtract(const Duration(hours: 8)), prayerMessage: '전주에서의 순례, 잊지 못할 경험이었습니다.'),
    VisitEntity(id: 'v7', userId: 'u2', userDisplayName: '이요한', userPhotoUrl: '', siteId: '5', siteName: '해미 순교 성지', timestamp: DateTime.now().subtract(const Duration(days: 1)), prayerMessage: ''),
    VisitEntity(id: 'v8', userId: 'u3', userDisplayName: '박베드로', userPhotoUrl: '', siteId: '2', siteName: '명동성당', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)), prayerMessage: '가족과 함께한 순례. 감사합니다.'),
  ];

  late final List<ModerationEntity> _moderations = [
    ModerationEntity(visitId: 'v1', userId: 'u1', userDisplayName: '김마리아', siteName: '명동성당', prayerMessage: '주님, 오늘 명동성당에서 드린 기도가 하늘에 닿기를 바랍니다. 평화를 주소서.', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
    ModerationEntity(visitId: 'v3', userId: 'u3', userDisplayName: '박베드로', siteName: '서소문 순교 성지', prayerMessage: '순교자들의 용기에 감사드립니다. 저도 흔들리지 않는 믿음을 갖겠습니다.', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    ModerationEntity(visitId: 'v4', userId: 'u4', userDisplayName: '최데레사', siteName: '절두산 순교 성지', prayerMessage: '이곳에서 기도하니 마음이 평화롭습니다.', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    ModerationEntity(visitId: 'v5', userId: 'u1', userDisplayName: '김마리아', siteName: '서소문 순교 성지', prayerMessage: '두 번째 방문입니다. 매번 새로운 은혜를 느낍니다.', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    ModerationEntity(visitId: 'v6', userId: 'u5', userDisplayName: '정안나', siteName: '전주 전동 성당', prayerMessage: '전주에서의 순례, 잊지 못할 경험이었습니다.', timestamp: DateTime.now().subtract(const Duration(hours: 8))),
  ];

  @override
  Future<List<HolySite>> getAllSites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_sites);
  }

  @override
  Future<void> createSite(HolySite site) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sites.add(site);
  }

  @override
  Future<void> updateSite(HolySite site) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sites.indexWhere((s) => s.id == site.id);
    if (index != -1) _sites[index] = site;
  }

  @override
  Future<void> deleteSite(String siteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sites.removeWhere((s) => s.id == siteId);
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_users);
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) _users[index] = _users[index].copyWith(role: role);
  }

  @override
  Future<List<VisitEntity>> getUserVisits(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _visits.where((v) => v.userId == userId).toList();
  }

  @override
  Future<List<ModerationEntity>> getPendingModerations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _moderations.where((m) => m.status == ModerationStatus.pending).toList();
  }

  @override
  Future<void> approveModerationItem(String visitId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _moderations.indexWhere((m) => m.visitId == visitId);
    if (index != -1) {
      _moderations[index] = _moderations[index].copyWith(status: ModerationStatus.approved);
    }
  }

  @override
  Future<void> rejectModerationItem(String visitId, String note) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _moderations.indexWhere((m) => m.visitId == visitId);
    if (index != -1) {
      _moderations[index] = _moderations[index].copyWith(
        status: ModerationStatus.rejected,
        moderatorNote: note,
      );
    }
  }

  @override
  Future<AdminStatsEntity> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AdminStatsEntity(
      totalUsers: _users.length,
      totalSites: _sites.length,
      totalVisits: _visits.length,
      pendingModerations: _moderations.where((m) => m.status == ModerationStatus.pending).length,
      popularSites: const [
        SiteVisitCount(siteId: '2', siteName: '명동성당', visitCount: 128),
        SiteVisitCount(siteId: '1', siteName: '서소문 순교 성지', visitCount: 95),
        SiteVisitCount(siteId: '3', siteName: '양화진', visitCount: 72),
        SiteVisitCount(siteId: '4', siteName: '절두산', visitCount: 58),
        SiteVisitCount(siteId: '6', siteName: '전주 전동 성당', visitCount: 41),
      ],
      recentActivity: [
        DailyVisitCount(date: DateTime.now().subtract(const Duration(days: 6)), count: 12),
        DailyVisitCount(date: DateTime.now().subtract(const Duration(days: 5)), count: 18),
        DailyVisitCount(date: DateTime.now().subtract(const Duration(days: 4)), count: 8),
        DailyVisitCount(date: DateTime.now().subtract(const Duration(days: 3)), count: 24),
        DailyVisitCount(date: DateTime.now().subtract(const Duration(days: 2)), count: 15),
        DailyVisitCount(date: DateTime.now().subtract(const Duration(days: 1)), count: 21),
        DailyVisitCount(date: DateTime.now(), count: 9),
      ],
    );
  }
}
