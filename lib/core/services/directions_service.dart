import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;

/// Naver Directions 5 API를 사용하여 경로 데이터를 가져오는 서비스.
class DirectionsService {
  // NCP Maps Application 인증키
  static const String _apiKeyId = 'wncoedbyc5';
  static const String _apiKey = 'p7vxkHNPrS2OgCoKkLtsVcKLySXk2WxqDC3mM3CJ';

  /// 출발지 → 목적지 경로 (자동차) 를 반환합니다.
  /// Naver Directions 5 API는 자동차 경로만 지원합니다.
  static Future<DirectionsResult> getRoute({
    required NLatLng origin,
    required NLatLng destination,
  }) async {
    try {
      // Naver API는 경도,위도 순서 (Google과 반대)
      final url = Uri.parse(
        'https://maps.apigw.ntruss.com/map-direction/v1/driving'
        '?start=${origin.longitude},${origin.latitude}'
        '&goal=${destination.longitude},${destination.latitude}'
        '&option=traoptimal',
      );

      final response = await http.get(url, headers: {
        'X-NCP-APIGW-API-KEY-ID': _apiKeyId,
        'X-NCP-APIGW-API-KEY': _apiKey,
      });

      if (response.statusCode != 200) {
        debugPrint('Naver Directions API HTTP error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return DirectionsResult.empty();
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['code'] as int?;

      if (code != 0) {
        debugPrint('Naver Directions API error code: $code, message: ${data['message']}');
        return DirectionsResult.empty();
      }

      final route = data['route'] as Map<String, dynamic>?;
      if (route == null) return DirectionsResult.empty();

      final traoptimal = route['traoptimal'] as List<dynamic>?;
      if (traoptimal == null || traoptimal.isEmpty) return DirectionsResult.empty();

      final bestRoute = traoptimal[0] as Map<String, dynamic>;
      final summary = bestRoute['summary'] as Map<String, dynamic>;
      final path = bestRoute['path'] as List<dynamic>;

      // [lng, lat] 배열을 NLatLng 리스트로 변환
      final coords = path.map((p) {
        final point = p as List<dynamic>;
        return NLatLng(
          (point[1] as num).toDouble(),  // latitude
          (point[0] as num).toDouble(),  // longitude
        );
      }).toList();

      // 거리 (미터 → 읽기 쉬운 포맷)
      final distanceM = summary['distance'] as int? ?? 0;
      final distance = distanceM >= 1000
          ? '${(distanceM / 1000).toStringAsFixed(1)} km'
          : '$distanceM m';

      // 소요시간 (밀리초 → 분/시간)
      final durationMs = summary['duration'] as int? ?? 0;
      final duration = _formatDuration(durationMs);

      // bounds 계산
      final bbox = summary['bbox'] as List<dynamic>?;
      NLatLngBounds? bounds;
      if (bbox != null && bbox.length == 2) {
        final min = bbox[0] as List<dynamic>;
        final max = bbox[1] as List<dynamic>;
        bounds = NLatLngBounds(
          southWest: NLatLng(
            (min[1] as num).toDouble(),
            (min[0] as num).toDouble(),
          ),
          northEast: NLatLng(
            (max[1] as num).toDouble(),
            (max[0] as num).toDouble(),
          ),
        );
      }

      return DirectionsResult(
        polylineCoordinates: coords,
        distance: distance,
        duration: duration,
        travelMode: '자동차',
        bounds: bounds,
      );
    } catch (e) {
      debugPrint('Naver Directions API error: $e');
      return DirectionsResult.empty();
    }
  }

  /// 밀리초를 읽기 쉬운 시간 문자열로 변환
  static String _formatDuration(int ms) {
    final minutes = (ms / 60000).round();
    if (minutes < 60) return '$minutes분';
    final hours = minutes ~/ 60;
    final remainMin = minutes % 60;
    if (remainMin == 0) return '$hours시간';
    return '$hours시간 $remainMin분';
  }
}

/// 경로 결과 데이터
class DirectionsResult {
  final List<NLatLng> polylineCoordinates;
  final String distance;
  final String duration;
  final String travelMode;
  final NLatLngBounds? bounds;

  DirectionsResult({
    required this.polylineCoordinates,
    required this.distance,
    required this.duration,
    this.travelMode = '',
    this.bounds,
  });

  factory DirectionsResult.empty() => DirectionsResult(
        polylineCoordinates: [],
        distance: '',
        duration: '',
      );

  bool get isEmpty => polylineCoordinates.isEmpty;
  bool get isNotEmpty => polylineCoordinates.isNotEmpty;
}
