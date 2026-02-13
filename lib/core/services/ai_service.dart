
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:holyroad/core/services/gemini_ai_service.dart';



part 'ai_service.g.dart';

abstract class AIService {
  Future<String> generateGuide(String siteName, String topic);
  Stream<String> streamGuide(String siteName, String topic);

  /// 신앙 상담 채팅: 대화 이력을 포함한 스트리밍 응답
  Stream<String> streamChat(List<ChatMessage> history, String userMessage);
}

/// 채팅 메시지 모델
class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}



@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
AIService aiService(AiServiceRef ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  if (apiKey != null && apiKey.isNotEmpty && apiKey != 'YOUR_KEY_HERE') {
    return GeminiAIService(apiKey);
  }
  return MockAIService();
}

class MockAIService implements AIService {
  @override
  Future<String> generateGuide(String siteName, String topic) async {
    await Future.delayed(const Duration(seconds: 2));
    return "$siteName에 대한 $topic 가이드입니다. 이곳의 역사는 깊고 의미가 있습니다...";
  }

  @override
  Stream<String> streamGuide(String siteName, String topic) async* {
    final text = "$siteName의 $topic에 대해 설명해 드리겠습니다. 이곳은 순교자들의 피와 땀이 서려있는 거룩한 장소입니다. 잠시 묵상하며 걸어보세요...";
    for (var i = 0; i < text.length; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        yield text.substring(0, i + 1);
    }
  }

  @override
  Stream<String> streamChat(List<ChatMessage> history, String userMessage) async* {
    await Future.delayed(const Duration(milliseconds: 500));

    final responses = [
      '좋은 질문이시네요. 하나님은 우리 삶의 모든 순간에 함께하십니다. 어려운 시기에도 그분의 사랑은 변함이 없습니다. 기도하며 묵상하는 시간을 가져보시는 것을 추천드립니다.',
      '그 마음을 이해합니다. 신앙의 여정에서 의문이 드는 것은 자연스러운 일입니다. 성경 말씀을 통해 위로를 받으시길 바랍니다. "두려워하지 말라 내가 너와 함께 함이라" (이사야 41:10)',
      '감사합니다. 순례의 여정을 통해 많은 것을 느끼셨군요. 성지를 방문하며 느낀 감동을 일상에서도 간직하시길 바랍니다. 매일의 기도가 큰 힘이 될 것입니다.',
    ];

    final text = responses[history.length % responses.length];
    for (var i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield text.substring(0, i + 1);
    }
  }
}
