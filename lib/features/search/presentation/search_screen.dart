import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/search/domain/providers/search_providers.dart';
import 'package:holyroad/features/search/presentation/widgets/search_result_tile.dart';

/// 성지 검색 화면
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 이전 검색 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(siteTypeFilterProvider.notifier).state = {};
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredSites = ref.watch(filteredSitesProvider);
    final typeFilter = ref.watch(siteTypeFilterProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '성지 이름 또는 설명으로 검색...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: Column(
        children: [
          // 유형 필터 칩
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: HolySiteType.values.map((type) {
                final isSelected = typeFilter.contains(type);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(_typeLabel(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      final current = ref.read(siteTypeFilterProvider);
                      if (selected) {
                        ref.read(siteTypeFilterProvider.notifier).state = {...current, type};
                      } else {
                        ref.read(siteTypeFilterProvider.notifier).state = {...current}..remove(type);
                      }
                    },
                    selectedColor: _typeColor(type).withValues(alpha: 0.2),
                    checkmarkColor: _typeColor(type),
                    labelStyle: TextStyle(
                      color: isSelected ? _typeColor(type) : colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 결과 수 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredSites.length}개 성지',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (typeFilter.isNotEmpty || query.isNotEmpty) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(siteTypeFilterProvider.notifier).state = {};
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('초기화', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),

          // 결과 리스트
          Expanded(
            child: filteredSites.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredSites.length,
                    itemBuilder: (context, index) {
                      final site = filteredSites[index];
                      return SearchResultTile(
                        site: site,
                        onTap: () => context.pop(site),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '다른 검색어나 필터를 시도해 보세요',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(HolySiteType type) => switch (type) {
        HolySiteType.church => '⛪ 교회',
        HolySiteType.school => '🏫 학교',
        HolySiteType.museum => '🏛 박물관',
        HolySiteType.memorial => '🏛 기념관',
        HolySiteType.martyrdom => '✝️ 순교지',
        HolySiteType.holySite => '⭐ 성지',
      };

  Color _typeColor(HolySiteType type) => switch (type) {
        HolySiteType.church => const Color(0xFFD32F2F),
        HolySiteType.school => const Color(0xFF1565C0),
        HolySiteType.museum => const Color(0xFF2E7D32),
        HolySiteType.memorial => const Color(0xFFE65100),
        HolySiteType.martyrdom => const Color(0xFF880E4F),
        HolySiteType.holySite => const Color(0xFF6A1B9A),
      };
}
