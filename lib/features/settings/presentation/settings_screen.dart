import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/settings_service.dart';

/// 앱 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── 알림 설정 ──
          _buildSectionHeader(context, '알림 설정'),
          SwitchListTile(
            title: const Text('근접 알림'),
            subtitle: const Text('성지 근처에 갔을 때 알림을 받습니다'),
            secondary: Icon(Icons.notifications, color: colorScheme.primary),
            value: settings.notificationsEnabled,
            onChanged: (value) => notifier.setNotificationsEnabled(value),
          ),
          ListTile(
            leading: Icon(Icons.radar, color: colorScheme.primary),
            title: const Text('알림 반경'),
            subtitle: Text('${settings.geofenceRadiusKm.toStringAsFixed(1)} km'),
            trailing: SizedBox(
              width: 180,
              child: Slider(
                value: settings.geofenceRadiusKm,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                label: '${settings.geofenceRadiusKm.toStringAsFixed(1)} km',
                onChanged: settings.notificationsEnabled
                    ? (value) => notifier.setGeofenceRadius(value)
                    : null,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.timer, color: colorScheme.primary),
            title: const Text('알림 반복 주기'),
            subtitle: Text(
              '근처에 머무를 때 ${settings.intervalDisplayText}마다 알림',
            ),
            trailing: SizedBox(
              width: 180,
              child: Slider(
                value: settings.notificationIntervalMinutes.toDouble(),
                min: 30,
                max: 180,
                divisions: 5,
                label: settings.intervalDisplayText,
                onChanged: settings.notificationsEnabled
                    ? (value) => notifier.setNotificationInterval(value.toInt())
                    : null,
              ),
            ),
          ),
          const Divider(),

          // ── 화면 설정 ──
          _buildSectionHeader(context, '화면 설정'),
          ListTile(
            leading: Icon(Icons.palette, color: colorScheme.primary),
            title: const Text('테마'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_brightness, size: 18),
                  label: Text('자동', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode, size: 18),
                  label: Text('라이트', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode, size: 18),
                  label: Text('다크', style: TextStyle(fontSize: 11)),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selected) {
                notifier.setThemeMode(selected.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const Divider(),

          // ── AI 가이드 ──
          _buildSectionHeader(context, 'AI 가이드'),
          SwitchListTile(
            title: const Text('자동 로드'),
            subtitle: const Text('순례 화면 진입 시 자동으로 AI 가이드를 로드합니다'),
            secondary: Icon(Icons.auto_awesome, color: colorScheme.primary),
            value: settings.aiAutoLoad,
            onChanged: (value) => notifier.setAiAutoLoad(value),
          ),
          const Divider(),

          // ── 정보 ──
          _buildSectionHeader(context, '정보'),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.primary),
            title: const Text('앱 버전'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: colorScheme.primary),
            title: const Text('오픈소스 라이선스'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Holy Road',
              applicationVersion: '1.0.0',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
