import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/admin/domain/repositories/admin_repository.dart';
import 'package:holyroad/features/admin/presentation/providers/admin_providers.dart';
import 'package:holyroad/features/admin/presentation/widgets/admin_visit_moderation_card.dart';

class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moderationsAsync = ref.watch(adminModerationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('기도문 모더레이션'),
        automaticallyImplyLeading: false,
      ),
      body: moderationsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('대기중인 검토 항목이 없습니다.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AdminVisitModerationCard(
                  item: item,
                  onApprove: () async {
                    await ref.read(adminRepositoryProvider).approveModerationItem(item.visitId);
                    ref.invalidate(adminModerationsProvider);
                    ref.invalidate(adminStatsProvider);
                  },
                  onReject: (note) async {
                    await ref.read(adminRepositoryProvider).rejectModerationItem(item.visitId, note);
                    ref.invalidate(adminModerationsProvider);
                    ref.invalidate(adminStatsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
