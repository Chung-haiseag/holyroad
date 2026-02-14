import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 주변 장소(카페) 데이터
class NearbyPlace {
  final String name;
  final String address;
  final double rating;
  final int userRatingsTotal;
  final double lat;
  final double lng;
  final bool? isOpen;
  final String? photoReference;

  NearbyPlace({
    required this.name,
    required this.address,
    required this.rating,
    required this.userRatingsTotal,
    required this.lat,
    required this.lng,
    this.isOpen,
    this.photoReference,
  });
}

/// Google Places API Nearby Search를 사용하여 주변 카페를 검색하는 서비스.
class NearbyPlacesService {
  // DirectionsService와 동일한 API 키 사용
  static const String _apiKey = 'AIzaSyDJbe0TIkN7abN61Y8Q3c_YhlC1WqHpogw';

  /// 주어진 좌표 반경 내 카페를 검색합니다.
  /// [lat] 위도, [lng] 경도, [radius] 반경 (미터, 기본 500m)
  static Future<List<NearbyPlace>> searchNearbyCafes({
    required double lat,
    required double lng,
    int radius = 500,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$radius'
      '&type=cafe'
      '&language=ko'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('[NearbyPlaces] HTTP error: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        debugPrint('[NearbyPlaces] API status: $status');
        return [];
      }

      final results = data['results'] as List<dynamic>? ?? [];

      final places = results.map((item) {
        final place = item as Map<String, dynamic>;
        final geometry = place['geometry'] as Map<String, dynamic>?;
        final location = geometry?['location'] as Map<String, dynamic>?;
        final openingHours = place['opening_hours'] as Map<String, dynamic>?;
        final photos = place['photos'] as List<dynamic>?;

        return NearbyPlace(
          name: place['name'] as String? ?? '',
          address: place['vicinity'] as String? ?? '',
          rating: (place['rating'] as num?)?.toDouble() ?? 0.0,
          userRatingsTotal: place['user_ratings_total'] as int? ?? 0,
          lat: (location?['lat'] as num?)?.toDouble() ?? 0.0,
          lng: (location?['lng'] as num?)?.toDouble() ?? 0.0,
          isOpen: openingHours?['open_now'] as bool?,
          photoReference: photos != null && photos.isNotEmpty
              ? (photos[0] as Map<String, dynamic>)['photo_reference'] as String?
              : null,
        );
      }).toList();

      // 평점순 정렬 (높은 순)
      places.sort((a, b) => b.rating.compareTo(a.rating));

      debugPrint('[NearbyPlaces] ${places.length}개 카페 검색됨');
      return places;
    } catch (e) {
      debugPrint('[NearbyPlaces] 검색 오류: $e');
      return [];
    }
  }

  /// Places Photo API URL을 생성합니다.
  static String getPhotoUrl(String photoReference, {int maxWidth = 200}) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$_apiKey';
  }
}
