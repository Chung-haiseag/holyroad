import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/admin/domain/repositories/admin_repository.dart';
import 'package:holyroad/features/admin/presentation/providers/admin_providers.dart';
import 'package:holyroad/features/admin/presentation/widgets/admin_site_form_dialog.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

class AdminSitesScreen extends ConsumerWidget {
  const AdminSitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(adminSitesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('성지 관리'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('성지 추가'),
            ),
          ),
        ],
      ),
      body: sitesAsync.when(
        data: (sites) {
          if (sites.isEmpty) {
            return const Center(child: Text('등록된 성지가 없습니다.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                border: TableBorder.all(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(8)),
                columns: const [
                  DataColumn(label: Text('이름')),
                  DataColumn(label: Text('설명')),
                  DataColumn(label: Text('위도')),
                  DataColumn(label: Text('경도')),
                  DataColumn(label: Text('작업')),
                ],
                rows: sites.map((site) => DataRow(
                  cells: [
                    DataCell(Text(site.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(SizedBox(width: 200, child: Text(site.description, maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Text(site.latitude.toStringAsFixed(4))),
                    DataCell(Text(site.longitude.toStringAsFixed(4))),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 18, color: colorScheme.primary),
                          tooltip: '수정',
                          onPressed: () => _showEditDialog(context, ref, site),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: colorScheme.error),
                          tooltip: '삭제',
                          onPressed: () => _showDeleteConfirm(context, ref, site),
                        ),
                      ],
                    )),
                  ],
                )).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<HolySite>(
      context: context,
      builder: (ctx) => const AdminSiteFormDialog(),
    );
    if (result != null) {
      await ref.read(adminRepositoryProvider).createSite(result);
      ref.invalidate(adminSitesProvider);
      ref.invalidate(adminStatsProvider);
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, HolySite site) async {
    final result = await showDialog<HolySite>(
      context: context,
      builder: (ctx) => AdminSiteFormDialog(site: site),
    );
    if (result != null) {
      await ref.read(adminRepositoryProvider).updateSite(result);
      ref.invalidate(adminSitesProvider);
    }
  }

  Future<void> _showDeleteConfirm(BuildContext context, WidgetRef ref, HolySite site) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text("'${site.name}'을(를) 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminRepositoryProvider).deleteSite(site.id);
      ref.invalidate(adminSitesProvider);
      ref.invalidate(adminStatsProvider);
    }
  }
}
