import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_service.g.dart';

/// 이미지 선택 및 Firebase Storage 업로드를 담당하는 서비스.
abstract class ImageUploadService {
  /// 카메라 또는 갤러리에서 이미지를 선택합니다.
  Future<XFile?> pickImage(ImageSource source);

  /// 선택한 이미지를 Firebase Storage에 업로드하고 다운로드 URL을 반환합니다.
  /// [storagePath]는 Storage 내 파일 경로 (예: 'visits/userId/timestamp.jpg')
  Future<String> uploadImage(XFile file, String storagePath);
}

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
ImageUploadService imageUploadService(ImageUploadServiceRef ref) {
  if (kIsWeb) return MockImageUploadService();
  return RealImageUploadService();
}

/// 실제 Firebase Storage 연동 이미지 업로드 서비스.
class RealImageUploadService implements ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85, // 적절한 품질로 압축
      );
      return image;
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
      return null;
    }
  }

  @override
  Future<String> uploadImage(XFile file, String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);

      // 파일 업로드
      final uploadTask = ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // 업로드 완료 대기
      final snapshot = await uploadTask;

      // 다운로드 URL 반환
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ImageUploadException('이미지 업로드에 실패했습니다: ${e.message}');
    } catch (e) {
      throw ImageUploadException('이미지 업로드 중 오류가 발생했습니다: $e');
    }
  }
}

/// 웹/테스트용 Mock 이미지 업로드 서비스.
class MockImageUploadService implements ImageUploadService {
  @override
  Future<XFile?> pickImage(ImageSource source) async {
    // Mock: null 반환 (웹에서는 실제 picker 미지원)
    return null;
  }

  @override
  Future<String> uploadImage(XFile file, String storagePath) async {
    // Mock: placeholder URL 반환
    await Future.delayed(const Duration(seconds: 1));
    return 'https://picsum.photos/seed/prayer/400/300';
  }
}

/// 이미지 업로드 관련 예외.
class ImageUploadException implements Exception {
  final String message;
  ImageUploadException(this.message);

  @override
  String toString() => 'ImageUploadException: $message';
}
