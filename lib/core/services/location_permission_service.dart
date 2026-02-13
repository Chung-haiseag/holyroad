import 'package:geolocator/geolocator.dart';

/// 위치 권한 상태
enum LocationPermissionStatus {
  /// 권한 허용됨
  granted,

  /// 권한 거부됨 (다시 요청 가능)
  denied,

  /// 권한 영구 거부됨 (앱 설정에서만 변경 가능)
  deniedForever,

  /// 위치 서비스 비활성화됨
  serviceDisabled,
}

/// 위치 권한 확인 및 요청을 담당하는 유틸리티 클래스.
/// geolocator 내장 메서드를 사용하여 별도 패키지 없이 동작합니다.
class LocationPermissionService {
  /// 위치 권한을 확인하고 필요 시 요청합니다.
  ///
  /// 1. 위치 서비스 활성화 여부 확인
  /// 2. 현재 권한 상태 확인
  /// 3. 미허용 시 권한 요청
  static Future<LocationPermissionStatus> checkAndRequestPermission() async {
    // 1. 위치 서비스가 켜져 있는지 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // 2. 현재 권한 상태 확인
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // 3. 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    // whileInUse 또는 always
    return LocationPermissionStatus.granted;
  }

  /// 기기의 위치 서비스 설정 화면을 엽니다.
  /// (위치 서비스가 비활성화된 경우 사용)
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// 앱 설정 화면을 엽니다.
  /// (권한이 영구 거부된 경우 사용)
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
