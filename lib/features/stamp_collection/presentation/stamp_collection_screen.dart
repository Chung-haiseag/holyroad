import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/stamp_collection/domain/entities/region_entity.dart';
import 'package:holyroad/features/stamp_collection/domain/providers/stamp_providers.dart';
import 'package:holyroad/features/stamp_collection/presentation/widgets/region_card.dart';

/// 순례 스탬프 컬렉션 메인 화면.
/// 전체 진행률 + 지역별 카드 리스트를 표시합니다.
class StampCollectionScreen extends ConsumerStatefulWidget {
  const StampCollectionScreen({super.key});

  @override
  ConsumerState<StampCollectionScreen> createState() =>
      _StampCollectionScreenState();
}

class _StampCollectionScreenState extends ConsumerState<StampCollectionScreen> {
  final Set<KoreanRegion> _expandedRegions = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stampDataAsync = ref.watch(stampCollectionProvider);
    final overallStats = ref.watch(stampOverallStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('순례 스탬프'),
        centerTitle: true,
      ),
      body: stampDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('데이터를 불러올 수 없습니다', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(err.toString(), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        data: (regionDataList) {
          return CustomScrollView(
            slivers: [
              // 전체 통계 헤더
              SliverToBoxAdapter(
                child: _buildOverallHeader(theme, overallStats),
              ),
              // 지역별 카드 리스트
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= regionDataList.length) return null;
                    final data = regionDataList[index];
                    return RegionCard(
                      data: data,
                      isExpanded: _expandedRegions.contains(data.region),
                      onToggle: () {
                        setState(() {
                          if (_expandedRegions.contains(data.region)) {
                            _expandedRegions.remove(data.region);
                          } else {
                            _expandedRegions.add(data.region);
                          }
                        });
                      },
                    );
                  },
                  childCount: regionDataList.length,
                ),
              ),
              // 하단 여백
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallHeader(ThemeData theme, StampOverallStats stats) {
    final percentage = (stats.completionRate * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '나의 순례 여정',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 원형 진행률
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: stats.completionRate,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor:
                      theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '완료',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 통계 수치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                theme,
                '방문 성지',
                '${stats.visitedSites}/${stats.totalSites}',
                Icons.place,
              ),
              Container(
                width: 1,
                height: 30,
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                theme,
                '완료 지역',
                '${stats.completedRegions}/${stats.totalRegions}',
                Icons.map,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
