import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API Key - .env의 GOOGLE_MAPS_API_KEY를 여기에 설정하세요
    GMSServices.provideAPIKey("AIzaSyDJbe0TIkN7abN61Y8Q3c_YhlC1WqHpogw")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
