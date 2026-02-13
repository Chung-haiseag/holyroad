import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:holyroad/features/admin/domain/entities/moderation_entity.dart';
import 'package:holyroad/features/admin/domain/repositories/admin_repository.dart';

class RealAdminRepository implements AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<HolySite>> getAllSites() async {
    final snapshot = await _firestore.collection('holy_sites').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HolySite(
        id: doc.id,
        name: data['name'] as String,
        description: data['description'] as String,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        imageUrl: data['imageUrl'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<void> createSite(HolySite site) async {
    await _firestore.collection('holy_sites').add({
      'name': site.name,
      'description': site.description,
      'latitude': site.latitude,
      'longitude': site.longitude,
      'imageUrl': site.imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateSite(HolySite site) async {
    await _firestore.collection('holy_sites').doc(site.id).update({
      'name': site.name,
      'description': site.description,
      'latitude': site.latitude,
      'longitude': site.longitude,
      'imageUrl': site.imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteSite(String siteId) async {
    await _firestore.collection('holy_sites').doc(siteId).delete();
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserEntity(
        uid: doc.id,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        photoUrl: data['photoUrl'] as String? ?? '',
        level: data['level'] as int? ?? 1,
        role: data['role'] as String? ?? 'user',
      );
    }).toList();
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  @override
  Future<List<VisitEntity>> getUserVisits(String userId) async {
    final snapshot = await _firestore
        .collection('visits')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VisitEntity(
        id: doc.id,
        userId: data['userId'] as String,
        userDisplayName: data['userDisplayName'] as String,
        userPhotoUrl: data['userPhotoUrl'] as String? ?? '',
        siteId: data['siteId'] as String,
        siteName: data['siteName'] as String,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        prayerMessage: data['prayerMessage'] as String? ?? '',
        photoUrl: data['photoUrl'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<List<ModerationEntity>> getPendingModerations() async {
    try {
      final snapshot = await _firestore
          .collection('visits')
          .where('moderationStatus', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ModerationEntity(
          visitId: doc.id,
          userId: data['userId'] as String,
          userDisplayName: data['userDisplayName'] as String,
          siteName: data['siteName'] as String,
          prayerMessage: data['prayerMessage'] as String? ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          photoUrl: data['photoUrl'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      // 인덱스 빌드 중이거나 에러 시 빈 리스트 반환
      return [];
    }
  }

  @override
  Future<void> approveModerationItem(String visitId) async {
    await _firestore.collection('visits').doc(visitId).update({
      'moderationStatus': 'approved',
    });
  }

  @override
  Future<void> rejectModerationItem(String visitId, String note) async {
    await _firestore.collection('visits').doc(visitId).update({
      'moderationStatus': 'rejected',
      'moderatorNote': note,
    });
  }

  @override
  Future<AdminStatsEntity> getDashboardStats() async {
    // Simplified stats - in production, use aggregation queries or Cloud Functions
    final usersSnap = await _firestore.collection('users').count().get();
    final sitesSnap = await _firestore.collection('holy_sites').count().get();
    final visitsSnap = await _firestore.collection('visits').count().get();
    int pendingCount = 0;
    try {
      final pendingSnap = await _firestore
          .collection('visits')
          .where('moderationStatus', isEqualTo: 'pending')
          .count()
          .get();
      pendingCount = pendingSnap.count ?? 0;
    } catch (e) {
      // 인덱스 빌드 중 에러 방어
    }

    return AdminStatsEntity(
      totalUsers: usersSnap.count ?? 0,
      totalSites: sitesSnap.count ?? 0,
      totalVisits: visitsSnap.count ?? 0,
      pendingModerations: pendingCount,
      popularSites: const [],
      recentActivity: const [],
    );
  }
}
