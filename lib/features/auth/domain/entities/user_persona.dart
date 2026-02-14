import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_persona.freezed.dart';
part 'user_persona.g.dart';

/// 회원별 AI 맞춤 페르소나.
/// Firestore `users/{uid}` 문서에 merge 방식으로 저장됩니다.
@freezed
class UserPersona with _$UserPersona {
  const factory UserPersona({
    /// 호칭(성별): '형제' (남성) 또는 '자매' (여성)
    @Default('') String gender,

    /// 별명: 성경 인물이나 자유 입력 (예: '다윗', '에스더', '바울')
    /// AI가 "{별명} {호칭}님" 형태로 호칭합니다.
    @Default('') String nickname,

    /// 연령대: '10대', '20대', '30대', '40대', '50대', '60대 이상'
    @Default('') String ageGroup,

    /// 직분: '학생', '청년', '집사', '권사', '장로', '전도사', '목사'
    @Default('') String churchRole,

    /// 관심사항 (다중 선택): ['역사', '기도', '선교', '찬양', '성경공부', '묵상', '봉사', '성지순례']
    @Default([]) List<String> interests,
  }) = _UserPersona;

  factory UserPersona.fromJson(Map<String, dynamic> json) =>
      _$UserPersonaFromJson(json);
}
