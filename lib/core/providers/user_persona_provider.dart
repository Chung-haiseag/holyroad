import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holyroad/features/auth/domain/entities/user_persona.dart';

/// 현재 로그인된 사용자의 페르소나를 실시간으로 감시하는 Provider.
/// 로그인 안 된 경우 null을 반환합니다.
final userPersonaProvider = StreamProvider<UserPersona?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    if (data == null) return null;

    // 페르소나 필드가 하나라도 있으면 파싱, 없으면 null
    if (data.containsKey('ageGroup') ||
        data.containsKey('churchRole') ||
        data.containsKey('interests')) {
      return UserPersona(
        ageGroup: (data['ageGroup'] as String?) ?? '',
        churchRole: (data['churchRole'] as String?) ?? '',
        interests: (data['interests'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    }
    return null;
  });
});

/// 사용자 페르소나를 Firestore에 저장합니다.
/// 기존 사용자 문서 필드(email, displayName 등)를 덮어쓰지 않도록 merge 합니다.
Future<void> saveUserPersona(String uid, UserPersona persona) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set(
    persona.toJson(),
    SetOptions(merge: true),
  );
}
