import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holyroad/features/verse_gacha/data/bible_verse_data.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/bible_verse.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/collected_verse.dart';

/// 말씀 뽑기(가챠) 서비스.
class VerseGachaService {
  final FirebaseFirestore _firestore;
  final Random _random = Random();

  VerseGachaService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 등급 확률에 따라 말씀 카드를 뽑습니다.
  BibleVerse drawVerse() {
    // 1. 등급 결정 (확률: 일반60%, 희귀25%, 에픽12%, 전설3%)
    final roll = _random.nextDouble();
    VerseRarity selectedRarity;

    if (roll < 0.03) {
      selectedRarity = VerseRarity.legendary;
    } else if (roll < 0.15) {
      selectedRarity = VerseRarity.epic;
    } else if (roll < 0.40) {
      selectedRarity = VerseRarity.rare;
    } else {
      selectedRarity = VerseRarity.normal;
    }

    // 2. 해당 등급의 말씀 중 랜덤 선택
    final pool =
        allBibleVerses.where((v) => v.rarity == selectedRarity).toList();
    if (pool.isEmpty) return allBibleVerses.first;
    return pool[_random.nextInt(pool.length)];
  }

  /// 오늘 이미 뽑기를 했는지 확인합니다.
  Future<bool> hasDrawnToday(String userId) async {
    final todayKey = _todayKey();
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('verse_draws')
        .doc(todayKey)
        .get();
    return doc.exists;
  }

  /// 오늘의 뽑기 기록을 조회합니다.
  Stream<BibleVerse?> getTodayDraw(String userId) {
    final todayKey = _todayKey();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('verse_draws')
        .doc(todayKey)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final verseId = snap.data()!['verseId'] as String?;
      if (verseId == null) return null;
      try {
        return allBibleVerses.firstWhere((v) => v.id == verseId);
      } catch (_) {
        return null;
      }
    });
  }

  /// 뽑기 결과를 저장합니다.
  Future<void> saveDrawResult({
    required String userId,
    required BibleVerse verse,
  }) async {
    final todayKey = _todayKey();
    final batch = _firestore.batch();

    // 1. 오늘의 뽑기 기록 저장
    final drawRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('verse_draws')
        .doc(todayKey);
    batch.set(drawRef, {
      'verseId': verse.id,
      'rarity': verse.rarity.name,
      'drawnAt': DateTime.now().toIso8601String(),
    });

    // 2. 컬렉션에 추가 (중복 시 덮어쓰기)
    final collRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('verse_collection')
        .doc(verse.id);
    batch.set(
      collRef,
      CollectedVerse(
        verseId: verse.id,
        book: verse.book,
        bookIndex: verse.bookIndex,
        rarity: verse.rarity.name,
        collectedAt: DateTime.now(),
      ).toJson(),
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// 수집한 말씀 컬렉션을 조회합니다.
  Stream<List<CollectedVerse>> getCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('verse_collection')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => CollectedVerse.fromJson(doc.data()))
          .toList();
      // 클라이언트 사이드 정렬 (Firestore 인덱스 불필요)
      list.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
      return list;
    });
  }

  /// 66권 중 수집한 책 수를 계산합니다.
  int countCollectedBooks(List<CollectedVerse> collection) {
    return collection.map((c) => c.bookIndex).toSet().length;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
