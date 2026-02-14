import 'package:flutter/material.dart';
import 'badge_entity.dart';

/// 앱에서 제공하는 전체 배지 목록.
/// 인증샷(사진) 배지를 최우선으로, 순례·연속·기도 순으로 정렬.
final List<BadgeDefinition> allBadges = [
  // ── 📸 인증샷 배지 ──
  BadgeDefinition(
    id: 'first_photo',
    name: '첫 인증샷',
    description: '처음으로 순례 인증샷을 올렸습니다',
    icon: Icons.camera_alt,
    color: const Color(0xFFFF9800), // orange
    category: 'photo',
    requirement: 1,
    checkCondition: (ctx) => ctx.totalPhotos >= 1,
  ),
  BadgeDefinition(
    id: 'photo_5',
    name: '사진작가',
    description: '인증샷을 5장 이상 올렸습니다',
    icon: Icons.photo_library,
    color: const Color(0xFF4CAF50), // green
    category: 'photo',
    requirement: 5,
    checkCondition: (ctx) => ctx.totalPhotos >= 5,
  ),
  BadgeDefinition(
    id: 'photo_10',
    name: '순례 기록가',
    description: '인증샷을 10장 이상 올렸습니다',
    icon: Icons.collections,
    color: const Color(0xFF2196F3), // blue
    category: 'photo',
    requirement: 10,
    checkCondition: (ctx) => ctx.totalPhotos >= 10,
  ),
  BadgeDefinition(
    id: 'photo_30',
    name: '추억 수집가',
    description: '인증샷을 30장 이상 올렸습니다',
    icon: Icons.emoji_events,
    color: const Color(0xFFFFD700), // gold
    category: 'photo',
    requirement: 30,
    checkCondition: (ctx) => ctx.totalPhotos >= 30,
  ),

  // ── 🚶 순례 방문 배지 ──
  BadgeDefinition(
    id: 'first_visit',
    name: '첫 발걸음',
    description: '첫 번째 성지를 순례했습니다',
    icon: Icons.directions_walk,
    color: const Color(0xFF795548), // brown
    category: 'visit',
    requirement: 1,
    checkCondition: (ctx) => ctx.totalVisits >= 1,
  ),
  BadgeDefinition(
    id: 'sites_5',
    name: '순례 탐험가',
    description: '5곳의 성지를 방문했습니다',
    icon: Icons.explore,
    color: const Color(0xFF009688), // teal
    category: 'visit',
    requirement: 5,
    checkCondition: (ctx) => ctx.uniqueSites >= 5,
  ),
  BadgeDefinition(
    id: 'sites_10',
    name: '성지 순례자',
    description: '10곳의 성지를 방문했습니다',
    icon: Icons.church,
    color: const Color(0xFF673AB7), // deep purple
    category: 'visit',
    requirement: 10,
    checkCondition: (ctx) => ctx.uniqueSites >= 10,
  ),
  BadgeDefinition(
    id: 'sites_30',
    name: '전국 순례',
    description: '30곳의 성지를 방문했습니다',
    icon: Icons.public,
    color: const Color(0xFF3F51B5), // indigo
    category: 'visit',
    requirement: 30,
    checkCondition: (ctx) => ctx.uniqueSites >= 30,
  ),

  // ── 🔥 연속 순례 배지 ──
  BadgeDefinition(
    id: 'streak_3',
    name: '3일 연속',
    description: '3일 연속으로 순례했습니다',
    icon: Icons.local_fire_department,
    color: const Color(0xFFF44336), // red
    category: 'streak',
    requirement: 3,
    checkCondition: (ctx) => ctx.streakDays >= 3,
  ),
  BadgeDefinition(
    id: 'streak_7',
    name: '7일 연속',
    description: '7일 연속으로 순례했습니다',
    icon: Icons.star,
    color: const Color(0xFFE91E63), // pink
    category: 'streak',
    requirement: 7,
    checkCondition: (ctx) => ctx.streakDays >= 7,
  ),

  // ── 🙏 기도 배지 ──
  BadgeDefinition(
    id: 'prayer_10',
    name: '기도의 사람',
    description: '기도문을 10개 이상 남겼습니다',
    icon: Icons.volunteer_activism,
    color: const Color(0xFF9C27B0), // purple
    category: 'prayer',
    requirement: 10,
    checkCondition: (ctx) => ctx.totalPrayers >= 10,
  ),
  BadgeDefinition(
    id: 'prayer_30',
    name: '기도 용사',
    description: '기도문을 30개 이상 남겼습니다',
    icon: Icons.auto_awesome,
    color: const Color(0xFFFF5722), // deep orange
    category: 'prayer',
    requirement: 30,
    checkCondition: (ctx) => ctx.totalPrayers >= 30,
  ),

  // ── ⭐ 일일 미션 배지 ──
  BadgeDefinition(
    id: 'mission_streak_7',
    name: '미션 마니아',
    description: '7일 연속 일일 미션을 완료했습니다',
    icon: Icons.task_alt,
    color: const Color(0xFF00ACC1), // cyan 600
    category: 'mission',
    requirement: 7,
    checkCondition: (ctx) => ctx.missionStreak >= 7,
  ),

  // ── 🗺️ 스탬프 컬렉션 배지 ──
  BadgeDefinition(
    id: 'region_3',
    name: '지역 탐험가',
    description: '3개 지역의 성지를 모두 방문했습니다',
    icon: Icons.map,
    color: const Color(0xFF00BCD4), // cyan
    category: 'stamp',
    requirement: 3,
    checkCondition: (ctx) => ctx.completedRegions >= 3,
  ),
  BadgeDefinition(
    id: 'region_5',
    name: '지역 마스터',
    description: '5개 지역의 성지를 모두 방문했습니다',
    icon: Icons.workspace_premium,
    color: const Color(0xFFFFC107), // amber
    category: 'stamp',
    requirement: 5,
    checkCondition: (ctx) => ctx.completedRegions >= 5,
  ),
  BadgeDefinition(
    id: 'national_master',
    name: '전국 마스터',
    description: '모든 지역의 성지를 완주했습니다',
    icon: Icons.military_tech,
    color: const Color(0xFFFFD700), // gold
    category: 'stamp',
    requirement: 9,
    checkCondition: (ctx) => ctx.isNationalMaster,
  ),
];

/// ID로 배지 정의 찾기.
BadgeDefinition? findBadgeById(String id) {
  try {
    return allBadges.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
}
