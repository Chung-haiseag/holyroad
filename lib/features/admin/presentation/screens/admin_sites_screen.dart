import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/admin/domain/repositories/admin_repository.dart';
import 'package:holyroad/features/admin/presentation/providers/admin_providers.dart';
import 'package:holyroad/features/admin/presentation/widgets/admin_site_form_dialog.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

class AdminSitesScreen extends ConsumerStatefulWidget {
  const AdminSitesScreen({super.key});

  @override
  ConsumerState<AdminSitesScreen> createState() => _AdminSitesScreenState();
}

class _AdminSitesScreenState extends ConsumerState<AdminSitesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  HolySiteType? _selectedType;

  static const _typeLabels = <HolySiteType, String>{
    HolySiteType.church: '교회',
    HolySiteType.school: '학교',
    HolySiteType.museum: '박물관',
    HolySiteType.memorial: '기념관',
    HolySiteType.martyrdom: '순교지',
    HolySiteType.holySite: '성지',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HolySite> _filterSites(List<HolySite> sites) {
    var filtered = sites;

    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q) ||
            s.id.toLowerCase().contains(q);
      }).toList();
    }

    // 유형 필터
    if (_selectedType != null) {
      filtered = filtered.where((s) => s.siteType == _selectedType).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
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
          final filtered = _filterSites(sites);

          return Column(
            children: [
              // ── 검색 바 + 필터 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    // 검색 입력
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '성지 이름 또는 설명 검색...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLowest,
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 유형 필터 드롭다운
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<HolySiteType?>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: '유형',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLowest,
                        ),
                        items: [
                          const DropdownMenuItem<HolySiteType?>(
                            value: null,
                            child: Text('전체'),
                          ),
                          ..._typeLabels.entries.map(
                            (e) => DropdownMenuItem<HolySiteType?>(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedType = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── 검색 결과 카운트 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Row(
                  children: [
                    Text(
                      '총 ${filtered.length}개',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty || _selectedType != null) ...[
                      Text(
                        ' / 전체 ${sites.length}개',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedType = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('초기화'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── 테이블 ──
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty || _selectedType != null
                                  ? '검색 결과가 없습니다'
                                  : '등록된 성지가 없습니다',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            ),
                            border: TableBorder.all(
                              color: colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            columns: const [
                              DataColumn(label: Text('이름')),
                              DataColumn(label: Text('유형')),
                              DataColumn(label: Text('설명')),
                              DataColumn(label: Text('위도')),
                              DataColumn(label: Text('경도')),
                              DataColumn(label: Text('작업')),
                            ],
                            rows: filtered
                                .map(
                                  (site) => DataRow(
                                    cells: [
                                      DataCell(Text(
                                        site.name,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      )),
                                      DataCell(_buildTypeChip(site.siteType, colorScheme)),
                                      DataCell(SizedBox(
                                        width: 200,
                                        child: Text(
                                          site.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
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
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTypeChip(HolySiteType type, ColorScheme colorScheme) {
    final label = _typeLabels[type] ?? type.name;
    final color = switch (type) {
      HolySiteType.church => Colors.indigo,
      HolySiteType.school => Colors.teal,
      HolySiteType.museum => Colors.amber.shade800,
      HolySiteType.memorial => Colors.deepOrange,
      HolySiteType.martyrdom => Colors.red.shade700,
      HolySiteType.holySite => colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
