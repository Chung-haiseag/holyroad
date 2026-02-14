import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holyroad/features/daily_quest/domain/entities/daily_mission_entity.dart';

/// 미션 완료 감지 및 저장 서비스.
class MissionCompletionService {
  final FirebaseFirestore _firestore;

  MissionCompletionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 오늘의 미션 완료 기록을 조회합니다.
  Stream<DailyMissionCompletion?> getTodayCompletion(String userId) {
    final today = _todayKey();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_missions')
        .doc(today)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return DailyMissionCompletion.fromJson(snap.data()!);
    });
  }

  /// 미션을 완료 처리합니다.
  Future<void> completeMission({
    required String userId,
    required DailyMissionType missionType,
    String evidence = '',
  }) async {
    final today = _todayKey();
    final completion = DailyMissionCompletion(
      type: missionType.name,
      completedAt: DateTime.now(),
      evidence: evidence,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_missions')
        .doc(today)
        .set(completion.toJson());
  }

  /// 셀프 확인 미션을 완료 처리합니다.
  Future<void> selfComplete({
    required String userId,
    required DailyMissionType missionType,
  }) async {
    await completeMission(
      userId: userId,
      missionType: missionType,
      evidence: 'self_confirmed',
    );
  }

  /// 최근 N일간 미션 완료 날짜를 조회합니다 (스트릭 계산용).
  Future<List<DateTime>> getRecentCompletionDates({
    required String userId,
    int days = 30,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startKey =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_missions')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .get();

    return snapshot.docs.map((doc) {
      final parts = doc.id.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
