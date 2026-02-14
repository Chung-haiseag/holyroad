import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/bible_verse.dart';
import 'package:holyroad/features/verse_gacha/domain/entities/collected_verse.dart';
import 'package:holyroad/features/verse_gacha/domain/services/verse_gacha_service.dart';

/// 뽑기 서비스 인스턴스
final verseGachaServiceProvider = Provider<VerseGachaService>((ref) {
  return VerseGachaService();
});

/// 오늘 뽑은 말씀 (실시간 스트림)
final todayDrawProvider = StreamProvider<BibleVerse?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  final service = ref.watch(verseGachaServiceProvider);
  return service.getTodayDraw(user.uid);
});

/// 수집한 말씀 컬렉션 (실시간 스트림)
final verseCollectionProvider = StreamProvider<List<CollectedVerse>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final service = ref.watch(verseGachaServiceProvider);
  return service.getCollection(user.uid);
});

/// 수집한 책 수
final collectedBooksCountProvider = Provider<int>((ref) {
  final collection = ref.watch(verseCollectionProvider).valueOrNull ?? [];
  final service = ref.watch(verseGachaServiceProvider);
  return service.countCollectedBooks(collection);
});
