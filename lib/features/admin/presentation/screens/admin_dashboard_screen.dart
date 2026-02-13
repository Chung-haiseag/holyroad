import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/admin/presentation/providers/admin_providers.dart';
import 'package:holyroad/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:holyroad/features/admin/presentation/widgets/admin_stats_chart.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        automaticallyImplyLeading: false,
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      AdminStatCard(
                        icon: Icons.people,
                        label: '전체 사용자',
                        value: '${stats.totalUsers}',
                        color: colorScheme.primary,
                      ),
                      AdminStatCard(
                        icon: Icons.place,
                        label: '등록 성지',
                        value: '${stats.totalSites}',
                        color: Colors.teal,
                      ),
                      AdminStatCard(
                        icon: Icons.directions_walk,
                        label: '전체 순례',
                        value: '${stats.totalVisits}',
                        color: Colors.orange,
                      ),
                      AdminStatCard(
                        icon: Icons.pending_actions,
                        label: '대기중 검토',
                        value: '${stats.pendingModerations}',
                        color: colorScheme.error,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Charts
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: PopularSitesChart(sites: stats.popularSites)),
                        const SizedBox(width: 16),
                        Expanded(child: RecentActivityChart(activity: stats.recentActivity)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      PopularSitesChart(sites: stats.popularSites),
                      const SizedBox(height: 16),
                      RecentActivityChart(activity: stats.recentActivity),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
