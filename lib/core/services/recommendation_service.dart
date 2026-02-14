import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/core/providers/sites_provider.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 오늘의 추천 성지 Provider.
/// 날짜 기반으로 매일 다른 성지를 추천합니다.
final dailyRecommendationProvider = FutureProvider<HolySite?>((ref) async {
  final sites = await ref.watch(allSitesProvider.future);
  if (sites.isEmpty) return null;

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return sites[dayOfYear % sites.length];
});
