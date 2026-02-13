import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holyroad/core/services/firestore_seed_service.dart';
import 'package:holyroad/core/services/location_permission_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firestore에서 모든 성지를 가져오는 Provider (위치 권한 불필요)
final allSitesProvider = FutureProvider<List<HolySite>>((ref) async {
  final service = FirestoreSeedService();
  final sites = await service.getAllSites();
  if (sites.isNotEmpty) return sites;
  // Firestore 실패 시 시드 데이터에서 가져옴
  return FirestoreSeedService.seedSites;
});

/// 성지 지도 화면.
/// Google Maps가 지원되는 플랫폼(Android/iOS)에서는 지도를 표시하고,
/// 미지원 플랫폼(macOS/Web/Linux/Windows)에서는 리스트 형태의 대체 UI를 표시합니다.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  HolySite? _selectedSite;

  // 경로 표시를 위한 상태
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  String _selectedMode = 'transit'; // 기본 이동 수단: 대중교통
  bool _isLoadingRoute = false;
  String? _routeInfo; // "대중교통 경로: 12.3 km, 약 45분"

  /// Google Maps 지원 여부 (Android, iOS만 지원)
  bool get _isMapSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // 서울 중심 좌표 (기본값)
  static const _defaultCenter = LatLng(37.555, 126.94);
  static const _defaultZoom = 11.5;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  static const _modeLabels = {
    'walking': '도보',
    'transit': '대중교통',
    'driving': '자동차',
  };

  static const _modeIcons = {
    'walking': Icons.directions_walk,
    'transit': Icons.directions_transit,
    'driving': Icons.directions_car,
  };

  static const _modeColors = {
    'walking': Colors.blue,
    'transit': Colors.green,
    'driving': Colors.orange,
  };

  /// Google Directions API를 사용하여 선택된 모드로 경로 가져오기
  Future<void> _getRoute(LatLng destination, String mode) async {
    setState(() {
      _isLoadingRoute = true;
      _routeInfo = null;
    });

    try {
      // 권한 확인 및 요청
      final permissionStatus =
          await LocationPermissionService.checkAndRequestPermission();

      if (permissionStatus == LocationPermissionStatus.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
        }
        return;
      }

      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.'),
              action: SnackBarAction(
                label: '설정',
                onPressed: () => LocationPermissionService.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final start = LatLng(position.latitude, position.longitude);

      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey == null) return;

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${start.latitude},${start.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=$mode'
        '&language=ko'
        '&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('네트워크 오류: ${response.statusCode}')),
          );
        }
        return;
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK' || (data['routes'] as List).isEmpty) {
        if (mounted) {
          setState(() {
            _polylines = {};
            _routePoints = [];
            _routeInfo = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_modeLabels[mode]} 경로를 찾을 수 없습니다. 다른 이동 수단을 선택해주세요.',
              ),
            ),
          );
        }
        return;
      }

      // 경로 찾기 성공
      final route = data['routes'][0];
      final overviewPolyline = route['overview_polyline']['points'];
      final result = PolylinePoints.decodePolyline(overviewPolyline);

      final leg = route['legs'][0];
      final distance = leg['distance']['text'] as String;
      final duration = leg['duration']['text'] as String;

      if (result.isNotEmpty && mounted) {
        setState(() {
          _routePoints = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              color: _modeColors[mode] ?? Colors.blue,
              points: _routePoints,
              width: 5,
            ),
          };

          _routeInfo = '$distance, 약 $duration';
        });

        // 경로가 보이도록 줌 조절
        final bounds = _boundsFromLatLngList([start, destination]);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  // 경로 좌표들을 포함하는 바운더리 계산
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Firestore에서 전체 성지 목록 조회 (위치 권한 불필요)
    final sitesAsync = ref.watch(allSitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: sitesAsync.when(
        data: (sites) {
          // 지도 지원 플랫폼이면 지도 표시, 아니면 리스트 표시
          if (_isMapSupported) {
            return _buildMapView(context, sites);
          }
          return _buildListView(context, sites);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildListFallback(context),
      ),
    );
  }

  /// Google Maps 지도 뷰 (Android/iOS)
  Widget _buildMapView(BuildContext context, List<HolySite> sites) {
    final markers = _buildMarkers(sites);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _defaultCenter,
            zoom: _defaultZoom,
          ),
          markers: markers,
          polylines: _polylines, // 경로 표시
          myLocationEnabled: true, // 내 위치 표시 (파란 점)
          myLocationButtonEnabled: true, // 내 위치로 이동 버튼
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
        // 선택된 성지 정보 카드
        if (_selectedSite != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildSiteInfoCard(context, _selectedSite!),
          ),
      ],
    );
  }

  /// 마커 생성
  Set<Marker> _buildMarkers(List<HolySite> sites) {
    return sites.map((site) {
      return Marker(
        markerId: MarkerId(site.id),
        position: LatLng(site.latitude, site.longitude),
        infoWindow: InfoWindow(title: site.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          setState(() {
            _selectedSite = site;
            // 선택 시 기존 경로 초기화
            _polylines = {};
            _routePoints = [];
            _routeInfo = null;
          });
          // 선택 시 자동으로 경로 탐색 하려면 아래 주석 해제 (단, API 호출 비용 발생)
          // _getRoute(LatLng(site.latitude, site.longitude));
        },
      );
    }).toSet();
  }

  /// 마커 탭 시 표시되는 성지 정보 카드
  Widget _buildSiteInfoCard(BuildContext context, HolySite site) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 성지 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    site.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.church),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 성지 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (site.distanceKm > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${site.distanceKm.toStringAsFixed(1)} km',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // 닫기 버튼
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() {
                    _selectedSite = null;
                    _polylines = {};
                    _routePoints = [];
                    _routeInfo = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 이동 수단 선택
            Row(
              children: ['walking', 'transit', 'driving'].map((mode) {
                final isSelected = _selectedMode == mode;
                final color = _modeColors[mode] ?? Colors.blue;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedMode = mode);
                      // 이미 경로가 표시된 상태면 새 모드로 자동 재검색
                      if (_routePoints.isNotEmpty) {
                        _getRoute(
                          LatLng(site.latitude, site.longitude),
                          mode,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : colorScheme.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _modeIcons[mode],
                            size: 20,
                            color: isSelected
                                ? color
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _modeLabels[mode] ?? mode,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? color
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // 경로 정보 표시
            if (_routeInfo != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (_modeColors[_selectedMode] ?? Colors.blue)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _modeIcons[_selectedMode],
                      size: 16,
                      color: _modeColors[_selectedMode],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _routeInfo!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _modeColors[_selectedMode],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            // 기능 버튼들
            Row(
              children: [
                // 길찾기 (경로 표시) 버튼
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _isLoadingRoute
                        ? null
                        : () {
                            _getRoute(
                              LatLng(site.latitude, site.longitude),
                              _selectedMode,
                            );
                          },
                    icon: _isLoadingRoute
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.directions, size: 18),
                    label: Text(_isLoadingRoute ? '검색 중...' : '길찾기'),
                  ),
                ),
                const SizedBox(width: 8),
                // 순례하기 버튼
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/pilgrimage', extra: site),
                    icon: const Icon(Icons.directions_walk, size: 18),
                    label: const Text('순례하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 리스트 뷰 - 지도 미지원 플랫폼 대체 UI (macOS/Web/Linux/Windows)
  Widget _buildListView(BuildContext context, List<HolySite> sites) {
    if (sites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('표시할 성지가 없습니다.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        return _buildSiteListTile(context, site);
      },
    );
  }

  /// 에러 시 하드코딩된 성지 리스트 표시
  Widget _buildListFallback(BuildContext context) {
    // LocationService에서 데이터를 못 가져올 때 빈 상태
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            '위치 정보를 사용할 수 없어\n성지 목록을 불러올 수 없습니다.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSiteListTile(BuildContext context, HolySite site) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/pilgrimage', extra: site),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 성지 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  site.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.church, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 성지 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (site.distanceKm > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${site.distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // 화살표
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
