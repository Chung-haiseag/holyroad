/// 말씀 카드 등급
enum VerseRarity {
  normal('일반', '⭐', 0.60),
  rare('희귀', '⭐⭐', 0.25),
  epic('에픽', '⭐⭐⭐', 0.12),
  legendary('전설', '⭐⭐⭐⭐', 0.03);

  final String displayName;
  final String stars;
  final double probability;

  const VerseRarity(this.displayName, this.stars, this.probability);
}

/// 성경 말씀 데이터
class BibleVerse {
  final String id;
  final String book; // 성경 책 이름
  final int bookIndex; // 성경 순서 (1-66)
  final String chapter; // 장:절
  final String text; // 말씀 내용
  final VerseRarity rarity;

  const BibleVerse({
    required this.id,
    required this.book,
    required this.bookIndex,
    required this.chapter,
    required this.text,
    required this.rarity,
  });

  /// 전체 참조 표기 (예: "시편 23:1")
  String get reference => '$book $chapter';

  /// 구약/신약 구분
  bool get isOldTestament => bookIndex <= 39;
}
