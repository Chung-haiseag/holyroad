
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holyroad/core/services/firestore_seed_service.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/auth/domain/repositories/auth_repository.dart';

class RealAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Google Cloud Console의 OAuth 2.0 Web Client ID
  /// Google Cloud Console의 OAuth 2.0 Web Client ID
  static const _googleWebClientId =
      '99007200987-h0kgh7qrgri6l8bk5046oufd2u4cosp3.apps.googleusercontent.com';

  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;
    if (kIsWeb) {
      await GoogleSignIn.instance.initialize(
        clientId: _googleWebClientId,
      );
    } else {
      // Android/iOS/macOS: serverClientId 필수
      await GoogleSignIn.instance.initialize(
        serverClientId: _googleWebClientId,
      );
    }
    _isGoogleSignInInitialized = true;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Pilgrim',
        photoUrl: user.photoURL ?? '',
      );
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // [WEB] Firebase Auth signInWithPopup 사용 (google_sign_in 패키지 미사용)
        // GIS 정책으로 인해 웹에서는 팝업 로그인이 표준입니다.
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // [MOBILE] GoogleSignIn 패키지 사용
        await _ensureGoogleSignInInitialized();
        
        final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = account.authentication;
        
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // 로그인 성공 후 처리
      await _onLoginSuccess(userCredential);

    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Login Failed: $e');
    }
  }

  Future<void> _onLoginSuccess(UserCredential userCredential) async {
    if (userCredential.user != null) {
      // 1. 사용자 프로필 자동 생성/업데이트
      await _ensureUserProfile(userCredential.user!);
      // 2. 성지 데이터 시드 (비어있으면 자동 삽입 - 인증 후 실행)
      try {
        await FirestoreSeedService().seedIfEmpty();
      } catch (_) {}
    }
  }

  /// Firestore users 컬렉션에 사용자 프로필이 없으면 생성, 있으면 기본 정보 업데이트
  Future<void> _ensureUserProfile(User user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // 신규 사용자: 프로필 생성
        await docRef.set({
          'email': user.email ?? '',
          'displayName': user.displayName ?? 'Pilgrim',
          'photoUrl': user.photoURL ?? '',
          'level': 1,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 기존 사용자: 마지막 로그인 시간 + 변경된 프로필 업데이트
        await docRef.update({
          'email': user.email ?? '',
          'displayName': user.displayName ?? 'Pilgrim',
          'photoUrl': user.photoURL ?? '',
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // 프로필 생성/업데이트 실패해도 로그인은 계속 진행
    }
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
