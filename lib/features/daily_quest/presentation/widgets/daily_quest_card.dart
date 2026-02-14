import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/daily_quest/domain/providers/daily_quest_providers.dart';

/// 홈 화면에 표시되는 일일 미션 카드.
class DailyQuestCard extends ConsumerWidget {
  const DailyQuestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mission = ref.watch(todayMissionProvider);
    final streakAsync = ref.watch(missionStreakProvider);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: mission.isCompleted
              ? [
                  const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  const Color(0xFF81C784).withValues(alpha: 0.1),
                ]
              : [
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.isCompleted
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: mission.isCompleted
              ? null
              : () => _onMissionTap(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 미션 이모지
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: mission.isCompleted
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    mission.isCompleted ? '✅' : mission.type.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                // 미션 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '오늘의 미션',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // 스트릭 표시
                          streakAsync.when(
                            data: (streak) {
                              if (streak <= 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF44336)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '🔥 $streak일 연속',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFF44336),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mission.type.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: mission.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: mission.isCompleted
                              ? theme.colorScheme.outline
                              : null,
                        ),
                      ),
                      if (!mission.isCompleted) ...[
                        const SizedBox(height: 2),
                        Text(
                          mission.type.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // 완료 버튼 또는 체크
                if (mission.isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 28,
                  )
                else if (!mission.type.isAutoDetectable)
                  FilledButton.tonal(
                    onPressed: () => _onSelfComplete(context, ref),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('완료'),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMissionTap(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${ref.read(todayMissionProvider).type.title} - 해당 활동을 수행하면 자동으로 완료됩니다!',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSelfComplete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('미션 완료'),
        content: Text(
          '${ref.read(todayMissionProvider).type.title}\n\n정말 완료하셨나요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('아니요'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final mission = ref.read(todayMissionProvider);
              final service = ref.read(missionCompletionServiceProvider);
              await service.selfComplete(
                userId: user.uid,
                missionType: mission.type,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 미션 완료! 수고하셨습니다'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('완료했어요'),
          ),
        ],
      ),
    );
  }
}
