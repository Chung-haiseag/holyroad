import 'package:holyroad/features/daily_quest/domain/entities/daily_mission_entity.dart';

/// 날짜 기반 결정론적 미션 선정 서비스.
/// 서버 없이 날짜만으로 동일한 미션을 제공합니다.
class DailyMissionService {
  static const _missionPool = DailyMissionType.values;

  /// 주어진 날짜의 오늘의 미션을 결정합니다.
  /// 같은 날짜에는 항상 같은 미션을 반환합니다.
  DailyMissionType getMissionForDate(DateTime date) {
    // 날짜를 기반으로 해시 계산 (연+월+일 조합)
    final dayHash = date.year * 10000 + date.month * 100 + date.day;
    // 소수를 곱하여 분산 + 풀 사이즈로 나머지
    final index = (dayHash * 31) % _missionPool.length;
    return _missionPool[index];
  }

  /// 오늘의 미션 객체를 생성합니다.
  DailyMission getTodayMission({
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DailyMission(
      type: getMissionForDate(today),
      date: today,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  /// 연속 미션 완료 일수 (스트릭)를 계산합니다.
  int calculateStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    // 날짜만 추출하여 정렬 (내림차순)
    final dates = completionDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 오늘 또는 어제부터 시작해야 스트릭 인정
    if (dates.first.difference(todayDate).inDays.abs() > 1) return 0;

    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
