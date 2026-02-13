import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/geofence_notification_service.dart';
import 'package:holyroad/features/home/presentation/widgets/geofencing_radar_card.dart';
import 'package:holyroad/features/home/presentation/widgets/home_sliver_app_bar.dart';
import 'package:holyroad/features/home/presentation/widgets/quick_menu_grid.dart';
import 'package:holyroad/features/home/presentation/widgets/real_time_feed_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 지오펜스 알림 서비스 자동 초기화 (홈 화면 진입 시 시작)
    ref.watch(geofenceNotificationServiceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const HomeSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내 주변 성지',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const GeofencingRadarCard(),
                  const SizedBox(height: 20),
                  const QuickMenuGrid(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '실시간 순례 피드',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(onPressed: () {}, child: const Text('더보기')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const RealTimeFeedList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/pilgrimage');
        },
        child: const Icon(Icons.directions_walk),
      ),
    );
  }
}
