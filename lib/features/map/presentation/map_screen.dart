import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holyroad/core/services/directions_service.dart';
import 'package:holyroad/core/utils/custom_marker_generator.dart';
import 'package:holyroad/core/providers/sites_provider.dart';
import 'package:holyroad/core/widgets/cached_holy_image.dart';
import 'package:holyroad/core/services/nearby_places_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// 성지 지도 화면.
/// 네이버 지도가 지원되는 플랫폼(Android/iOS)에서는 지도를 표시하고,
/// 미지원 플랫폼(macOS/Web/Linux/Windows)에서는 리스트 형태의 대체 UI를 표시합니다.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  NaverMapController? _mapController;
  HolySite? _selectedSite;
  bool _isLoadingRoute = false;
  DirectionsResult? _routeResult;
  bool _isRouteDetailExpanded = false;
  bool _markersReady = false;

  // 내 위치 커스텀 마커
  NOverlayImage? _myLocationIcon;
  NLatLng? _myLocation;
  StreamSubscription<Position>? _locationSub;

  // 카페 마커
  Set<NMarker> _cafeMarkers = {};
  bool _loadingCafes = false;
  NearbyPlace? _selectedCafe;
  NOverlayImage? _cafeIcon;

  // 현재 지도에 표시된 성지 목록 (오버레이 업데이트용)
  List<HolySite> _currentSites = [];

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _initMyLocation();
  }

  Future<void> _initMarkers() async {
    await CustomMarkerGenerator.preloadMarkers();
    _cafeIcon = await CustomMarkerGenerator.getCafeMarker();
    if (mounted) {
      setState(() => _markersReady = true);
      // 마커 준비 후 지도에 오버레이 업데이트
      _updateOverlays();
    }
  }

  /// 내 위치 커스텀 마커 초기화 + 위치 스트림 구독
  Future<void> _initMyLocation() async {
    _myLocationIcon = await CustomMarkerGenerator.getMyLocationMarker();

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) {
        setState(() => _myLocation = NLatLng(pos.latitude, pos.longitude));
        _updateMyLocationMarker();
      }

      // 50m 이동마다 위치 업데이트
      _locationSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() => _myLocation = NLatLng(pos.latitude, pos.longitude));
          _updateMyLocationMarker();
        }
      });
    } catch (e) {
      debugPrint('[HolyRoad] 내 위치 가져오기 실패: $e');
    }
  }

  /// 네이버 지도 지원 여부 (Android, iOS만 지원)
  bool get _isMapSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // 서울 중심 좌표 (기본값)
  static const _defaultCenter = NLatLng(37.555, 126.94);
  static const _defaultZoom = 11.5;

  @override
  void dispose() {
    _locationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// 지도에 성지 마커를 추가/업데이트
  Future<void> _updateOverlays() async {
    if (_mapController == null || !_markersReady) return;

    // 기존 성지 마커 제거
    for (final site in _currentSites) {
      _mapController?.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: site.id));
    }

    // 새 성지 마커 추가
    for (final site in _currentSites) {
      final icon = CustomMarkerGenerator.getMarker(site.siteType);
      final marker = NMarker(
        id: site.id,
        position: NLatLng(site.latitude, site.longitude),
      );
      if (icon != null) {
        marker.setIcon(icon);
      }
      marker.setCaption(NOverlayCaption(text: site.name, textSize: 12));
      marker.setOnTapListener((overlay) {
        setState(() {
          _selectedSite = site;
          _routeResult = null;
          _isRouteDetailExpanded = false;
        });
        // 경로 오버레이 제거
        _mapController?.deleteOverlay(
          const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'route'),
        );
      });
      await _mapController?.addOverlay(marker);
    }
  }

  /// 내 위치 마커 업데이트
  Future<void> _updateMyLocationMarker() async {
    if (_mapController == null || _myLocation == null || _myLocationIcon == null) return;

    final marker = NMarker(
      id: 'my_location',
      position: _myLocation!,
    );
    marker.setIcon(_myLocationIcon!);
    marker.setAnchor(const NPoint(0.5, 0.5));
    marker.setZIndex(999);
    await _mapController?.addOverlay(marker);
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(allSitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('성지 지도'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '성지 검색',
            onPressed: () async {
              final selectedSite = await context.push<HolySite>('/search');
              if (selectedSite != null && _mapController != null) {
                final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                  target: NLatLng(selectedSite.latitude, selectedSite.longitude),
                  zoom: 15.0,
                );
                await _mapController!.updateCamera(cameraUpdate);
                setState(() {
                  _selectedSite = selectedSite;
                  _routeResult = null;
                  _isRouteDetailExpanded = false;
                });
              }
            },
          ),
        ],
      ),
      body: sitesAsync.when(
        data: (sites) {
          _currentSites = sites;
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

  /// 네이버 지도 뷰 (Android/iOS)
  Widget _buildMapView(BuildContext context, List<HolySite> sites) {
    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: _defaultCenter,
              zoom: _defaultZoom,
            ),
            locationButtonEnable: false,
            zoomGesturesFriction: 0.12,
            scrollGesturesFriction: 0.12,
            minZoom: 5,
            maxZoom: 18,
          ),
          onMapReady: (NaverMapController controller) {
            _mapController = controller;
            _updateOverlays();
            _updateMyLocationMarker();
          },
          onMapTapped: (NPoint point, NLatLng latLng) {
            if (_selectedSite != null || _routeResult != null || _cafeMarkers.isNotEmpty || _selectedCafe != null) {
              // 카페 마커 제거
              for (final cafe in _cafeMarkers) {
                _mapController?.deleteOverlay(
                  NOverlayInfo(type: NOverlayType.marker, id: cafe.info.id),
                );
              }
              // 경로 오버레이 제거
              _mapController?.deleteOverlay(
                const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'route'),
              );
              setState(() {
                _selectedSite = null;
                _routeResult = null;
                _isRouteDetailExpanded = false;
                _cafeMarkers = {};
                _selectedCafe = null;
              });
            }
          },
        ),
        // 경로 로딩 인디케이터
        if (_isLoadingRoute)
          const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('경로를 검색하고 있습니다...'),
                  ],
                ),
              ),
            ),
          ),
        // 경로 정보 표시 (상단)
        if (_routeResult != null && _routeResult!.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildRouteInfoCard(context),
          ),
        // 카페 로딩 인디케이터
        if (_loadingCafes)
          const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('주변 카페를 찾고 있습니다...'),
                  ],
                ),
              ),
            ),
          ),
        // 카페 표시 중 상단 배너
        if (_cafeMarkers.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 64,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.local_cafe, size: 18, color: Colors.brown),
                    const SizedBox(width: 8),
                    Text(
                      '주변 카페 ${_cafeMarkers.length}곳',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· 네이버 플레이스 연결',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF03C75A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        for (final cafe in _cafeMarkers) {
                          _mapController?.deleteOverlay(
                            NOverlayInfo(type: NOverlayType.marker, id: cafe.info.id),
                          );
                        }
                        setState(() {
                          _cafeMarkers = {};
                          _selectedCafe = null;
                        });
                      },
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // 내 위치로 이동 FAB
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'myLocationBtn',
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            onPressed: () {
              if (_myLocation != null && _mapController != null) {
                final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                  target: _myLocation!,
                  zoom: 15.0,
                );
                _mapController!.updateCamera(cameraUpdate);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        // 선택된 카페 정보 카드
        if (_selectedCafe != null)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: _buildCafeInfoCard(context, _selectedCafe!),
          ),
        // 선택된 성지 정보 카드
        if (_selectedSite != null && _selectedCafe == null)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: _buildSiteInfoCard(context, _selectedSite!),
          ),
      ],
    );
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
                CachedHolyImage(
                  imageUrl: site.imageUrl,
                  width: 70,
                  height: 70,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            Icon(Icons.location_on, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 2),
                            Text(
                              '${site.distanceKm.toStringAsFixed(1)} km',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _mapController?.deleteOverlay(
                      const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'route'),
                    );
                    setState(() {
                      _selectedSite = null;
                      _routeResult = null;
                      _isRouteDetailExpanded = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 순례하기 + 길찾기 + 카페 버튼 (3열 배치)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/pilgrimage', extra: site),
                    icon: const Icon(Icons.directions_walk, size: 16),
                    label: const Text('순례', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingRoute ? null : () => _showRoute(site),
                    icon: const Icon(Icons.directions_car, size: 16),
                    label: const Text('길찾기', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showNearbyCafes(site),
                    icon: const Icon(Icons.local_cafe, size: 16),
                    label: const Text('카페', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.brown,
                      side: BorderSide(color: Colors.brown.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 지도에 경로를 표시합니다.
  Future<void> _showRoute(HolySite site) async {
    setState(() => _isLoadingRoute = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final origin = NLatLng(position.latitude, position.longitude);
      final destination = NLatLng(site.latitude, site.longitude);

      final result = await DirectionsService.getRoute(
        origin: origin,
        destination: destination,
      );

      if (result.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('경로를 찾을 수 없습니다.')),
          );
        }
        setState(() => _isLoadingRoute = false);
        return;
      }

      // NPathOverlay 생성 및 추가
      if (result.polylineCoordinates.length >= 2) {
        final pathOverlay = NPathOverlay(
          id: 'route',
          coords: result.polylineCoordinates,
          color: Colors.blue,
          width: 5,
          outlineWidth: 0,
        );
        await _mapController?.addOverlay(pathOverlay);
      }

      setState(() {
        _routeResult = result;
        _isLoadingRoute = false;
      });

      // 카메라를 경로 전체가 보이도록 이동
      if (result.bounds != null && _mapController != null) {
        final cameraUpdate = NCameraUpdate.fitBounds(
          result.bounds!,
          padding: const EdgeInsets.all(80),
        );
        await _mapController!.updateCamera(cameraUpdate);
      }
    } catch (e) {
      debugPrint('Route error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 정보를 가져올 수 없습니다.')),
        );
      }
      setState(() => _isLoadingRoute = false);
    }
  }

  /// 리스트 뷰 - 지도 미지원 플랫폼 대체 UI
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

  /// 에러 시 대체 UI
  Widget _buildListFallback(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('위치 정보를 사용할 수 없어\n성지 목록을 불러올 수 없습니다.', textAlign: TextAlign.center),
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
              CachedHolyImage(
                imageUrl: site.imageUrl,
                width: 80,
                height: 80,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
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
                          Icon(Icons.location_on, size: 14, color: colorScheme.primary),
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
              IconButton(
                icon: Icon(Icons.directions_car, color: colorScheme.primary),
                tooltip: '자동차 길찾기',
                onPressed: () => _launchCarRoute(site),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  /// 경로 정보 카드
  Widget _buildRouteInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = _routeResult!;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${result.travelMode}  ${result.distance}  ·  ${result.duration}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _mapController?.deleteOverlay(
                      const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'route'),
                    );
                    setState(() {
                      _routeResult = null;
                      _isRouteDetailExpanded = false;
                    });
                  },
                  child: Icon(Icons.close, size: 20, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 주변 카페를 지도에 마커로 표시
  Future<void> _showNearbyCafes(HolySite site) async {
    // 이미 카페가 표시 중이면 토글 (닫기)
    if (_cafeMarkers.isNotEmpty) {
      for (final cafe in _cafeMarkers) {
        _mapController?.deleteOverlay(
          NOverlayInfo(type: NOverlayType.marker, id: cafe.info.id),
        );
      }
      setState(() {
        _cafeMarkers = {};
        _selectedCafe = null;
      });
      return;
    }

    setState(() {
      _loadingCafes = true;
      _selectedCafe = null;
    });

    final cafes = await NearbyPlacesService.searchNearbyCafes(
      lat: site.latitude,
      lng: site.longitude,
      radius: 500,
    );

    if (!mounted) return;

    if (cafes.isEmpty) {
      setState(() => _loadingCafes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반경 500m 내 카페가 없습니다.')),
      );
      return;
    }

    final markers = <NMarker>{};
    for (int i = 0; i < cafes.length; i++) {
      final cafe = cafes[i];
      final marker = NMarker(
        id: 'cafe_$i',
        position: NLatLng(cafe.lat, cafe.lng),
      );
      if (_cafeIcon != null) {
        marker.setIcon(_cafeIcon!);
      }
      marker.setCaption(NOverlayCaption(text: cafe.name, textSize: 11));
      marker.setZIndex(100);
      marker.setOnTapListener((overlay) {
        setState(() => _selectedCafe = cafe);
      });
      await _mapController?.addOverlay(marker);
      markers.add(marker);
    }

    setState(() {
      _cafeMarkers = markers;
      _loadingCafes = false;
    });

    // 성지 + 카페가 모두 보이도록 카메라 줌 조정
    if (_mapController != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(site.latitude, site.longitude),
        zoom: 15.5,
      );
      await _mapController!.updateCamera(cameraUpdate);
    }
  }

  /// 카페 정보 카드
  Widget _buildCafeInfoCard(BuildContext context, NearbyPlace cafe) {
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_cafe, size: 28, color: Colors.brown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cafe.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cafe.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (cafe.rating > 0) ...[
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              cafe.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (cafe.userRatingsTotal > 0)
                              Text(
                                ' (${cafe.userRatingsTotal})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            const SizedBox(width: 12),
                          ],
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cafe.isOpen! ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _selectedCafe = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openCafeInNaver(cafe),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('네이버 플레이스에서 보기'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF03C75A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 네이버 플레이스에서 카페 열기
  Future<void> _openCafeInNaver(NearbyPlace cafe) async {
    final encodedName = Uri.encodeComponent(cafe.name);
    final appUrl = Uri.parse(
      'nmap://search?query=$encodedName&appname=com.holyroad.holyroad',
    );
    final webUrl = Uri.parse(
      'https://map.naver.com/p/search/$encodedName',
    );

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        debugPrint('[NearbyPlaces] 네이버 플레이스 열기 실패: $e');
      }
    }
  }

  /// 외부 네이버 지도 앱 실행 (자동차 경로) - 리스트 뷰에서 사용
  Future<void> _launchCarRoute(HolySite site) async {
    final encodedName = Uri.encodeComponent(site.name);
    final appUrl = Uri.parse(
      'nmap://route/car?dlat=${site.latitude}&dlng=${site.longitude}&dname=$encodedName&appname=com.holyroad.holyroad',
    );
    final webUrl = Uri.parse(
      'https://map.naver.com/p/directions/-/${site.longitude},${site.latitude},$encodedName/car',
    );

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        debugPrint('Error launching Naver Map: $e');
      }
    }
  }
}
