import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// Canvas로 커스텀 마커 비트맵을 생성하는 유틸리티.
class CustomMarkerGenerator {
  static final Map<HolySiteType, NOverlayImage> _cache = {};

  /// 디버그용: 캐시된 키 목록
  static List<String> get cacheKeys => _cache.keys.map((k) => k.name).toList();

  /// 모든 유형의 마커를 미리 생성합니다.
  static Future<void> preloadMarkers() async {
    for (final type in HolySiteType.values) {
      if (!_cache.containsKey(type)) {
        _cache[type] = await _createMarker(type);
      }
    }
    debugPrint('[HolyRoad] preloadMarkers done: ${_cache.length} types cached: ${cacheKeys}');
  }

  /// 유형별 마커를 반환합니다.
  static NOverlayImage? getMarker(HolySiteType type) {
    final result = _cache[type];
    if (result == null) {
      debugPrint('[HolyRoad] getMarker MISS for $type');
    }
    return result;
  }

  /// 바이트 배열을 NOverlayImage로 변환하는 헬퍼
  static Future<NOverlayImage?> _bytesToOverlayImage(Uint8List bytes, {String? cacheKey}) async {
    try {
      return NOverlayImage.fromByteArray(bytes, cacheKey: cacheKey);
    } catch (e) {
      debugPrint('[HolyRoad] NOverlayImage 변환 실패: $e');
      return null;
    }
  }

  static Future<NOverlayImage> _createMarker(HolySiteType type) async {
    const double s = 48;   // 원 크기
    const double h = 62;   // 전체 높이 (꼬리 포함)

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bgColor = _bgColor(type);
    _drawPin(canvas, bgColor, s, h);
    _drawIcon(canvas, type, s);

    final picture = recorder.endRecording();
    final image = await picture.toImage(s.toInt(), h.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return const NOverlayImage.fromAssetImage('assets/images/marker_default.png');
    }
    final result = await _bytesToOverlayImage(
      byteData.buffer.asUint8List(),
      cacheKey: 'marker_${type.name}',
    );
    return result ?? const NOverlayImage.fromAssetImage('assets/images/marker_default.png');
  }

  static Color _bgColor(HolySiteType type) {
    switch (type) {
      case HolySiteType.church:    return const Color(0xFFD32F2F);
      case HolySiteType.school:    return const Color(0xFF1565C0);
      case HolySiteType.museum:    return const Color(0xFF2E7D32);
      case HolySiteType.memorial:  return const Color(0xFFE65100);
      case HolySiteType.martyrdom: return const Color(0xFF880E4F);
      case HolySiteType.holySite:  return const Color(0xFF6A1B9A);
    }
  }

  static void _drawPin(Canvas canvas, Color color, double s, double h) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final cx = s / 2;
    final cy = s / 2;
    final r = s / 2 - 3;

    // 그림자 + 원
    canvas.drawCircle(Offset(cx + 1, cy + 1), r, shadow);
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // 꼬리
    final tail = Path()
      ..moveTo(cx - 8, cy + r - 5)
      ..lineTo(cx, h - 2)
      ..lineTo(cx + 8, cy + r - 5)
      ..close();
    canvas.drawPath(tail.shift(const Offset(1, 1)), shadow);
    canvas.drawPath(tail, paint);

    // 흰색 내부 원
    canvas.drawCircle(Offset(cx, cy), r - 3, Paint()..color = Colors.white);
  }

  static void _drawIcon(Canvas canvas, HolySiteType type, double s) {
    final c = Offset(s / 2, s / 2);
    final color = _bgColor(type);

    switch (type) {
      case HolySiteType.church:    _cross(canvas, c, color); break;
      case HolySiteType.school:    _building(canvas, c, color); break;
      case HolySiteType.museum:    _museum(canvas, c, color); break;
      case HolySiteType.memorial:  _memorial(canvas, c, color); break;
      case HolySiteType.martyrdom: _martyrdom(canvas, c, color); break;
      case HolySiteType.holySite:  _star(canvas, c, color); break;
    }
  }

  /// ✝ 교회 - 십자가
  static void _cross(Canvas canvas, Offset c, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    // 세로
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, -1), width: 4, height: 18),
      const Radius.circular(1),
    ), p);
    // 가로
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, -5), width: 14, height: 4),
      const Radius.circular(1),
    ), p);
  }

  /// 🏫 학교 - 건물
  static void _building(Canvas canvas, Offset c, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final w = Paint()..color = Colors.white..style = PaintingStyle.fill;

    // 건물
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, 1), width: 16, height: 12),
      const Radius.circular(1),
    ), p);
    // 지붕
    canvas.drawPath(Path()
      ..moveTo(c.dx - 10, c.dy - 5)
      ..lineTo(c.dx, c.dy - 13)
      ..lineTo(c.dx + 10, c.dy - 5)
      ..close(), p);
    // 창문
    canvas.drawRect(Rect.fromCenter(center: c + const Offset(-3, 0), width: 3, height: 3), w);
    canvas.drawRect(Rect.fromCenter(center: c + const Offset(3, 0), width: 3, height: 3), w);
    canvas.drawRect(Rect.fromCenter(center: c + const Offset(0, 4.5), width: 3, height: 4), w);
  }

  /// 🏛 박물관 - 기둥건물
  static void _museum(Canvas canvas, Offset c, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    for (final dx in [-5.0, 0.0, 5.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(dx, 2), width: 3, height: 11),
        const Radius.circular(0.5),
      ), p);
    }
    canvas.drawPath(Path()
      ..moveTo(c.dx - 11, c.dy - 4)
      ..lineTo(c.dx, c.dy - 12)
      ..lineTo(c.dx + 11, c.dy - 4)
      ..close(), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, 8), width: 16, height: 3),
      const Radius.circular(0.5),
    ), p);
  }

  /// 🏛 기념관 - 비석
  static void _memorial(Canvas canvas, Offset c, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 9, height: 16),
      const Radius.circular(4.5),
    ), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, 8.5), width: 14, height: 3),
      const Radius.circular(0.5),
    ), p);
    canvas.drawCircle(c + const Offset(0, -3), 2, Paint()..color = Colors.white);
  }

  /// ✝ 순교지 - 원+십자가
  static void _martyrdom(Canvas canvas, Offset c, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(c, 9, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, -1), width: 3, height: 12),
      const Radius.circular(0.5),
    ), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + const Offset(0, -3), width: 9, height: 3),
      const Radius.circular(0.5),
    ), p);
  }

  /// ⭐ 성지 - 별
  static void _star(Canvas canvas, Offset c, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    const or = 8.0, ir = 3.5;
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? or : ir;
      final a = (i * math.pi / 5) - (math.pi / 2);
      final x = c.dx + r * math.cos(a);
      final y = c.dy + r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  // ───── 카페 마커 ─────

  static NOverlayImage? _cafeMarker;

  /// 카페 마커를 생성합니다 (브라운 핀 + 커피 아이콘).
  static Future<NOverlayImage?> getCafeMarker() async {
    if (_cafeMarker != null) return _cafeMarker!;
    _cafeMarker = await _createCafeMarker();
    return _cafeMarker;
  }

  static Future<NOverlayImage?> _createCafeMarker() async {
    const double s = 48;
    const double h = 62;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const cafeColor = Color(0xFF795548); // 브라운
    _drawPin(canvas, cafeColor, s, h);

    // 커피 컵 아이콘
    final c = Offset(s / 2, s / 2);
    final p = Paint()..color = cafeColor..style = PaintingStyle.fill;
    // 컵 몸체
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(0, 1), width: 12, height: 10),
        const Radius.circular(2),
      ),
      p,
    );
    // 컵 손잡이
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(7, 0), width: 6, height: 6),
      -1.2,
      2.4,
      false,
      Paint()..color = cafeColor..style = PaintingStyle.stroke..strokeWidth = 2,
    );
    // 김 (steam)
    canvas.drawLine(
      c + const Offset(-2, -7),
      c + const Offset(-2, -11),
      Paint()..color = cafeColor..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      c + const Offset(2, -7),
      c + const Offset(2, -12),
      Paint()..color = cafeColor..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(s.toInt(), h.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return _bytesToOverlayImage(byteData.buffer.asUint8List(), cacheKey: 'marker_cafe');
  }

  // ───── 내 위치 마커 ─────

  static NOverlayImage? _myLocationMarker;

  /// 내 위치 마커를 생성합니다 (눈에 잘 띄는 파란색 원 + 사람 아이콘).
  static Future<NOverlayImage?> getMyLocationMarker() async {
    if (_myLocationMarker != null) return _myLocationMarker!;
    _myLocationMarker = await _createMyLocationMarker();
    return _myLocationMarker;
  }

  static Future<NOverlayImage?> _createMyLocationMarker() async {
    const double size = 96; // 큰 사이즈로 눈에 잘 띄게
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const cx = size / 2;
    const cy = size / 2;

    // 1) 바깥 펄스 링 (반투명 하늘색)
    canvas.drawCircle(
      const Offset(cx, cy),
      42,
      Paint()
        ..color = const Color(0xFF2196F3).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    // 2) 중간 링 (반투명 파란색)
    canvas.drawCircle(
      const Offset(cx, cy),
      30,
      Paint()
        ..color = const Color(0xFF2196F3).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // 3) 그림자
    canvas.drawCircle(
      const Offset(cx + 1, cy + 1),
      18,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 4) 메인 파란 원
    canvas.drawCircle(
      const Offset(cx, cy),
      18,
      Paint()..color = const Color(0xFF1976D2),
    );

    // 5) 흰색 테두리
    canvas.drawCircle(
      const Offset(cx, cy),
      18,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // 6) 사람 아이콘 (머리 + 몸)
    final iconPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    // 머리
    canvas.drawCircle(const Offset(cx, cy - 5), 4.5, iconPaint);
    // 몸통
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(cx, cy + 5), width: 13, height: 10),
        const Radius.circular(4),
      ),
      iconPaint,
    );

    // 7) 방향 화살표 (상단 삼각형) — 현재 방향 표시
    final arrowPaint = Paint()..color = const Color(0xFF1976D2)..style = PaintingStyle.fill;
    final arrow = Path()
      ..moveTo(cx, cy - 40)
      ..lineTo(cx - 7, cy - 30)
      ..lineTo(cx + 7, cy - 30)
      ..close();
    canvas.drawPath(arrow, arrowPaint);
    // 화살표 흰색 테두리
    canvas.drawPath(
      arrow,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return _bytesToOverlayImage(byteData.buffer.asUint8List(), cacheKey: 'marker_my_location');
  }

  // ───── 클러스터 마커 ─────

  static final Map<int, NOverlayImage> _clusterCache = {};

  /// 클러스터 마커를 생성합니다 (숫자가 표시된 원형 마커).
  static Future<NOverlayImage?> getClusterMarker(int count) async {
    // 범위별로 캐시 (색상이 같으면 재사용)
    final cacheKey = count < 10 ? count : (count < 50 ? -1 : (count < 100 ? -2 : -3));
    if (_clusterCache.containsKey(cacheKey)) return _clusterCache[cacheKey]!;

    final marker = await _createClusterMarker(count);
    if (marker != null) {
      _clusterCache[cacheKey] = marker;
    }
    return marker;
  }

  static Future<NOverlayImage?> _createClusterMarker(int count) async {
    const double size = 56;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 클러스터 크기에 따라 색상 변경
    final color = count < 10
        ? const Color(0xFF6750A4) // 보라 (작은 클러스터)
        : count < 50
            ? const Color(0xFF1565C0) // 파랑
            : const Color(0xFFD32F2F); // 빨강 (큰 클러스터)

    final cx = size / 2;
    final cy = size / 2;
    final r = size / 2 - 2;

    // 그림자
    canvas.drawCircle(
      Offset(cx + 1, cy + 1),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 배경 원
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);

    // 안쪽 테두리
    canvas.drawCircle(
      Offset(cx, cy),
      r - 3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 숫자 텍스트
    final text = count > 99 ? '99+' : '$count';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return _bytesToOverlayImage(byteData.buffer.asUint8List(), cacheKey: 'marker_cluster_$count');
  }
}
