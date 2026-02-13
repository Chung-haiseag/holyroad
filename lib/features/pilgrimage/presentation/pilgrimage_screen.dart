import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holyroad/core/services/image_upload_service.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/pilgrimage/presentation/widgets/audio_guide_bar.dart';
import 'package:holyroad/features/pilgrimage/presentation/widgets/prayer_submit_dialog.dart';

class PilgrimageScreen extends ConsumerStatefulWidget {
  final HolySite? site;

  const PilgrimageScreen({super.key, this.site});

  @override
  ConsumerState<PilgrimageScreen> createState() => _PilgrimageScreenState();
}

class _PilgrimageScreenState extends ConsumerState<PilgrimageScreen> {
  double? _distanceKm;
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  /// GPS 위치를 가져와 성지까지의 거리를 계산
  Future<void> _calculateDistance() async {
    if (widget.site == null) {
      setState(() => _locationLoading = false);
      return;
    }

    try {
      // 이미 distanceKm이 계산되어 있으면 그 값 사용
      if (widget.site!.distanceKm > 0) {
        setState(() {
          _distanceKm = widget.site!.distanceKm;
          _locationLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.site!.latitude,
        widget.site!.longitude,
      );

      if (mounted) {
        setState(() {
          _distanceKm = distanceMeters / 1000;
          _locationLoading = false;
        });
      }
    } catch (_) {
      // 위치 권한 없거나 에러 시 거리 표시 생략
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final siteName = site?.name ?? '양화진';
    final siteDescription = site?.description ?? '외국인 선교사 묘원';
    final siteImageUrl = site?.imageUrl ?? 'https://picsum.photos/seed/history/800/1200';
    final distanceText = _distanceKm != null
        ? '현재 위치에서 ${_distanceKm!.toStringAsFixed(1)} km'
        : '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () => _onCameraPressed(context, ref),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 몰입형 배경 이미지
          Image.network(
            siteImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
              ),
            ),
          ),
          // 어두운 오버레이
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          // 성지 정보
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siteName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  siteDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                if (distanceText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        distanceText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 하단 영역: 커뮤니티 팝업 + 도슨트 바 (수직 배치)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 커뮤니티 팝업 (기도 남기기)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '현재 12명의 순례자가 함께 기도하고 있습니다.',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showPrayerDialog(context),
                            child: const Text('기도 남기기'),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 도슨트 바
                    AudioGuideBar(
                      siteName: siteName,
                      topic: '역사',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카메라 버튼: 사진 촬영 후 기도문 다이얼로그 열기
  void _onCameraPressed(BuildContext context, WidgetRef ref) async {
    final uploadService = ref.read(imageUploadServiceProvider);
    final image = await uploadService.pickImage(ImageSource.camera);

    if (context.mounted) {
      _showPrayerDialog(context, initialImage: image);
    }
  }

  /// 기도 남기기 바텀시트 열기
  void _showPrayerDialog(BuildContext context, {XFile? initialImage}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PrayerSubmitDialog(
        site: widget.site,
        initialImage: initialImage,
      ),
    );
  }
}
