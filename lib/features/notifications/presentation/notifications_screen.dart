import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/notification_service.dart';
import 'package:holyroad/core/services/geofence_notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 알림 목록 화면.
/// 수신한 성지 근접 알림 및 순례 알림 이력을 표시합니다.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(notificationServiceProvider);
    final geofenceService = ref.watch(geofenceNotificationServiceProvider);
    final notifications = notificationService.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 지오펜스 감시 토글
          IconButton(
            icon: Icon(
              geofenceService.isWatching
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: geofenceService.isWatching
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () {
              if (geofenceService.isWatching) {
                geofenceService.stopWatching();
              } else {
                geofenceService.startWatching();
              }
              // UI 갱신을 위해 다시 읽기
              ref.invalidate(geofenceNotificationServiceProvider);
            },
            tooltip: geofenceService.isWatching ? '알림 끄기' : '알림 켜기',
          ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                notificationService.clearHistory();
                ref.invalidate(notificationServiceProvider);
              },
              tooltip: '전체 삭제',
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, geofenceService.isWatching)
          : _buildNotificationList(context, ref, notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isWatching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWatching ? Icons.notifications_none : Icons.notifications_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isWatching ? '아직 알림이 없습니다' : '알림이 꺼져 있습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isWatching
                ? '성지 근처에 가면 알림을 받을 수 있습니다'
                : '상단의 알림 버튼을 눌러 켜주세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<NotificationRecord> notifications,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationTile(context, ref, notification);
      },
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    NotificationRecord notification,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeAgo = timeago.format(notification.timestamp, locale: 'ko');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: notification.isRead
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.church,
          color: notification.isRead
              ? colorScheme.onSurfaceVariant
              : colorScheme.primary,
        ),
      ),
      title: Text(
        notification.siteName,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            timeAgo,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () {
        notification.isRead = true;
        // 순례 화면으로 이동
        context.push('/pilgrimage');
      },
    );
  }
}
