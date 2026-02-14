/// 일일 미션 타입
enum DailyMissionType {
  visitSite('새로운 성지 방문하기', '🚶', '아직 방문하지 않은 성지를 방문해보세요'),
  takePhoto('성지 인증샷 촬영하기', '📸', '순례한 성지에서 인증샷을 남겨보세요'),
  writePrayer('기도문 남기기', '🙏', '성지에서 기도문을 작성해보세요'),
  readBible('오늘의 성경 읽기', '📖', '성경을 읽고 말씀을 묵상해보세요'),
  meditate('10분 묵상하기', '🧘', '조용히 10분간 말씀을 묵상해보세요'),
  shareStory('순례 나눔 글쓰기', '✍️', '순례 경험을 나눔방에 공유해보세요'),
  aiCounseling('AI 상담으로 말씀 묵상하기', '💬', 'AI 상담에서 말씀을 함께 묵상해보세요'),
  thanksPrayer('감사 기도문 작성하기', '💝', '오늘 감사한 것을 기도문에 담아보세요'),
  takePhotos3('성지 사진 3장 촬영하기', '📷', '같은 성지에서 3장의 사진을 남겨보세요'),
  visitNearby('가까운 성지 방문하기', '📍', '현재 위치에서 가장 가까운 성지를 방문해보세요'),
  praisePrayer('찬양 제목으로 기도하기', '🎵', '좋아하는 찬양의 가사로 기도해보세요'),
  writeReview('순례 후기 작성하기', '📝', '방문한 성지에 대한 후기를 남겨보세요');

  final String title;
  final String emoji;
  final String description;

  const DailyMissionType(this.title, this.emoji, this.description);

  /// 자동 완료 감지 가능 여부
  bool get isAutoDetectable {
    switch (this) {
      case DailyMissionType.visitSite:
      case DailyMissionType.takePhoto:
      case DailyMissionType.writePrayer:
      case DailyMissionType.shareStory:
      case DailyMissionType.takePhotos3:
      case DailyMissionType.visitNearby:
      case DailyMissionType.thanksPrayer:
      case DailyMissionType.writeReview:
        return true;
      case DailyMissionType.readBible:
      case DailyMissionType.meditate:
      case DailyMissionType.aiCounseling:
      case DailyMissionType.praisePrayer:
        return false;
    }
  }
}

/// 오늘의 미션 정보
class DailyMission {
  final DailyMissionType type;
  final DateTime date;
  final bool isCompleted;
  final DateTime? completedAt;

  const DailyMission({
    required this.type,
    required this.date,
    this.isCompleted = false,
    this.completedAt,
  });

  DailyMission copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return DailyMission(
      type: type,
      date: date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// 미션 완료 기록 (Firestore 저장용)
class DailyMissionCompletion {
  final String type;
  final DateTime completedAt;
  final String evidence;

  const DailyMissionCompletion({
    required this.type,
    required this.completedAt,
    this.evidence = '',
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'completedAt': completedAt.toIso8601String(),
        'evidence': evidence,
      };

  factory DailyMissionCompletion.fromJson(Map<String, dynamic> json) {
    return DailyMissionCompletion(
      type: json['type'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      evidence: json['evidence'] as String? ?? '',
    );
  }
}
