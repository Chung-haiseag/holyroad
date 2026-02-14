
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:holyroad/core/services/ai_service.dart';
import 'package:holyroad/features/auth/domain/entities/user_persona.dart';

class GeminiAIService implements AIService {
  late final GenerativeModel _chatModel;
  late final GenerativeModel _guideModel;

  static const _systemPrompt = '''당신은 "Holy Road" 앱의 전문 신앙 상담사 '은혜샘'입니다.
20년 이상의 목회 상담 경험을 가진 따뜻하고 지혜로운 상담사로서 대화합니다.

## 역할과 성격
- 사용자의 호칭이 컨텍스트에 제공되면 그대로 사용하고, 없으면 "순례자님"으로 부르며 따뜻하게 대합니다
- 공감과 경청을 우선으로 하고, 판단하지 않습니다
- 성경 말씀을 자연스럽게 인용하며 (📖 표시와 함께), 실생활에 적용하도록 도와줍니다
- 한국 개신교 전통에 기반하되, 열린 마음으로 소통합니다

## 응답 스타일
- **구조적 응답**: 긴 답변 시 소제목(##)과 목록을 활용하여 가독성을 높입니다
- **성경 인용**: 관련 성경 구절을 1-3개 인용하며, 말씀 주소를 정확히 표기합니다
  예: 📖 "내가 세상 끝날까지 너희와 항상 함께 있으리라" (마태복음 28:20)
- **실천 제안**: 구체적이고 실행 가능한 신앙 실천 방법을 제안합니다
- **기도문**: 요청 시 상황에 맞는 기도문을 작성해 줍니다
- **따뜻한 마무리**: 격려와 축복의 말로 대화를 마무리합니다

## 상담 영역
1. **기도 상담**: 기도 방법, 기도문 작성, 중보기도
2. **성경 공부**: 성경 구절 해석, 묵상 안내, 말씀 적용
3. **고민 상담**: 인간관계, 직장, 가정, 건강 등 삶의 고민을 신앙으로 풀어감
4. **순례 안내**: 한국 개신교 성지의 역사와 영적 의미 설명
5. **신앙 성장**: 경건 생활, 예배, 봉사, 신앙 습관 형성

## 주의사항
- 항상 한국어로 답변합니다
- 의학적, 법적, 심리치료가 필요한 심각한 문제는 전문가 상담을 권합니다
- 답변은 충분히 깊이 있되, 읽기 부담스럽지 않게 적절한 길이로 합니다
- 이모지를 적절히 사용하여 따뜻한 분위기를 만듭니다 (🙏✝️📖💒🕊️)''';

  static const _guideSystemPrompt = '''당신은 "Holy Road" 앱의 성지순례 전문 도슨트 '순례 가이드'입니다.
20년 이상 한국 기독교 역사를 연구하고 성지순례를 안내해온 전문가로서,
마치 현장에 함께 서서 이야기하듯 생동감 있고 감동적으로 설명합니다.

## 핵심 원칙
- **이야기꾼**: 역사적 사실을 단순 나열하지 않고, 스토리텔링으로 생생하게 전달합니다
- **깊이 있는 해설**: 표면적 정보가 아닌, 그 뒤에 숨겨진 의미와 맥락을 전합니다
- **감성적 연결**: 순례자가 그 시대 인물들의 마음을 느끼도록 이끕니다
- **신앙적 적용**: 과거의 이야기를 오늘의 삶에 연결합니다

## 주제별 응답 가이드

### [역사] 주제일 때
1. 📅 **시대적 배경**: 당시 조선/한국의 시대 상황, 왜 이곳에서 이 일이 시작되었는지
2. ⛪ **설립/건립 이야기**: 누가, 어떤 동기로, 어떤 어려움을 겪으며 세웠는지 (구체적 에피소드)
3. 🔥 **주요 사건**: 이곳에서 일어난 역사적 사건들 (부흥회, 독립운동, 순교 등)
4. 🌊 **역사적 흐름**: 설립 이후 현재까지의 변천사
5. 📖 **관련 성경 말씀**: 이 장소의 역사와 연결되는 성경 구절 1-2개

### [인물] 주제일 때
1. 👤 **핵심 인물 소개**: 이 성지와 관련된 주요 인물 2-3명
2. 💡 **소명과 헌신**: 그들이 어떤 부르심을 받고 어떻게 응답했는지
3. 😢 **고난과 시련**: 겪었던 어려움과 박해 (구체적 에피소드)
4. ✨ **유산과 영향**: 그들의 헌신이 한국 기독교에 끼친 영향
5. 📖 **그들이 사랑한 말씀**: 그 인물들과 관련된 성경 구절

### [묵상] 주제일 때
1. 🙏 **묵상 안내**: 이 장소에서 묵상하면 좋을 주제
2. 📖 **말씀 묵상**: 관련 성경 구절 2-3개와 깊이 있는 해설
3. 🕊️ **기도 포인트**: 이 장소에서 드릴 기도 제목 3-5가지
4. ✝️ **신앙적 도전**: 순례를 통해 내 삶에 적용할 점
5. 🙏 **순례 기도문**: 이 성지에 맞는 짧은 기도문 작성

### [기도] 주제일 때
- 이 성지의 역사와 의미를 담은 감동적인 기도문을 작성합니다
- 기도문 구성: 감사 → 회개 → 결단 → 소원 → 축복
- 3-5분 분량으로 작성합니다

## 응답 스타일
- 500-800자 내외로 충분히 깊이 있되 지루하지 않게
- 마크다운 형식 사용: ## 소제목, **강조**, 번호 목록 활용
- 이모지를 적절히 사용 (⛪📖🙏✝️🕊️🔥💒)
- 마치 순례자 옆에서 이야기하듯 따뜻한 어조
- 항상 한국어로 답변합니다
- 역사적 사실에 기반하되, 확인되지 않은 정보는 "전해지기로는" 등으로 표현''';

  GeminiAIService(String apiKey) {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
    ];

    _chatModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
      safetySettings: safetySettings,
    );

    _guideModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_guideSystemPrompt),
      safetySettings: safetySettings,
    );
  }

  /// 별명 + 호칭을 조합한 호칭 문자열을 생성합니다.
  /// 예: "다윗 형제님", "에스더 자매님", "다윗님", "형제님"
  String _buildCallName(UserPersona persona) {
    final nickname = persona.nickname;
    final gender = persona.gender;
    if (nickname.isNotEmpty && gender.isNotEmpty) {
      return '$nickname ${gender}님';
    } else if (nickname.isNotEmpty) {
      return '${nickname}님';
    } else if (gender.isNotEmpty) {
      return '${gender}님';
    }
    return '';
  }

  /// 순례자 페르소나 컨텍스트를 프롬프트 문자열로 변환합니다.
  /// persona가 null이거나 비어있으면 빈 문자열을 반환합니다.
  String _buildPersonaContext(UserPersona? persona) {
    if (persona == null) return '';

    final parts = <String>[];

    // 호칭 생성: 별명 + 성별 조합
    final callName = _buildCallName(persona);
    if (callName.isNotEmpty) parts.add('호칭: $callName');

    if (persona.ageGroup.isNotEmpty) parts.add('나이: ${persona.ageGroup}');
    if (persona.churchRole.isNotEmpty) parts.add('직분: ${persona.churchRole}');
    if (persona.interests.isNotEmpty) {
      parts.add('관심사: ${persona.interests.join(", ")}');
    }
    if (parts.isEmpty) return '';

    return '''

[순례자 정보]
${parts.join("\n")}
위 순례자의 연령대와 직분에 맞는 눈높이로, 관심사에 맞춰 설명을 조절해 주세요.
반드시 호칭에 명시된 이름으로 불러주세요. 호칭 정보가 없으면 "순례자님"으로 불러주세요.
예: 청년에게는 친근하고 쉬운 표현, 장로/권사에게는 깊이 있는 신학적 해설을 제공합니다.''';
  }

  /// 주제별 상세 프롬프트 생성 (페르소나 컨텍스트 포함)
  String _buildGuidePrompt(String siteName, String topic, {UserPersona? persona}) {
    final personaContext = _buildPersonaContext(persona);

    switch (topic) {
      case '역사':
        return '''$siteName 성지의 역사에 대해 상세히 설명해 주세요.
다음 내용을 포함해 주세요:
- 이 장소가 세워진 시대적 배경과 당시 조선/한국의 상황
- 설립 과정에서의 구체적인 에피소드와 어려움
- 이곳에서 일어난 주요 역사적 사건들
- 설립 이후 현재까지의 변천사
- 관련 성경 구절 1-2개
마치 현장에서 순례자에게 이야기하듯 생동감 있게 설명해 주세요.$personaContext''';
      case '인물':
        return '''$siteName 성지와 관련된 주요 인물들에 대해 설명해 주세요.
다음 내용을 포함해 주세요:
- 이 성지의 핵심 인물 2-3명의 이야기
- 그들이 어떤 소명을 받고 어떻게 헌신했는지
- 겪었던 고난과 시련의 구체적 에피소드
- 그들의 헌신이 한국 기독교에 끼친 영향과 유산
- 그 인물들과 관련된 성경 구절
감동적인 스토리텔링으로 설명해 주세요.$personaContext''';
      case '묵상':
        return '''$siteName 성지에서의 묵상 가이드를 작성해 주세요.
다음 내용을 포함해 주세요:
- 이 장소에서 묵상하면 좋을 주제
- 관련 성경 구절 2-3개와 깊이 있는 해설
- 이 장소에서 드릴 기도 제목 3-5가지
- 순례를 통해 내 삶에 적용할 신앙적 도전
- 이 성지에 맞는 짧은 순례 기도문
순례자의 마음을 따뜻하게 이끌어 주세요.$personaContext''';
      case '기도':
        return '''$siteName 성지에서 드리기 좋은 기도문을 작성해 주세요.
이 성지의 역사적 의미와 신앙적 가치를 담아,
감사 → 회개 → 결단 → 소원 → 축복의 구조로
3-5분 분량의 감동적인 기도문을 작성해 주세요.
관련 성경 구절도 기도문에 자연스럽게 녹여 주세요.$personaContext''';
      default:
        return '$siteName의 $topic에 대해 상세히 설명해 주세요. 역사적 배경, 주요 인물, 신앙적 의미를 포함해 주세요.$personaContext';
    }
  }

  @override
  Future<String> generateGuide(String siteName, String topic, {UserPersona? persona}) async {
    try {
      final prompt = _buildGuidePrompt(siteName, topic, persona: persona);
      final response =
          await _guideModel.generateContent([Content.text(prompt)]);
      return response.text ?? '가이드를 생성할 수 없습니다.';
    } catch (e, stack) {
      print('[GeminiAI] generateGuide error: $e');
      print('[GeminiAI] stackTrace: $stack');
      return '가이드를 불러올 수 없습니다. 네트워크 연결을 확인해 주세요.';
    }
  }

  @override
  Stream<String> streamGuide(String siteName, String topic, {UserPersona? persona}) async* {
    try {
      final prompt = _buildGuidePrompt(siteName, topic, persona: persona);
      final response =
          _guideModel.generateContentStream([Content.text(prompt)]);
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e, stack) {
      print('[GeminiAI] streamGuide error: $e');
      print('[GeminiAI] stackTrace: $stack');
      yield '가이드를 불러올 수 없습니다. 네트워크 연결을 확인해 주세요.';
    }
  }

  @override
  Stream<String> streamChat(
      List<ChatMessage> history, String userMessage, {UserPersona? persona, String? activityContext}) async* {
    try {
      final contents = <Content>[];

      // 페르소나 + 활동 컨텍스트를 결합하여 첫 메시지로 삽입
      final personaContext = _buildPersonaContext(persona);
      final fullContext = StringBuffer();
      if (personaContext.isNotEmpty) fullContext.write(personaContext);
      if (activityContext != null && activityContext.isNotEmpty) {
        fullContext.write('\n\n$activityContext');
      }

      if (fullContext.isNotEmpty) {
        contents.add(Content.text('[컨텍스트] $fullContext'));
        contents.add(Content.model([TextPart('네, 순례자님의 정보와 활동 이력을 참고하여 맞춤 상담을 드리겠습니다.')]));
      }

      // 대화 이력 추가
      for (final msg in history) {
        if (msg.role == 'user') {
          contents.add(Content.text(msg.content));
        } else {
          contents.add(Content.model([TextPart(msg.content)]));
        }
      }

      // 새 사용자 메시지
      contents.add(Content.text(userMessage));

      final response = _chatModel.generateContentStream(contents);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e, stack) {
      print('[GeminiAI] streamChat error: $e');
      print('[GeminiAI] stackTrace: $stack');
      yield '죄송합니다. 응답을 생성할 수 없습니다. 잠시 후 다시 시도해 주세요.';
    }
  }
}
