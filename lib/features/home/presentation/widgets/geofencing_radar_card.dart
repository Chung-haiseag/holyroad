import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/location_service.dart';
import 'package:holyroad/core/services/location_permission_service.dart';
import 'package:holyroad/core/services/real_location_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

class GeofencingRadarCard extends ConsumerWidget {
  const GeofencingRadarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbySitesAsync = ref.watch(nearbySitesProvider(5.0)); // 5km 반경

    return SizedBox(
      height: 180,
      child: nearbySitesAsync.when(
        data: (sites) {
          if (sites.isEmpty) {
            return _buildEmptyCard(context);
          }
          return PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: sites.length,
            itemBuilder: (context, index) {
              final site = sites[index];
              return GestureDetector(
                onTap: () => context.push('/pilgrimage', extra: site),
                child: _buildSiteCard(context, site),
              );
            },
          );
        },
        loading: () => _buildLoadingCard(context),
        error: (err, stack) {
          if (err is LocationServiceException) {
            return _buildPermissionErrorCard(context, ref, err);
          }
          return _buildGenericErrorCard(context, ref, '$err');
        },
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('위치를 확인하고 있습니다...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '주변 5km 내에 성지가 없습니다.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionErrorCard(
    BuildContext context,
    WidgetRef ref,
    LocationServiceException error,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 36,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(context, ref, error.permissionStatus),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    LocationPermissionStatus? status,
  ) {
    switch (status) {
      case LocationPermissionStatus.serviceDisabled:
        return FilledButton.icon(
          onPressed: () => LocationPermissionService.openLocationSettings(),
          icon: const Icon(Icons.settings, size: 18),
          label: const Text('위치 서비스 설정'),
        );
      case LocationPermissionStatus.deniedForever:
        return FilledButton.icon(
          onPressed: () => LocationPermissionService.openAppSettings(),
          icon: const Icon(Icons.settings, size: 18),
          label: const Text('앱 설정 열기'),
        );
      default:
        return FilledButton.icon(
          onPressed: () => ref.invalidate(nearbySitesProvider(5.0)),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('다시 시도'),
        );
    }
  }

  Widget _buildGenericErrorCard(BuildContext context, WidgetRef ref, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 36,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            '위치 정보를 불러올 수 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ref.invalidate(nearbySitesProvider(5.0)),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(BuildContext context, HolySite site) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        image: DecorationImage(
          image: NetworkImage(site.imageUrl),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${site.distanceKm.toStringAsFixed(1)} km 남음',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '레이더 활성화',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stream provider로 위치 서비스의 근처 성지 데이터를 감시
final nearbySitesProvider = StreamProvider.family<List<HolySite>, double>((ref, radius) {
  final service = ref.watch(locationServiceProvider);
  return service.getNearbySites(radius);
});
