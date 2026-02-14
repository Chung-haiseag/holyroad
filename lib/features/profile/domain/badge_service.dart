import 'package:cloud_firestore/cloud_firestore.dart';
import 'badge_entity.dart';
import 'badge_definitions.dart';

/// 배지 획득 감지 및 Firestore 관리 서비스.
class BadgeService {
  final _firestore = FirebaseFirestore.instance;

  /// 현재 활동 데이터와 기존 획득 배지를 비교하여 새로 획득한 배지를 반환합니다.
  List<BadgeDefinition> checkNewBadges(
    BadgeCheckContext context,
    List<String> alreadyEarnedIds,
  ) {
    final newBadges = <BadgeDefinition>[];
    for (final badge in allBadges) {
      if (!alreadyEarnedIds.contains(badge.id) && badge.checkCondition(context)) {
        newBadges.add(badge);
      }
    }
    return newBadges;
  }

  /// 사용자의 획득 배지를 Firestore에 저장합니다.
  /// Firestore 경로: `users/{uid}/badges/{badgeId}`
  Future<void> saveBadge(String uid, EarnedBadge badge) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc(badge.badgeId)
        .set(badge.toJson());
  }

  /// 여러 배지를 한 번에 저장합니다.
  Future<void> saveBadges(String uid, List<EarnedBadge> badges) async {
    if (badges.isEmpty) return;
    final batch = _firestore.batch();
    for (final badge in badges) {
      final ref = _firestore
          .collection('users')
          .doc(uid)
          .collection('badges')
          .doc(badge.badgeId);
      batch.set(ref, badge.toJson());
    }
    await batch.commit();
  }

  /// 사용자의 획득 배지 목록을 실시간으로 감시합니다.
  Stream<List<EarnedBadge>> streamEarnedBadges(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EarnedBadge.fromJson(doc.data()))
            .toList());
  }

  /// 사용자의 획득 배지 ID 목록을 한 번 가져옵니다.
  Future<List<String>> getEarnedBadgeIds(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
