import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/ai_service.dart';

/// AI 신앙 상담 채팅 화면.
/// Gemini AI를 사용하여 신앙 관련 질문에 답변합니다.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  /// 채팅 메시지 이력
  final List<ChatMessage> _messages = [];

  /// AI 응답 스트리밍 중인지 여부
  bool _isStreaming = false;

  /// 현재 스트리밍 중인 AI 응답 텍스트
  String _streamingText = '';

  /// 스트림 구독
  StreamSubscription<String>? _streamSubscription;

  /// 추천 질문 목록
  static const _suggestedQuestions = [
    '기도하는 방법을 알려주세요',
    '힘든 시기에 위로가 되는 성경 구절은?',
    '성지순례의 의미는 무엇인가요?',
    '감사 기도를 드리고 싶어요',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 20),
            SizedBox(width: 8),
            Text('AI 신앙 상담'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearChat,
              tooltip: '대화 초기화',
            ),
        ],
      ),
      body: Column(
        children: [
          // 채팅 메시지 리스트
          Expanded(
            child: _messages.isEmpty && !_isStreaming
                ? _buildWelcomeView(context)
                : _buildChatList(context),
          ),

          // 입력 영역
          _buildInputArea(context, colorScheme),
        ],
      ),
    );
  }

  /// 환영 화면 (채팅 시작 전)
  Widget _buildWelcomeView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // AI 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            '안녕하세요!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '신앙에 대한 질문이나 고민을\n편하게 나눠주세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),

          // 추천 질문
          Text(
            '이런 질문을 해보세요',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedQuestions.map((question) {
              return ActionChip(
                label: Text(question),
                onPressed: () => _sendMessage(question),
                avatar: const Icon(Icons.chat_bubble_outline, size: 16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 채팅 메시지 리스트
  Widget _buildChatList(BuildContext context) {
    // 전체 아이템 수 = 메시지 수 + 스트리밍 응답 (있으면)
    final itemCount = _messages.length + (_isStreaming ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _messages.length) {
          return _buildMessageBubble(context, _messages[index]);
        } else {
          // 스트리밍 중인 AI 응답
          return _buildStreamingBubble(context);
        }
      },
    );
  }

  /// 메시지 버블
  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.role == 'user';
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI 아바타
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 메시지 내용
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      height: 1.5,
                    ),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// 스트리밍 중인 AI 응답 버블
  Widget _buildStreamingBubble(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _streamingText.isEmpty
                  ? _buildTypingIndicator(colorScheme)
                  : Text(
                      _streamingText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 타이핑 인디케이터
  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + index * 200),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3 + (value * 0.5),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  /// 입력 영역
  Widget _buildInputArea(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _onSend(),
              decoration: InputDecoration(
                hintText: '질문을 입력하세요...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 전송 버튼
          Container(
            decoration: BoxDecoration(
              color: _isStreaming
                  ? colorScheme.errorContainer
                  : colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isStreaming ? Icons.stop : Icons.send,
                color: _isStreaming
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimary,
              ),
              onPressed: _isStreaming ? _stopStreaming : _onSend,
            ),
          ),
        ],
      ),
    );
  }

  /// 전송 버튼 핸들러
  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isStreaming) return;
    _sendMessage(text);
  }

  /// 메시지 전송 및 AI 응답 스트리밍
  void _sendMessage(String text) {
    if (_isStreaming) return;

    _textController.clear();

    // 사용자 메시지 추가
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _isStreaming = true;
      _streamingText = '';
    });

    _scrollToBottom();

    // AI 응답 스트리밍
    final aiService = ref.read(aiServiceProvider);
    final buffer = StringBuffer();

    _streamSubscription = aiService.streamChat(_messages, text).listen(
      (chunk) {
        buffer.write(chunk);
        setState(() {
          _streamingText = buffer.toString();
        });
        _scrollToBottom();
      },
      onDone: () {
        final finalText = buffer.toString();
        setState(() {
          _messages.add(ChatMessage(role: 'model', content: finalText));
          _isStreaming = false;
          _streamingText = '';
        });
        _scrollToBottom();
      },
      onError: (error) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'model',
            content: '죄송합니다, 응답 중 오류가 발생했습니다. 다시 시도해 주세요.',
          ));
          _isStreaming = false;
          _streamingText = '';
        });
        _scrollToBottom();
      },
    );
  }

  /// 스트리밍 중지
  void _stopStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (_streamingText.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(role: 'model', content: _streamingText));
      });
    }

    setState(() {
      _isStreaming = false;
      _streamingText = '';
    });
  }

  /// 대화 초기화
  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 초기화'),
        content: const Text('모든 대화 내용이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _streamSubscription?.cancel();
              setState(() {
                _messages.clear();
                _isStreaming = false;
                _streamingText = '';
              });
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  /// 리스트를 맨 아래로 스크롤
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
