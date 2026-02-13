import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/pilgrimage/data/repositories/real_firestore_repository.dart';

part 'firestore_repository.g.dart';

abstract class FirestoreRepository {
  Stream<List<VisitEntity>> getRecentVisits();
  Future<void> addVisit(VisitEntity visit);

  /// 특정 사용자의 방문 기록을 조회합니다.
  Stream<List<VisitEntity>> getUserVisits(String userId);

  /// 방문(기도문) 기록을 삭제합니다.
  Future<void> deleteVisit(String visitId);
}



@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
FirestoreRepository firestoreRepository(FirestoreRepositoryRef ref) {
  // Switch to RealFirestoreRepository when Firebase is configured
  return RealFirestoreRepository();
  // return MockFirestoreRepository();
}

class MockFirestoreRepository implements FirestoreRepository {
  final _visits = <VisitEntity>[
    VisitEntity(
        id: '1',
        userId: 'u1',
        userDisplayName: '김마리아',
        userPhotoUrl: 'https://picsum.photos/seed/u1/100',
        siteId: 's1',
        siteName: '명동성당',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        prayerMessage: '주님, 오늘 명동성당에서 드린 기도가 하늘에 닿기를 바랍니다. 평화를 주소서.',
    ),
    VisitEntity(
        id: '2',
        userId: 'u2',
        userDisplayName: '이요한',
        userPhotoUrl: 'https://picsum.photos/seed/u2/100',
        siteId: 's3',
        siteName: '양화진',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        prayerMessage: '선교사님들의 숭고한 희생을 묵상합니다.',
    ),
  ];

  @override
  Stream<List<VisitEntity>> getRecentVisits() {
    return Stream.value(_visits);
  }

  @override
  Future<void> addVisit(VisitEntity visit) async {
    _visits.insert(0, visit);
  }

  @override
  Stream<List<VisitEntity>> getUserVisits(String userId) {
    return Stream.value(
      _visits.where((v) => v.userId == userId).toList(),
    );
  }

  @override
  Future<void> deleteVisit(String visitId) async {
    _visits.removeWhere((v) => v.id == visitId);
  }
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Stream<List<VisitEntity>> recentVisits(RecentVisitsRef ref) {
  return ref.watch(firestoreRepositoryProvider).getRecentVisits();
}
