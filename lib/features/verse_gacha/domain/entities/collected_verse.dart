import 'package:holyroad/features/verse_gacha/domain/entities/bible_verse.dart';

/// 수집된 말씀 카드 (Firestore 저장용)
class CollectedVerse {
  final String verseId;
  final String book;
  final int bookIndex;
  final String rarity;
  final DateTime collectedAt;

  const CollectedVerse({
    required this.verseId,
    required this.book,
    required this.bookIndex,
    required this.rarity,
    required this.collectedAt,
  });

  Map<String, dynamic> toJson() => {
        'verseId': verseId,
        'book': book,
        'bookIndex': bookIndex,
        'rarity': rarity,
        'collectedAt': collectedAt.toIso8601String(),
      };

  factory CollectedVerse.fromJson(Map<String, dynamic> json) {
    return CollectedVerse(
      verseId: json['verseId'] as String,
      book: json['book'] as String,
      bookIndex: json['bookIndex'] as int,
      rarity: json['rarity'] as String,
      collectedAt: DateTime.parse(json['collectedAt'] as String),
    );
  }

  VerseRarity get verseRarity {
    return VerseRarity.values.firstWhere(
      (r) => r.name == rarity,
      orElse: () => VerseRarity.normal,
    );
  }
}
