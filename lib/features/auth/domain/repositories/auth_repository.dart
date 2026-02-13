
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:holyroad/features/auth/domain/entities/user_entity.dart';
import 'package:holyroad/features/auth/data/repositories/real_auth_repository.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<void> signInWithGoogle();
  Future<void> signOut();
}



@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
AuthRepository authRepository(AuthRepositoryRef ref) {
  // Switch to RealAuthRepository when Firebase is configured
  return RealAuthRepository(); 
  // return MockAuthRepository(); 
}

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  MockAuthRepository() {
     // Initial state: Logged out
    _controller.add(null);
  }

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = const UserEntity(
      uid: 'mock_uid_123',
      email: 'believer@holyroad.com',
      displayName: '베드로',
      photoUrl: 'https://picsum.photos/seed/user/100',
      level: 3,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(null);
  }
}
