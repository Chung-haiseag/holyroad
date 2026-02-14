import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/features/verse_gacha/domain/providers/verse_gacha_providers.dart';
import 'package:holyroad/features/verse_gacha/presentation/widgets/verse_card_widget.dart';

/// 홈 화면용 오늘의 말씀 미니 카드 (또는 "뽑기" 버튼).
class TodayVerseCard extends ConsumerWidget {
  const TodayVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayDraw = ref.watch(todayDrawProvider);

    return todayDraw.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (verse) {
        if (verse != null) {
          // 이미 뽑은 경우: 미니 카드 표시
          return GestureDetector(
            onTap: () => context.push('/verse-gacha'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: VerseCardWidget(verse: verse, showFull: false),
            ),
          );
        }

        // 아직 뽑지 않은 경우: 뽑기 유도 카드
        return GestureDetector(
          onTap: () => context.push('/verse-gacha'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎲', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 말씀 카드',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '오늘의 말씀을 뽑아보세요!',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
