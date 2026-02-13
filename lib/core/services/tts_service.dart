import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service.g.dart';

/// TTS 서비스 인터페이스.
/// AI 가이드 텍스트를 음성으로 변환하여 읽어줍니다.
abstract class TtsService {
  /// TTS 엔진 초기화
  Future<void> initialize();

  /// 텍스트를 음성으로 읽기
  Future<void> speak(String text);

  /// 현재 읽기 중지
  Future<void> stop();

  /// 일시정지
  Future<void> pause();

  /// 재개 (일시정지 후)
  Future<void> resume();

  /// 음성 속도 설정 (0.0 ~ 1.0, 기본 0.5)
  Future<void> setSpeechRate(double rate);

  /// 음높이 설정 (0.5 ~ 2.0, 기본 1.0)
  Future<void> setPitch(double pitch);

  /// 현재 재생 중인지 여부
  bool get isSpeaking;

  /// 일시정지 상태인지 여부
  bool get isPaused;

  /// TTS 상태 변화 콜백 등록
  void setOnComplete(VoidCallback callback);
  void setOnStart(VoidCallback callback);
  void setOnError(VoidCallback callback);

  /// 리소스 해제
  Future<void> dispose();
}

/// 실제 TTS 서비스 (flutter_tts 패키지 사용)
class RealTtsService implements TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _initialized = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // 한국어 설정
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    // iOS 설정: 오디오 세션 카테고리
    if (!kIsWeb && Platform.isIOS) {
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    // macOS 설정: 공유 인스턴스 사용
    if (!kIsWeb && Platform.isMacOS) {
      await _flutterTts.setSharedInstance(true);
    }

    // 상태 콜백 등록
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _isPaused = false;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      _isPaused = false;
    });

    _flutterTts.setPauseHandler(() {
      _isSpeaking = false;
      _isPaused = true;
    });

    _flutterTts.setContinueHandler(() {
      _isSpeaking = true;
      _isPaused = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      _isPaused = false;
      debugPrint('TTS Error: $msg');
    });

    _initialized = true;
  }

  @override
  Future<void> speak(String text) async {
    if (!_initialized) await initialize();
    if (text.isEmpty) return;

    _isSpeaking = true;
    _isPaused = false;
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
    _isPaused = false;
    await _flutterTts.stop();
  }

  @override
  Future<void> pause() async {
    if (_isSpeaking) {
      _isPaused = true;
      _isSpeaking = false;
      await _flutterTts.pause();
    }
  }

  @override
  Future<void> resume() async {
    // flutter_tts doesn't have a native resume - re-speak is handled at widget level
    // On some platforms pause/continue works natively
    _isPaused = false;
    _isSpeaking = true;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  @override
  void setOnComplete(VoidCallback callback) {
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      callback();
    });
  }

  @override
  void setOnStart(VoidCallback callback) {
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _isPaused = false;
      callback();
    });
  }

  @override
  void setOnError(VoidCallback callback) {
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      _isPaused = false;
      debugPrint('TTS Error: $msg');
      callback();
    });
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}

/// Mock TTS 서비스 (Web/테스트용)
class MockTtsService implements TtsService {
  bool _isSpeaking = false;
  bool _isPaused = false;
  VoidCallback? _onComplete;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text) async {
    _isSpeaking = true;
    _isPaused = false;
    debugPrint('[MockTTS] Speaking: $text');
    // 읽는 시간 시뮬레이션 (글자당 100ms)
    await Future.delayed(Duration(milliseconds: text.length * 100));
    _isSpeaking = false;
    _onComplete?.call();
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
    _isPaused = false;
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
    _isSpeaking = false;
  }

  @override
  Future<void> resume() async {
    _isPaused = false;
    _isSpeaking = true;
  }

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  void setOnComplete(VoidCallback callback) {
    _onComplete = callback;
  }

  @override
  void setOnStart(VoidCallback callback) {}

  @override
  void setOnError(VoidCallback callback) {}

  @override
  Future<void> dispose() async {
    await stop();
  }
}

/// TTS 서비스 프로바이더.
/// Web에서는 MockTtsService, 네이티브에서는 RealTtsService를 사용합니다.
@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
TtsService ttsService(TtsServiceRef ref) {
  if (kIsWeb) return MockTtsService();

  final service = RealTtsService();
  // 프로바이더 생성 시 초기화
  service.initialize();
  return service;
}
