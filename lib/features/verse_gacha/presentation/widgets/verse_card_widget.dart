import 'package:flutter/material.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/bible_verse.dart';

/// 말씀 카드 위젯.
/// 등급별 스타일: 일반=흰색, 희귀=파랑, 에픽=보라, 전설=금색.
class VerseCardWidget extends StatelessWidget {
  final BibleVerse verse;
  final bool showFull;

  const VerseCardWidget({
    super.key,
    required this.verse,
    this.showFull = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getGradientColors(verse.rarity);

    return Container(
      margin: showFull
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 8)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(showFull ? 24 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 등급 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    verse.rarity.stars,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  verse.rarity.displayName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: showFull ? 20 : 12),
            // 성경 참조
            Text(
              verse.reference,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: showFull ? 16 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: showFull ? 16 : 8),
            // 말씀 내용
            Text(
              verse.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: showFull ? 18 : 14,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              maxLines: showFull ? null : 3,
              overflow: showFull ? null : TextOverflow.ellipsis,
            ),
            if (showFull) ...[
              const SizedBox(height: 20),
              // 구약/신약 표시
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  verse.isOldTestament ? '구약성경' : '신약성경',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(VerseRarity rarity) {
    switch (rarity) {
      case VerseRarity.normal:
        return [const Color(0xFF78909C), const Color(0xFF546E7A)];
      case VerseRarity.rare:
        return [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
      case VerseRarity.epic:
        return [const Color(0xFFAB47BC), const Color(0xFF6A1B9A)];
      case VerseRarity.legendary:
        return [const Color(0xFFFFD54F), const Color(0xFFFF8F00)];
    }
  }
}
