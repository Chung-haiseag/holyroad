import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/core/providers/sites_provider.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 검색어 상태
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 유형 필터 상태
final siteTypeFilterProvider = StateProvider<Set<HolySiteType>>((ref) => {});

/// 필터링된 성지 목록
final filteredSitesProvider = Provider<List<HolySite>>((ref) {
  final allSites = ref.watch(allSitesProvider).valueOrNull ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final typeFilter = ref.watch(siteTypeFilterProvider);

  var filtered = allSites;

  if (query.isNotEmpty) {
    filtered = filtered
        .where((site) =>
            site.name.toLowerCase().contains(query) ||
            site.description.toLowerCase().contains(query))
        .toList();
  }

  if (typeFilter.isNotEmpty) {
    filtered = filtered.where((site) => typeFilter.contains(site.siteType)).toList();
  }

  return filtered;
});
