import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/bible_verse.dart';
import 'package:holyroad/features/verse_gacha/domain/providers/verse_gacha_providers.dart';
import 'package:holyroad/features/verse_gacha/presentation/widgets/gacha_animation_widget.dart';
import 'package:holyroad/features/verse_gacha/presentation/widgets/verse_card_widget.dart';

/// 말씀 뽑기 메인 화면.
class VerseGachaScreen extends ConsumerStatefulWidget {
  const VerseGachaScreen({super.key});

  @override
  ConsumerState<VerseGachaScreen> createState() => _VerseGachaScreenState();
}

class _VerseGachaScreenState extends ConsumerState<VerseGachaScreen> {
  BibleVerse? _drawnVerse;
  bool _isDrawing = false;
  bool _animationComplete = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayDraw = ref.watch(todayDrawProvider).valueOrNull;
    final collectedBooks = ref.watch(collectedBooksCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 말씀'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/verse-collection'),
            icon: const Icon(Icons.collections_bookmark, size: 18),
            label: Text('$collectedBooks/66'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 헤더
              Text(
                '🎲 말씀 카드 뽑기',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '매일 1회 뽑을 수 있어요\n66권 수집에 도전해보세요!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 뽑기 결과 표시
              if (_isDrawing && _drawnVerse != null)
                // 애니메이션 진행 중
                GachaAnimationWidget(
                  verse: _drawnVerse!,
                  onAnimationComplete: () {
                    setState(() => _animationComplete = true);
                  },
                )
              else if (todayDraw != null)
                // 오늘 이미 뽑은 경우
                Column(
                  children: [
                    VerseCardWidget(verse: todayDraw, showFull: true),
                    const SizedBox(height: 16),
                    Text(
                      '오늘의 말씀을 받았습니다 ✨',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                // 아직 뽑지 않은 경우 - 뽑기 버튼
                Column(
                  children: [
                    Container(
                      width: 200,
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF37474F), Color(0xFF263238)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 56,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '?',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _onDraw,
                      icon: const Icon(Icons.style),
                      label: const Text('말씀 뽑기'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
              // 등급 안내
              if (!_isDrawing && todayDraw == null)
                _buildRarityGuide(theme),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onDraw() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
      }
      return;
    }

    try {
      final service = ref.read(verseGachaServiceProvider);

      // 중복 뽑기 방지
      final hasDrawn = await service.hasDrawnToday(user.uid);
      if (hasDrawn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('오늘은 이미 뽑았습니다! 내일 다시 도전해주세요')),
          );
        }
        return;
      }

      // 뽑기 실행
      final verse = service.drawVerse();
      debugPrint('[VerseGacha] 뽑기 결과: ${verse.reference} (${verse.rarity.name})');

      setState(() {
        _drawnVerse = verse;
        _isDrawing = true;
      });

      // Firestore에 저장
      await service.saveDrawResult(userId: user.uid, verse: verse);
      debugPrint('[VerseGacha] Firestore 저장 완료');
    } catch (e, stack) {
      debugPrint('[VerseGacha] 뽑기 오류: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Widget _buildRarityGuide(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '등급별 확률',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRarityItem('⭐', '일반', '60%', const Color(0xFF78909C)),
              _buildRarityItem('⭐⭐', '희귀', '25%', const Color(0xFF42A5F5)),
              _buildRarityItem('⭐⭐⭐', '에픽', '12%', const Color(0xFFAB47BC)),
              _buildRarityItem('⭐⭐⭐⭐', '전설', '3%', const Color(0xFFFFD54F)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRarityItem(
      String stars, String name, String rate, Color color) {
    return Column(
      children: [
        Text(stars, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 2),
        Text(name, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        Text(rate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
