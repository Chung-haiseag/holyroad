import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 순례자의기록 화면.
/// 모든 순례자들의 기도문을 모아 보여주는 커뮤니티 피드입니다.
class GuestbookScreen extends ConsumerStatefulWidget {
  const GuestbookScreen({super.key});

  @override
  ConsumerState<GuestbookScreen> createState() => _GuestbookScreenState();
}

class _GuestbookScreenState extends ConsumerState<GuestbookScreen> {
  /// 현재 선택된 성지 필터 (null이면 전체)
  String? _selectedSiteFilter;

  /// 사진 있는 기도문만 표시
  bool _showPhotosOnly = false;

  /// 관리자 여부
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  /// 현재 사용자가 관리자인지 Firestore에서 확인
  Future<void> _checkAdminRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _isAdmin = doc.data()?['role'] == 'admin';
        });
      }
    } catch (_) {
      // 권한 확인 실패 시 관리자 아님으로 처리
    }
  }

  /// 기도문 삭제 확인 다이얼로그
  Future<void> _confirmDelete(BuildContext context, VisitEntity visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기도문 삭제'),
        content: Text(
          '${visit.userDisplayName}님의 기도문을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repo = ref.read(firestoreRepositoryProvider);
        await repo.deleteVisit(visit.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기도문이 삭제되었습니다.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(recentVisitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('순례자의기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 사진 필터 토글
          IconButton(
            icon: Icon(
              _showPhotosOnly ? Icons.photo : Icons.photo_outlined,
              color: _showPhotosOnly
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () {
              setState(() => _showPhotosOnly = !_showPhotosOnly);
            },
            tooltip: _showPhotosOnly ? '전체 보기' : '사진만 보기',
          ),
        ],
      ),
      body: visitsAsync.when(
        data: (visits) {
          // 기도문이 있는 방문만 필터링
          var prayerVisits = visits
              .where((v) => v.prayerMessage.isNotEmpty)
              .toList();

          // 사진 필터
          if (_showPhotosOnly) {
            prayerVisits = prayerVisits
                .where((v) => v.photoUrl.isNotEmpty)
                .toList();
          }

          // 성지 필터
          if (_selectedSiteFilter != null) {
            prayerVisits = prayerVisits
                .where((v) => v.siteName == _selectedSiteFilter)
                .toList();
          }

          // 고유 성지 목록 (필터 칩용)
          final uniqueSites = visits
              .where((v) => v.prayerMessage.isNotEmpty)
              .map((v) => v.siteName)
              .toSet()
              .toList();

          if (prayerVisits.isEmpty && visits.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // 성지 필터 칩
              if (uniqueSites.length > 1)
                _buildFilterChips(context, uniqueSites),

              // 기도문 목록
              Expanded(
                child: prayerVisits.isEmpty
                    ? _buildNoResultState(context)
                    : _buildPrayerList(context, prayerVisits),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(context),
      ),
    );
  }

  /// 성지 필터 칩
  Widget _buildFilterChips(BuildContext context, List<String> siteNames) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 전체 보기
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('전체'),
              selected: _selectedSiteFilter == null,
              onSelected: (selected) {
                setState(() => _selectedSiteFilter = null);
              },
            ),
          ),
          // 성지별 필터
          ...siteNames.map(
            (siteName) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(siteName),
                selected: _selectedSiteFilter == siteName,
                onSelected: (selected) {
                  setState(() {
                    _selectedSiteFilter = selected ? siteName : null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 기도문 리스트
  Widget _buildPrayerList(BuildContext context, List<VisitEntity> visits) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        return _buildPrayerCard(context, visits[index]);
      },
    );
  }

  /// 기도문 카드
  Widget _buildPrayerCard(BuildContext context, VisitEntity visit) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeAgo = timeago.format(visit.timestamp, locale: 'ko');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사진 (있는 경우)
          if (visit.photoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                visit.photoUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 32),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 헤더
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: visit.userPhotoUrl.isNotEmpty
                          ? NetworkImage(visit.userPhotoUrl)
                          : null,
                      child: visit.userPhotoUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.userDisplayName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.church,
                                size: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                visit.siteName,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '·',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeAgo,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 관리자 삭제 메뉴
                    if (_isAdmin)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmDelete(context, visit);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '삭제',
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // 기도문 본문
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    visit.prayerMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 하단 액션 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 함께 기도하기 버튼
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${visit.userDisplayName}님과 함께 기도합니다',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite_border, size: 18),
                      label: const Text('기도 함께하기'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 기도문이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '성지를 방문하고 첫 기도문을 남겨보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/pilgrimage'),
            icon: const Icon(Icons.directions_walk, size: 18),
            label: const Text('순례하러 가기'),
          ),
        ],
      ),
    );
  }

  /// 필터 결과 없음
  Widget _buildNoResultState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            '조건에 맞는 기도문이 없습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSiteFilter = null;
                _showPhotosOnly = false;
              });
            },
            child: const Text('필터 초기화'),
          ),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          const Text('순례자의기록을 불러올 수 없습니다'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ref.invalidate(recentVisitsProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
