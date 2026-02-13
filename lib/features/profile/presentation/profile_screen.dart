import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/auth/domain/repositories/auth_repository.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 사용자 프로필 및 순례 통계 화면.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStream = ref.watch(_authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: authStream.when(
        data: (user) {
          if (user == null) {
            return _buildGuestView(context, ref);
          }
          return _buildProfileView(context, ref, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
      ),
    );
  }

  /// 로그인하지 않은 상태
  Widget _buildGuestView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('로그인이 필요합니다', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '로그인하면 순례 기록과 통계를 확인할 수 있습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login),
            label: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  /// 로그인한 사용자 프로필
  Widget _buildProfileView(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    final userVisitsStream = ref.watch(_userVisitsProvider(user.uid));

    return SingleChildScrollView(
      child: Column(
        children: [
          // 프로필 헤더
          _buildProfileHeader(context, ref, user),
          const SizedBox(height: 16),

          // 통계 카드
          userVisitsStream.when(
            data: (visits) => _buildStatsSection(context, user, visits),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => _buildStatsSection(context, user, []),
          ),

          const SizedBox(height: 24),

          // 최근 순례 기록
          userVisitsStream.when(
            data: (visits) => _buildVisitHistory(context, visits),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 프로필 헤더
  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          // 프로필 사진
          CircleAvatar(
            radius: 48,
            backgroundColor: colorScheme.primary,
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : null,
            child: user.photoUrl.isEmpty
                ? Icon(Icons.person, size: 48, color: colorScheme.onPrimary)
                : null,
          ),
          const SizedBox(height: 12),

          // 이름
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),

          // 이메일
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),

          // 레벨 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16, color: colorScheme.onPrimary),
                const SizedBox(width: 4),
                Text(
                  _getLevelTitle(user.level),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 로그아웃 버튼
          OutlinedButton.icon(
            onPressed: () async {
              final authRepo = ref.read(authRepositoryProvider);
              await authRepo.signOut();
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('로그아웃'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onPrimaryContainer,
              side: BorderSide(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 섹션
  Widget _buildStatsSection(
    BuildContext context,
    UserEntity user,
    List<VisitEntity> visits,
  ) {
    // 통계 계산
    final totalVisits = visits.length;
    final uniqueSites = visits.map((v) => v.siteId).toSet().length;
    final totalPrayers = visits.where((v) => v.prayerMessage.isNotEmpty).length;
    final totalPhotos = visits.where((v) => v.photoUrl.isNotEmpty).length;

    // 이번 달 방문 수
    final now = DateTime.now();
    final thisMonthVisits = visits
        .where(
          (v) => v.timestamp.year == now.year && v.timestamp.month == now.month,
        )
        .length;

    // 연속 순례일 계산
    final streakDays = _calculateStreak(visits);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '순례 통계',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 상단 통계 그리드 (2x2)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.directions_walk,
                  value: '$totalVisits',
                  label: '총 순례',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.church,
                  value: '$uniqueSites',
                  label: '방문 성지',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.calendar_month,
                  value: '$thisMonthVisits',
                  label: '이번 달',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.local_fire_department,
                  value: '$streakDays일',
                  label: '연속 순례',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.edit_note,
                  value: '$totalPrayers',
                  label: '기도문',
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.photo_camera,
                  value: '$totalPhotos',
                  label: '사진',
                  color: Colors.pink,
                ),
              ),
            ],
          ),

          // 레벨 프로그레스
          const SizedBox(height: 20),
          _buildLevelProgress(context, user.level, totalVisits),
        ],
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 레벨 프로그레스 바
  Widget _buildLevelProgress(BuildContext context, int level, int totalVisits) {
    final colorScheme = Theme.of(context).colorScheme;
    final nextLevelVisits = _getNextLevelRequirement(level);
    final currentLevelVisits = _getNextLevelRequirement(level - 1);
    final progress = nextLevelVisits > currentLevelVisits
        ? ((totalVisits - currentLevelVisits) /
                  (nextLevelVisits - currentLevelVisits))
              .clamp(0.0, 1.0)
        : 1.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv.$level ${_getLevelTitle(level)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalVisits / $nextLevelVisits 순례',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '다음 레벨까지 ${(nextLevelVisits - totalVisits).clamp(0, nextLevelVisits)}회 남음',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 최근 순례 기록
  Widget _buildVisitHistory(BuildContext context, List<VisitEntity> visits) {
    if (visits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.hiking,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '아직 순례 기록이 없습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.push('/map'),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('지도'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '순례 기록',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '총 ${visits.length}건',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visits.take(10).map((visit) => _buildVisitTile(context, visit)),
        ],
      ),
    );
  }

  /// 순례 기록 타일
  Widget _buildVisitTile(BuildContext context, VisitEntity visit) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeAgo = timeago.format(visit.timestamp, locale: 'ko');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 성지 아이콘/이미지
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: visit.photoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        visit.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.church, color: colorScheme.primary),
                      ),
                    )
                  : Icon(Icons.church, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.siteName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (visit.prayerMessage.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      visit.prayerMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 기도문/사진 아이콘
            if (visit.prayerMessage.isNotEmpty)
              Icon(
                Icons.edit_note,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            if (visit.photoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.photo,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 레벨별 칭호
  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return '새 신자';
      case 2:
        return '순례자';
      case 3:
        return '열심 신자';
      case 4:
        return '신앙의 벗';
      case 5:
        return '순례 달인';
      case >= 6:
        return '성지 수호자';
      default:
        return '새 신자';
    }
  }

  /// 다음 레벨 필요 방문 수
  int _getNextLevelRequirement(int level) {
    switch (level) {
      case 0:
        return 0;
      case 1:
        return 5;
      case 2:
        return 15;
      case 3:
        return 30;
      case 4:
        return 50;
      case 5:
        return 100;
      default:
        return 100 + (level - 5) * 50;
    }
  }

  /// 연속 순례일 계산
  int _calculateStreak(List<VisitEntity> visits) {
    if (visits.isEmpty) return 0;

    // 날짜별로 그룹핑
    final visitDates =
        visits
            .map(
              (v) => DateTime(
                v.timestamp.year,
                v.timestamp.month,
                v.timestamp.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // 최신순

    if (visitDates.isEmpty) return 0;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // 오늘 또는 어제 방문이 없으면 스트릭 0
    final lastVisitDate = visitDates.first;
    final daysDiff = today.difference(lastVisitDate).inDays;
    if (daysDiff > 1) return 0;

    int streak = 1;
    for (int i = 0; i < visitDates.length - 1; i++) {
      final diff = visitDates[i].difference(visitDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

/// Auth state stream provider
final _authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// 사용자 방문 기록 provider
final _userVisitsProvider = StreamProvider.family<List<VisitEntity>, String>((
  ref,
  userId,
) {
  return ref.watch(firestoreRepositoryProvider).getUserVisits(userId);
});
