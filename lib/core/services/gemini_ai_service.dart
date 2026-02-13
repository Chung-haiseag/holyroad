
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:holyroad/core/services/ai_service.dart';

class GeminiAIService implements AIService {
  late final GenerativeModel _chatModel;
  late final GenerativeModel _guideModel;

  static const _systemPrompt = '''당신은 "Holy Road" 앱의 신앙 상담사입니다.
사용자의 신앙 관련 질문에 따뜻하고 지혜롭게 답변해 주세요.
성경 말씀을 적절히 인용하고, 한국 개신교 성지순례와 관련된 조언도 해주세요.
항상 한국어로 답변하며, 공감과 위로를 담아 대화해 주세요.
답변은 3-5문장 정도로 간결하게 해주세요.''';

  static const _guideSystemPrompt = '''당신은 한국 개신교 성지순례 가이드입니다.
성지의 역사적, 신앙적 의미를 따뜻하고 감동적으로 설명해 주세요.
한국어로 3문장 정도로 간결하게 설명해 주세요.''';

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

  @override
  Future<String> generateGuide(String siteName, String topic) async {
    try {
      final prompt = '$siteName의 $topic에 대해 설명해 주세요.';
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
  Stream<String> streamGuide(String siteName, String topic) async* {
    try {
      final prompt = '$siteName의 $topic에 대해 설명해 주세요.';
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
      List<ChatMessage> history, String userMessage) async* {
    try {
      final contents = <Content>[];

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
