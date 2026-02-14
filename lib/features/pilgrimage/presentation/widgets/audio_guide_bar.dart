import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/core/services/ai_service.dart';
import 'package:holyroad/core/providers/user_persona_provider.dart';
import 'package:holyroad/core/services/tts_service.dart';

/// 오디오 가이드 바.
/// AI 서비스에서 스트리밍된 텍스트를 TTS로 음성 재생합니다.
/// [siteName]과 [topic]으로 성지별 맞춤 가이드를 제공합니다.
class AudioGuideBar extends ConsumerStatefulWidget {
  final String siteName;
  final String topic;

  const AudioGuideBar({
    super.key,
    this.siteName = '양화진',
    this.topic = '역사',
  });

  @override
  ConsumerState<AudioGuideBar> createState() => _AudioGuideBarState();
}

class _AudioGuideBarState extends ConsumerState<AudioGuideBar>
    with SingleTickerProviderStateMixin {
  /// 재생 상태
  bool _isPlaying = false;

  /// AI 텍스트 로딩 중
  bool _isLoading = false;

  /// 현재 표시 텍스트
  String _currentText = '';

  /// 전체 AI 응답 텍스트 (TTS용)
  String _fullText = '';

  /// AI 스트림 구독
  StreamSubscription<String>? _streamSubscription;

  /// 음성 속도 (0.0~1.0)
  double _speechRate = 0.5;

  /// 웨이브 애니메이션 컨트롤러
  late AnimationController _waveController;

  /// TTS 서비스 참조 (dispose에서 안전하게 사용하기 위해 캐싱)
  TtsService? _ttsService;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didUpdateWidget(covariant AudioGuideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 주제가 변경되면 재생 중인 가이드 초기화
    if (oldWidget.topic != widget.topic || oldWidget.siteName != widget.siteName) {
      _onStop();
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _waveController.dispose();
    // TTS 정지 (캐싱된 참조 사용 - ref.read()는 dispose 후 사용 불가)
    _ttsService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 가이드 텍스트 표시 영역
          if (_currentText.isNotEmpty || _isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
              child: _isLoading && _currentText.isEmpty
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '가이드를 준비하고 있습니다...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    )
                  : Text(
                      _currentText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            height: 1.4,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

          // 컨트롤 영역
          Row(
            children: [
              // 재생/정지 버튼
              _buildPlayButton(colorScheme),
              const SizedBox(width: 8),

              // 웨이브 인디케이터 또는 타이틀
              Expanded(child: _buildTitleOrWave(context, colorScheme)),

              // 속도 조절 버튼
              if (_isPlaying || _currentText.isNotEmpty)
                _buildSpeedButton(context, colorScheme),

              // 정지 버튼
              if (_isPlaying || _currentText.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.stop, color: colorScheme.onPrimaryContainer),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _onStop,
                  tooltip: '정지',
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 재생/일시정지 버튼
  Widget _buildPlayButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: colorScheme.onPrimary,
        ),
        iconSize: 28,
        onPressed: _isLoading ? null : _onPlayPause,
        tooltip: _isPlaying ? '일시정지' : '재생',
      ),
    );
  }

  /// 웨이브 또는 타이틀
  Widget _buildTitleOrWave(BuildContext context, ColorScheme colorScheme) {
    if (_isPlaying) {
      return _buildWaveIndicator(colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'AI 도슨트',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '${widget.siteName} · ${widget.topic} 이야기',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  /// 음성 재생 중 웨이브 인디케이터
  Widget _buildWaveIndicator(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final offset = index * 0.15;
            final value = ((_waveController.value + offset) % 1.0);
            final height = 8.0 + (value * 16.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  /// 속도 조절 버튼
  Widget _buildSpeedButton(BuildContext context, ColorScheme colorScheme) {
    final label = _speechRate <= 0.3
        ? '0.5x'
        : _speechRate <= 0.5
            ? '1.0x'
            : _speechRate <= 0.7
                ? '1.5x'
                : '2.0x';

    return GestureDetector(
      onTap: _onSpeedChange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  /// 재생/일시정지 토글
  void _onPlayPause() {
    if (_isPlaying) {
      _pauseGuide();
    } else {
      if (_fullText.isEmpty) {
        _startGuide();
      } else {
        _resumeGuide();
      }
    }
  }

  /// 가이드 시작 - AI 텍스트 스트리밍 + TTS 재생
  void _startGuide() async {
    final aiService = ref.read(aiServiceProvider);
    final ttsService = ref.read(ttsServiceProvider);
    _ttsService = ttsService;

    setState(() {
      _isLoading = true;
      _isPlaying = true;
      _currentText = '';
      _fullText = '';
    });

    _waveController.repeat();

    // TTS 완료 콜백
    ttsService.setOnComplete(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _waveController.stop();
        _waveController.reset();
      }
    });

    ttsService.setOnError(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
        _waveController.stop();
        _waveController.reset();
      }
    });

    // AI 스트림에서 텍스트 수집
    final buffer = StringBuffer();

    try {
      final persona = ref.read(userPersonaProvider).valueOrNull;
      final stream = aiService.streamGuide(widget.siteName, widget.topic, persona: persona);
      _streamSubscription = stream.listen(
        (text) {
          if (!mounted || !_isPlaying) return;
          buffer.write(text);
          setState(() {
            _currentText = buffer.toString();
            _isLoading = false;
          });
        },
        onDone: () async {
          if (!mounted) return;
          _fullText = buffer.toString();
          setState(() {
            _isLoading = false;
            _currentText = _fullText;
          });

          // 전체 텍스트를 TTS로 읽기
          if (_isPlaying && _fullText.isNotEmpty) {
            await ttsService.speak(_fullText);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _isPlaying = false;
            _currentText = '가이드 생성 중 오류가 발생했습니다.';
          });
          _waveController.stop();
          _waveController.reset();
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
          _currentText = '가이드를 시작할 수 없습니다.';
        });
        _waveController.stop();
        _waveController.reset();
      }
    }
  }

  /// 일시정지
  void _pauseGuide() async {
    final ttsService = ref.read(ttsServiceProvider);
    _ttsService = ttsService;
    await ttsService.pause();
    setState(() {
      _isPlaying = false;
    });
    _waveController.stop();
  }

  /// 재개 (이미 수집된 전체 텍스트로 다시 읽기)
  void _resumeGuide() async {
    final ttsService = ref.read(ttsServiceProvider);
    _ttsService = ttsService;

    setState(() {
      _isPlaying = true;
    });
    _waveController.repeat();

    // flutter_tts의 pause/resume은 플랫폼 제한이 있으므로 전체 텍스트를 다시 읽음
    if (_fullText.isNotEmpty) {
      await ttsService.speak(_fullText);
    }
  }

  /// 완전 정지 (텍스트 초기화)
  void _onStop() async {
    final ttsService = ref.read(ttsServiceProvider);
    _ttsService = ttsService;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    await ttsService.stop();

    setState(() {
      _isPlaying = false;
      _isLoading = false;
      _currentText = '';
      _fullText = '';
    });
    _waveController.stop();
    _waveController.reset();
  }

  /// 속도 순환: 0.3(느림) → 0.5(보통) → 0.7(빠름) → 0.9(매우빠름) → 0.3
  void _onSpeedChange() async {
    final ttsService = ref.read(ttsServiceProvider);
    _ttsService = ttsService;

    double newRate;
    if (_speechRate <= 0.3) {
      newRate = 0.5;
    } else if (_speechRate <= 0.5) {
      newRate = 0.7;
    } else if (_speechRate <= 0.7) {
      newRate = 0.9;
    } else {
      newRate = 0.3;
    }

    setState(() {
      _speechRate = newRate;
    });

    await ttsService.setSpeechRate(newRate);

    // 재생 중이면 새 속도로 다시 읽기
    if (_isPlaying && _fullText.isNotEmpty) {
      await ttsService.speak(_fullText);
    }
  }
}
