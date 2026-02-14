import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/notification_service.dart';
import 'package:holyroad/core/services/recommendation_service.dart';
import 'package:holyroad/core/widgets/cached_holy_image.dart';

class HomeSliverAppBar extends ConsumerWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(notificationServiceProvider);
    final unreadCount = notificationService.history
        .where((n) => !n.isRead)
        .length;
    final recommendedSite = ref.watch(dailyRecommendationProvider);

    final siteName = recommendedSite.valueOrNull?.name ?? 'Holy Road';
    final siteImageUrl = recommendedSite.valueOrNull?.imageUrl;

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Holy Road'),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (siteImageUrl != null)
              CachedHolyImage(
                imageUrl: siteImageUrl,
                fit: BoxFit.cover,
              )
            else
              Container(color: Theme.of(context).colorScheme.primaryContainer),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  final site = recommendedSite.valueOrNull;
                  if (site != null) {
                    context.push('/pilgrimage', extra: site);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 추천 성지',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      siteName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // 알림 버튼 (읽지 않은 알림 배지 표시)
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
