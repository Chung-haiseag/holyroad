import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holyroad/core/services/nearby_places_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 성지 주변 카페 섹션 — 가로 스크롤 카드 리스트
class NearbyCafesSection extends StatefulWidget {
  final HolySite site;

  const NearbyCafesSection({super.key, required this.site});

  @override
  State<NearbyCafesSection> createState() => _NearbyCafesSectionState();
}

class _NearbyCafesSectionState extends State<NearbyCafesSection> {
  List<NearbyPlace>? _cafes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCafes();
  }

  Future<void> _loadCafes() async {
    final results = await NearbyPlacesService.searchNearbyCafes(
      lat: widget.site.latitude,
      lng: widget.site.longitude,
      radius: 500,
    );
    if (mounted) {
      setState(() {
        _cafes = results;
        _loading = false;
      });
    }
  }

  /// 두 지점 간 직선 거리 계산 (미터)
  int _distanceFromSite(NearbyPlace place) {
    const r = 6371000.0; // 지구 반지름 (미터)
    final dLat = _toRad(place.lat - widget.site.latitude);
    final dLng = _toRad(place.lng - widget.site.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(widget.site.latitude)) *
            math.cos(_toRad(place.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (r * c).round();
  }

  double _toRad(double deg) => deg * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    // 로딩 중이거나 결과 없으면 아무것도 표시하지 않음
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.local_cafe, size: 18),
            const SizedBox(width: 8),
            Text(
              '주변 카페를 찾고 있습니다...',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    if (_cafes == null || _cafes!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Icon(Icons.local_cafe, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '주변 카페',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_cafes!.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '네이버 플레이스 연결',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF03C75A), // 네이버 그린
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 가로 스크롤 카페 카드
          SizedBox(
            height: 152,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cafes!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _CafeCard(
                  cafe: _cafes![index],
                  distanceM: _distanceFromSite(_cafes![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 개별 카페 카드
class _CafeCard extends StatelessWidget {
  final NearbyPlace cafe;
  final int distanceM;

  const _CafeCard({required this.cafe, required this.distanceM});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _openNaverPlace(),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카페 아이콘 + 영업 상태
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_cafe, size: 18, color: Colors.brown),
                ),
                const Spacer(),
                if (cafe.isOpen != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cafe.isOpen!
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cafe.isOpen! ? '영업중' : '휴무',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cafe.isOpen! ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 카페명
            Text(
              cafe.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // 별점 + 거리
            Row(
              children: [
                if (cafe.rating > 0) ...[
                  const Icon(Icons.star, size: 13, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    cafe.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (cafe.userRatingsTotal > 0)
                    Text(
                      ' (${cafe.userRatingsTotal})',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
                const Spacer(),
                Icon(Icons.directions_walk, size: 12, color: colorScheme.primary),
                const SizedBox(width: 2),
                Text(
                  '${distanceM}m',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 네이버 플레이스에서 카페 검색 (앱 → 웹 fallback)
  Future<void> _openNaverPlace() async {
    final encodedName = Uri.encodeComponent(cafe.name);

    // 1) 네이버 지도 앱 URL (설치되어 있으면 앱으로 열림)
    final appUrl = Uri.parse(
      'nmap://search?query=$encodedName&appname=com.holyroad.holyroad',
    );

    // 2) 네이버 플레이스 웹 검색 (fallback)
    final webUrl = Uri.parse(
      'https://map.naver.com/p/search/$encodedName',
    );

    try {
      // 네이버 지도 앱 시도
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        // 앱이 없으면 웹으로 열기
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 최종 fallback: 웹 브라우저
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        debugPrint('[NearbyPlaces] 네이버 플레이스 열기 실패: $e');
      }
    }
  }
}
