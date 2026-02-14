import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/daily_quest/domain/entities/daily_mission_entity.dart';
import 'package:holyroad/features/daily_quest/domain/services/daily_mission_service.dart';
import 'package:holyroad/features/daily_quest/domain/services/mission_completion_service.dart';

/// 미션 서비스 인스턴스
final dailyMissionServiceProvider = Provider<DailyMissionService>((ref) {
  return DailyMissionService();
});

/// 미션 완료 서비스 인스턴스
final missionCompletionServiceProvider =
    Provider<MissionCompletionService>((ref) {
  return MissionCompletionService();
});

/// 오늘의 미션 타입
final todayMissionTypeProvider = Provider<DailyMissionType>((ref) {
  final service = ref.watch(dailyMissionServiceProvider);
  return service.getMissionForDate(DateTime.now());
});

/// 오늘의 미션 완료 여부 (실시간 스트림)
final todayMissionCompletionProvider =
    StreamProvider<DailyMissionCompletion?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  final service = ref.watch(missionCompletionServiceProvider);
  return service.getTodayCompletion(user.uid);
});

/// 오늘의 미션 (완료 상태 포함)
final todayMissionProvider = Provider<DailyMission>((ref) {
  final missionType = ref.watch(todayMissionTypeProvider);
  final completion = ref.watch(todayMissionCompletionProvider).valueOrNull;
  final now = DateTime.now();

  return DailyMission(
    type: missionType,
    date: DateTime(now.year, now.month, now.day),
    isCompleted: completion != null,
    completedAt: completion?.completedAt,
  );
});

/// 미션 연속 달성 일수 (스트릭)
final missionStreakProvider = FutureProvider<int>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0;

  final completionService = ref.watch(missionCompletionServiceProvider);
  final missionService = ref.watch(dailyMissionServiceProvider);

  final dates = await completionService.getRecentCompletionDates(
    userId: user.uid,
  );
  return missionService.calculateStreak(dates);
});
