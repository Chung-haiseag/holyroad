import 'package:flutter/material.dart';

/// 배지 획득 조건 체크에 필요한 컨텍스트 데이터.
class BadgeCheckContext {
  final int totalVisits;
  final int totalPhotos;
  final int uniqueSites;
  final int streakDays;
  final int totalPrayers;
  final int completedRegions;
  final bool isNationalMaster;
  final int missionStreak;

  const BadgeCheckContext({
    required this.totalVisits,
    required this.totalPhotos,
    required this.uniqueSites,
    required this.streakDays,
    required this.totalPrayers,
    this.completedRegions = 0,
    this.isNationalMaster = false,
    this.missionStreak = 0,
  });
}

/// 배지 정의 (정적). 앱에 하드코딩된 배지 종류.
class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String category; // 'photo', 'visit', 'streak', 'prayer'
  final int requirement; // 조건 수치 (UI 표시용)
  final bool Function(BadgeCheckContext) checkCondition;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requirement,
    required this.checkCondition,
  });
}

/// 사용자가 획득한 배지 기록 (Firestore 저장용).
class EarnedBadge {
  final String badgeId;
  final DateTime earnedAt;

  const EarnedBadge({
    required this.badgeId,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'badgeId': badgeId,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory EarnedBadge.fromJson(Map<String, dynamic> json) => EarnedBadge(
        badgeId: json['badgeId'] as String,
        earnedAt: DateTime.parse(json['earnedAt'] as String),
      );
}
