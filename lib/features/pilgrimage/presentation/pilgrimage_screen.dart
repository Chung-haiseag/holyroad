import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holyroad/core/services/ai_service.dart';
import 'package:holyroad/core/providers/user_persona_provider.dart';
import 'package:holyroad/core/services/image_upload_service.dart';
import 'package:holyroad/core/widgets/cached_holy_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';
import 'package:holyroad/features/pilgrimage/presentation/widgets/audio_guide_bar.dart';
import 'package:holyroad/features/pilgrimage/presentation/widgets/nearby_cafes_section.dart';
import 'package:holyroad/features/pilgrimage/presentation/widgets/prayer_submit_dialog.dart';

/// 성지별 실시간 순례자(방문자) 수 Provider
final sitePilgrimCountProvider = StreamProvider.family<int, String>((ref, siteId) {
  return FirebaseFirestore.instance
      .collection('visits')
      .where('siteId', isEqualTo: siteId)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d['userId'] as String).toSet().length);
});

/// 가이드 주제
enum GuideTopic {
  history('역사', Icons.history_edu, '이 성지가 걸어온 길'),
  people('인물', Icons.person, '헌신한 믿음의 사람들'),
  meditation('묵상', Icons.self_improvement, '이 자리에서 드리는 묵상'),
  prayer('기도', Icons.volunteer_activism, '함께 드리는 기도');

  final String label;
  final IconData icon;
  final String subtitle;
  const GuideTopic(this.label, this.icon, this.subtitle);
}

class PilgrimageScreen extends ConsumerStatefulWidget {
  final HolySite? site;

  const PilgrimageScreen({super.key, this.site});

  @override
  ConsumerState<PilgrimageScreen> createState() => _PilgrimageScreenState();
}

class _PilgrimageScreenState extends ConsumerState<PilgrimageScreen> {
  double? _distanceKm;
  bool _locationLoading = true;

  /// 현재 선택된 가이드 주제
  GuideTopic _selectedTopic = GuideTopic.history;

  /// 주제별 AI 생성 콘텐츠 캐시
  final Map<GuideTopic, String> _contentCache = {};

  /// 현재 AI 콘텐츠 로딩 중 여부
  bool _contentLoading = false;

  /// 현재 AI 스트리밍 텍스트
  String _streamingText = '';

  /// AI 스트림 구독
  StreamSubscription<String>? _streamSubscription;

  /// 하단 시트 확장 여부
  bool _sheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
    // 초기 콘텐츠 로드 (역사)
    _loadContent(GuideTopic.history);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// GPS 위치를 가져와 성지까지의 거리를 계산
  Future<void> _calculateDistance() async {
    if (widget.site == null) {
      setState(() => _locationLoading = false);
      return;
    }

    try {
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
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  /// AI 콘텐츠 로드 (캐시 활용)
  Future<void> _loadContent(GuideTopic topic) async {
    // 이미 캐시에 있으면 바로 사용
    if (_contentCache.containsKey(topic)) {
      setState(() {
        _selectedTopic = topic;
        _contentLoading = false;
        _streamingText = '';
      });
      return;
    }

    // 이전 스트림 취소
    _streamSubscription?.cancel();

    setState(() {
      _selectedTopic = topic;
      _contentLoading = true;
      _streamingText = '';
    });

    final siteName = widget.site?.name ?? '알 수 없는 성지';
    final aiService = ref.read(aiServiceProvider);
    final buffer = StringBuffer();

    try {
      final persona = ref.read(userPersonaProvider).valueOrNull;
      final stream = aiService.streamGuide(siteName, topic.label, persona: persona);
      _streamSubscription = stream.listen(
        (text) {
          if (!mounted) return;
          buffer.write(text);
          setState(() {
            _streamingText = buffer.toString();
          });
        },
        onDone: () {
          if (!mounted) return;
          final fullText = buffer.toString();
          setState(() {
            _contentCache[topic] = fullText;
            _contentLoading = false;
            _streamingText = '';
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _contentCache[topic] = '콘텐츠를 불러오는 중 오류가 발생했습니다. 다시 시도해 주세요.';
            _contentLoading = false;
            _streamingText = '';
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _contentCache[topic] = '콘텐츠를 불러올 수 없습니다. 네트워크 연결을 확인해 주세요.';
          _contentLoading = false;
          _streamingText = '';
        });
      }
    }
  }

  /// 현재 표시할 텍스트 (캐시 또는 스트리밍)
  String get _displayText {
    if (_contentCache.containsKey(_selectedTopic)) {
      return _contentCache[_selectedTopic]!;
    }
    return _streamingText;
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    if (site == null) {
      return _buildNoSiteView(context);
    }
    final siteName = site.name;
    final siteDescription = site.description;
    final siteImageUrl = site.imageUrl;
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
          // 배경 이미지
          CachedHolyImage(
            imageUrl: siteImageUrl,
            fit: BoxFit.cover,
          ),
          // 어두운 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.3, 0.7],
              ),
            ),
          ),

          // 성지 정보 (상단)
          Positioned(
            top: 100,
            left: 20,
            right: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 성지 유형 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _siteTypeColor(site.siteType).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _siteTypeLabel(site.siteType),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  siteName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  siteDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (distanceText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        distanceText,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 자동차 길찾기 버튼 (우측 상단)
          Positioned(
            top: 100,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'carRoute',
              onPressed: () => _launchCarRoute(site),
              backgroundColor: Colors.white,
              child: const Icon(Icons.directions_car, color: Colors.blue),
            ),
          ),

          // 하단 콘텐츠 영역
          _buildBottomSheet(context, siteName),
        ],
      ),
    );
  }

  /// 하단 슬라이딩 패널 (주제 탭 + AI 콘텐츠 + 오디오 가이드)
  Widget _buildBottomSheet(BuildContext context, String siteName) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.20,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 주제 탭 바
                _buildTopicTabs(context),

                const SizedBox(height: 12),

                // AI 콘텐츠 영역
                _buildContentArea(context),

                const SizedBox(height: 16),

                // 커뮤니티 섹션 (기도 남기기)
                _buildCommunitySection(context),

                const SizedBox(height: 16),

                // 주변 카페 섹션
                if (widget.site != null)
                  NearbyCafesSection(site: widget.site!),

                const SizedBox(height: 12),

                // 오디오 가이드 바
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: AudioGuideBar(
                    siteName: siteName,
                    topic: _selectedTopic.label,
                  ),
                ),

                const SizedBox(height: 64),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 주제 탭 바 (역사 / 인물 / 묵상 / 기도)
  Widget _buildTopicTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: GuideTopic.values.length,
        itemBuilder: (context, index) {
          final topic = GuideTopic.values[index];
          final isSelected = _selectedTopic == topic;

          return GestureDetector(
            onTap: () => _loadContent(topic),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    topic.icon,
                    size: 22,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// AI 콘텐츠 영역
  Widget _buildContentArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = _displayText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주제 제목
          Row(
            children: [
              Icon(_selectedTopic.icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                _selectedTopic.subtitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // 새로고침 버튼
              if (!_contentLoading)
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: colorScheme.primary),
                  onPressed: () {
                    _contentCache.remove(_selectedTopic);
                    _loadContent(_selectedTopic);
                  },
                  tooltip: '다시 불러오기',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 콘텐츠
          if (_contentLoading && text.isEmpty)
            _buildLoadingIndicator(context)
          else if (text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: colorScheme.onSurface,
                      ),
                      h2: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        height: 2.0,
                      ),
                      h3: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.8,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      em: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      listBullet: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                      blockquotePadding: const EdgeInsets.all(12),
                      blockquoteDecoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_contentLoading) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '계속 생성 중...',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )
          else
            _buildEmptyContent(context),
        ],
      ),
    );
  }

  /// 로딩 인디케이터
  Widget _buildLoadingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_selectedTopic.label} 가이드를 준비하고 있습니다...',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI가 이 성지에 대한 깊이 있는 이야기를 준비합니다',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 콘텐츠 표시
  Widget _buildEmptyContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              _selectedTopic.icon,
              size: 40,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '${_selectedTopic.label} 가이드를 불러오려면\n위 탭을 탭해 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 커뮤니티 섹션
  Widget _buildCommunitySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final siteId = widget.site?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '순례자 기도 커뮤니티',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (siteId != null)
                    Consumer(
                      builder: (context, ref, _) {
                        final countAsync = ref.watch(sitePilgrimCountProvider(siteId));
                        final count = countAsync.valueOrNull ?? 0;
                        return Text(
                          count > 0
                              ? '$count명의 순례자가 함께 기도했습니다'
                              : '첫 번째 순례자가 되어 기도를 남겨보세요',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        );
                      },
                    )
                  else
                    Text(
                      '기도를 남겨보세요',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showPrayerDialog(context),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('기도 남기기', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 성지 유형별 색상
  Color _siteTypeColor(HolySiteType type) {
    switch (type) {
      case HolySiteType.church:    return const Color(0xFFD32F2F);
      case HolySiteType.school:    return const Color(0xFF1565C0);
      case HolySiteType.museum:    return const Color(0xFF2E7D32);
      case HolySiteType.memorial:  return const Color(0xFFE65100);
      case HolySiteType.martyrdom: return const Color(0xFF880E4F);
      case HolySiteType.holySite:  return const Color(0xFF6A1B9A);
    }
  }

  /// 성지 유형별 라벨
  String _siteTypeLabel(HolySiteType type) {
    switch (type) {
      case HolySiteType.church:    return '⛪ 교회';
      case HolySiteType.school:    return '🏫 학교';
      case HolySiteType.museum:    return '🏛 박물관';
      case HolySiteType.memorial:  return '🏛 기념관';
      case HolySiteType.martyrdom: return '✝️ 순교지';
      case HolySiteType.holySite:  return '⭐ 성지';
    }
  }

  /// 카메라 버튼
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

  /// site가 null인 경우 표시할 뷰
  Widget _buildNoSiteView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('순례'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.church, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              '성지를 선택해 주세요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '지도에서 방문하고 싶은 성지를 선택하면\n상세 정보와 AI 가이드를 볼 수 있습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/map'),
              icon: const Icon(Icons.map),
              label: const Text('성지 찾기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 외부 지도 앱 실행 (자동차 경로 → 네이버 지도)
  Future<void> _launchCarRoute(HolySite? site) async {
    if (site == null) return;

    // 네이버 지도 앱 URL (nmap:// scheme)
    final naverApp = Uri.parse(
      'nmap://route/car?dlat=${site.latitude}&dlng=${site.longitude}'
      '&dname=${Uri.encodeComponent(site.name)}'
      '&appname=com.holyroad.holyroad',
    );

    // 웹 폴백 URL
    final naverWeb = Uri.parse(
      'https://map.naver.com/v5/directions/-/-/-/car'
      '?c=${site.longitude},${site.latitude},15,0,0,0,dh',
    );

    try {
      if (await canLaunchUrl(naverApp)) {
        await launchUrl(naverApp, mode: LaunchMode.externalApplication);
      } else {
        // 네이버 지도 앱이 없으면 웹으로 열기
        await launchUrl(naverWeb, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching Naver Map: $e');
    }
  }
}
