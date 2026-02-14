import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 설정 상태
class AppSettingsState {
  final bool notificationsEnabled;
  final double geofenceRadiusKm;
  final int notificationIntervalMinutes;
  final ThemeMode themeMode;
  final bool aiAutoLoad;

  const AppSettingsState({
    this.notificationsEnabled = true,
    this.geofenceRadiusKm = 1.0,
    this.notificationIntervalMinutes = 60,
    this.themeMode = ThemeMode.system,
    this.aiAutoLoad = true,
  });

  AppSettingsState copyWith({
    bool? notificationsEnabled,
    double? geofenceRadiusKm,
    int? notificationIntervalMinutes,
    ThemeMode? themeMode,
    bool? aiAutoLoad,
  }) {
    return AppSettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      geofenceRadiusKm: geofenceRadiusKm ?? this.geofenceRadiusKm,
      notificationIntervalMinutes: notificationIntervalMinutes ?? this.notificationIntervalMinutes,
      themeMode: themeMode ?? this.themeMode,
      aiAutoLoad: aiAutoLoad ?? this.aiAutoLoad,
    );
  }

  /// 알림 반복 주기 표시 텍스트
  String get intervalDisplayText {
    if (notificationIntervalMinutes < 60) {
      return '$notificationIntervalMinutes분';
    } else {
      final hours = notificationIntervalMinutes ~/ 60;
      final mins = notificationIntervalMinutes % 60;
      return mins > 0 ? '$hours시간 $mins분' : '$hours시간';
    }
  }
}

/// 앱 설정을 관리하는 Notifier
class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(const AppSettingsState()) {
    _load();
  }

  static const _kNotifications = 'notifications_enabled';
  static const _kRadius = 'geofence_radius_km';
  static const _kInterval = 'notification_interval_minutes';
  static const _kTheme = 'theme_mode';
  static const _kAiAutoLoad = 'ai_auto_load';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettingsState(
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
      geofenceRadiusKm: prefs.getDouble(_kRadius) ?? 1.0,
      notificationIntervalMinutes: prefs.getInt(_kInterval) ?? 60,
      themeMode: ThemeMode.values[prefs.getInt(_kTheme) ?? 0],
      aiAutoLoad: prefs.getBool(_kAiAutoLoad) ?? true,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
  }

  Future<void> setGeofenceRadius(double km) async {
    state = state.copyWith(geofenceRadiusKm: km);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kRadius, km);
  }

  Future<void> setNotificationInterval(int minutes) async {
    state = state.copyWith(notificationIntervalMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kInterval, minutes);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTheme, mode.index);
  }

  Future<void> setAiAutoLoad(bool value) async {
    state = state.copyWith(aiAutoLoad: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAiAutoLoad, value);
  }
}

/// 설정 Provider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
  (ref) => AppSettingsNotifier(),
);
