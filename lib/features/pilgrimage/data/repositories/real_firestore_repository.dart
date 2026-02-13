
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';

class RealFirestoreRepository implements FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<VisitEntity>> getRecentVisits() {
    return _firestore
        .collection('visits')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return VisitEntity(
          id: doc.id,
          userId: data['userId'] as String,
          userDisplayName: data['userDisplayName'] as String,
          userPhotoUrl: data['userPhotoUrl'] as String,
          siteId: data['siteId'] as String,
          siteName: data['siteName'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          prayerMessage: data['prayerMessage'] as String? ?? '',
          photoUrl: data['photoUrl'] as String? ?? '',
        );
      }).toList();
    });
  }

  @override
  Future<void> addVisit(VisitEntity visit) async {
    await _firestore.collection('visits').add({
      'userId': visit.userId,
      'userDisplayName': visit.userDisplayName,
      'userPhotoUrl': visit.userPhotoUrl,
      'siteId': visit.siteId,
      'siteName': visit.siteName,
      'timestamp': Timestamp.fromDate(visit.timestamp),
      'prayerMessage': visit.prayerMessage,
      'photoUrl': visit.photoUrl,
      'moderationStatus': 'pending',
    });
  }

  @override
  Stream<List<VisitEntity>> getUserVisits(String userId) {
    return _firestore
        .collection('visits')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return VisitEntity(
          id: doc.id,
          userId: data['userId'] as String,
          userDisplayName: data['userDisplayName'] as String,
          userPhotoUrl: data['userPhotoUrl'] as String,
          siteId: data['siteId'] as String,
          siteName: data['siteName'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          prayerMessage: data['prayerMessage'] as String? ?? '',
          photoUrl: data['photoUrl'] as String? ?? '',
        );
      }).toList();
    });
  }

  @override
  Future<void> deleteVisit(String visitId) async {
    await _firestore.collection('visits').doc(visitId).delete();
  }
}
