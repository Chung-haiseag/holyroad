import 'package:flutter/material.dart';
import 'package:holyroad/features/admin/domain/entities/admin_stats_entity.dart';

class PopularSitesChart extends StatelessWidget {
  final List<SiteVisitCount> sites;
  const PopularSitesChart({super.key, required this.sites});

  @override
  Widget build(BuildContext context) {
    if (sites.isEmpty) return const SizedBox.shrink();
    final maxCount = sites.map((s) => s.visitCount).reduce((a, b) => a > b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('인기 성지 TOP 5', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...sites.map((site) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(site.siteName, style: Theme.of(context).textTheme.bodyMedium),
                      Text('${site.visitCount}회', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: site.visitCount / maxCount,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class RecentActivityChart extends StatelessWidget {
  final List<DailyVisitCount> activity;
  const RecentActivityChart({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) return const SizedBox.shrink();
    final maxCount = activity.map((a) => a.count).reduce((a, b) => a > b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;
    final dayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('최근 7일 활동', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: activity.map((day) {
                  final ratio = maxCount > 0 ? day.count / maxCount : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${day.count}', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: ratio.clamp(0.05, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(dayNames[day.date.weekday % 7], style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
