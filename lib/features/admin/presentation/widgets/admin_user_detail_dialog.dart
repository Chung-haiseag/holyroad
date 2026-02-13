import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/admin/presentation/providers/admin_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminUserDetailDialog extends ConsumerWidget {
  final UserEntity user;
  const AdminUserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(adminUserVisitsProvider(user.uid));
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('${user.displayName} 상세'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                  child: user.photoUrl.isEmpty ? Text(user.displayName[0], style: TextStyle(color: colorScheme.onPrimaryContainer)) : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(user.email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(label: Text('Lv.${user.level}'), visualDensity: VisualDensity.compact),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(user.role),
                          backgroundColor: user.role == 'admin' ? colorScheme.primaryContainer : null,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Text('순례 이력', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: visitsAsync.when(
                data: (visits) {
                  if (visits.isEmpty) {
                    return const Center(child: Text('순례 이력이 없습니다.'));
                  }
                  return ListView.separated(
                    itemCount: visits.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final visit = visits[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(Icons.place, color: colorScheme.primary, size: 20),
                        title: Text(visit.siteName),
                        subtitle: visit.prayerMessage.isNotEmpty ? Text(visit.prayerMessage, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                        trailing: Text(timeago.format(visit.timestamp, locale: 'ko'), style: Theme.of(context).textTheme.labelSmall),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
      ],
    );
  }
}
