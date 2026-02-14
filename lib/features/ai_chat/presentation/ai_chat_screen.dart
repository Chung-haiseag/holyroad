import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/services/ai_service.dart';
import 'package:holyroad/core/providers/user_persona_provider.dart';
import 'package:holyroad/features/pilgrimage/domain/entities/visit_entity.dart';
import 'package:holyroad/features/pilgrimage/domain/repositories/firestore_repository.dart';

/// 상담 카테고리 정의
enum CounselCategory {
  all('전체', Icons.auto_awesome, null),
  prayer('기도', Icons.volunteer_activism, Color(0xFF6A1B9A)),
  bible('성경', Icons.menu_book, Color(0xFF1565C0)),
  counsel('고민상담', Icons.favorite, Color(0xFFD32F2F)),
  pilgrimage('순례', Icons.church, Color(0xFF2E7D32)),
  growth('신앙성장', Icons.trending_up, Color(0xFFE65100));

  final String label;
  final IconData icon;
  final Color? color;
  const CounselCategory(this.label, this.icon, this.color);
}

/// 추천 질문 데이터
class SuggestedQuestion {
  final String question;
  final CounselCategory category;
  final IconData icon;

  const SuggestedQuestion(this.question, this.category, this.icon);
}

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

  /// 현재 선택된 카테고리 (환영 화면용)
  CounselCategory _selectedCategory = CounselCategory.all;

  /// 순례 활동 컨텍스트 (Gemini에 전달)
  String _activityContext = '';

  /// 순례 활동 요약 (환영 화면 표시용)
  String _activitySummary = '';

  /// 추천 질문 목록
  static const List<SuggestedQuestion> _allQuestions = [
    // 기도
    SuggestedQuestion('기도하는 방법을 알려주세요', CounselCategory.prayer, Icons.volunteer_activism),
    SuggestedQuestion('아침 기도문을 작성해 주세요', CounselCategory.prayer, Icons.wb_sunny),
    SuggestedQuestion('감사 기도를 드리고 싶어요', CounselCategory.prayer, Icons.favorite_border),
    SuggestedQuestion('중보기도는 어떻게 하나요?', CounselCategory.prayer, Icons.people),
    SuggestedQuestion('기도 응답이 없을 때 어떻게 해야 하나요?', CounselCategory.prayer, Icons.hourglass_empty),

    // 성경
    SuggestedQuestion('힘든 시기에 위로가 되는 성경 구절은?', CounselCategory.bible, Icons.auto_stories),
    SuggestedQuestion('오늘의 말씀 묵상을 도와주세요', CounselCategory.bible, Icons.light_mode),
    SuggestedQuestion('요한복음 3장 16절을 해석해 주세요', CounselCategory.bible, Icons.search),
    SuggestedQuestion('시편 23편의 의미를 알려주세요', CounselCategory.bible, Icons.grass),
    SuggestedQuestion('성경 통독 계획을 세워주세요', CounselCategory.bible, Icons.calendar_month),

    // 고민상담
    SuggestedQuestion('직장에서 어려움을 겪고 있어요', CounselCategory.counsel, Icons.work),
    SuggestedQuestion('가족 관계가 힘들어요', CounselCategory.counsel, Icons.family_restroom),
    SuggestedQuestion('외로움과 우울함을 느껴요', CounselCategory.counsel, Icons.sentiment_dissatisfied),
    SuggestedQuestion('용서가 어려운 사람이 있어요', CounselCategory.counsel, Icons.healing),
    SuggestedQuestion('미래가 불안해요', CounselCategory.counsel, Icons.psychology),

    // 순례
    SuggestedQuestion('성지순례의 의미는 무엇인가요?', CounselCategory.pilgrimage, Icons.church),
    SuggestedQuestion('양화진 선교사 묘원의 역사를 알려주세요', CounselCategory.pilgrimage, Icons.place),
    SuggestedQuestion('정동제일교회의 의미는?', CounselCategory.pilgrimage, Icons.account_balance),
    SuggestedQuestion('한국 기독교 역사의 중요 사건들은?', CounselCategory.pilgrimage, Icons.history),

    // 신앙성장
    SuggestedQuestion('매일 경건의 시간을 갖고 싶어요', CounselCategory.growth, Icons.schedule),
    SuggestedQuestion('교회 봉사를 시작하고 싶어요', CounselCategory.growth, Icons.handshake),
    SuggestedQuestion('신앙이 식어진 것 같아요', CounselCategory.growth, Icons.local_fire_department),
    SuggestedQuestion('성경 읽기를 습관으로 만들고 싶어요', CounselCategory.growth, Icons.auto_stories),
  ];

  @override
  void initState() {
    super.initState();
    _loadActivityContext();
  }

  /// 사용자의 순례 활동 데이터를 로드하여 AI 컨텍스트를 생성합니다.
  Future<void> _loadActivityContext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final repo = ref.read(firestoreRepositoryProvider);
      final visits = await repo.getUserVisits(user.uid).first;
      if (visits.isEmpty) return;

      final totalVisits = visits.length;
      final totalPhotos = visits.where((v) => v.photoUrl.isNotEmpty).length;
      final uniqueSites = visits.map((v) => v.siteId).toSet().length;
      final totalPrayers = visits.where((v) => v.prayerMessage.isNotEmpty).length;

      // 최근 방문 성지 목록 (최근 5곳)
      final recentSites = <String>[];
      final seenSites = <String>{};
      for (final v in visits) {
        if (!seenSites.contains(v.siteName)) {
          recentSites.add(v.siteName);
          seenSites.add(v.siteName);
        }
        if (recentSites.length >= 5) break;
      }

      // 마지막 방문일
      final lastVisit = visits.first;
      final daysSinceLastVisit = DateTime.now().difference(lastVisit.timestamp).inDays;

      final context = StringBuffer();
      context.writeln('[순례 활동 이력]');
      context.writeln('총 순례 횟수: $totalVisits회');
      context.writeln('방문 성지 수: $uniqueSites곳');
      context.writeln('기도문 수: $totalPrayers개');
      context.writeln('인증샷 수: $totalPhotos장');
      if (recentSites.isNotEmpty) {
        context.writeln('최근 방문 성지: ${recentSites.join(", ")}');
      }
      if (daysSinceLastVisit == 0) {
        context.writeln('마지막 순례: 오늘');
      } else if (daysSinceLastVisit == 1) {
        context.writeln('마지막 순례: 어제');
      } else {
        context.writeln('마지막 순례: ${daysSinceLastVisit}일 전');
      }
      context.writeln('이 순례자의 활동 이력을 참고하여, 경험에 맞는 맞춤 상담을 해주세요.');
      context.writeln('예: 방문한 성지를 언급하며 공감하고, 아직 방문하지 않은 성지를 추천할 수 있습니다.');

      // 환영 화면용 요약
      final summary = StringBuffer();
      summary.write('$totalVisits회 순례 · $uniqueSites곳 방문');
      if (totalPrayers > 0) summary.write(' · $totalPrayers편 기도');
      if (totalPhotos > 0) summary.write(' · $totalPhotos장 인증샷');

      if (mounted) {
        setState(() {
          _activityContext = context.toString();
          _activitySummary = summary.toString();
        });
      }
    } catch (e) {
      debugPrint('활동 컨텍스트 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  List<SuggestedQuestion> get _filteredQuestions {
    if (_selectedCategory == CounselCategory.all) return _allQuestions;
    return _allQuestions.where((q) => q.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✝️', style: TextStyle(fontSize: 20)),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // AI 프로필
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '은혜샘과 대화하기',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '신앙의 길 위에서 함께 걸어가는 AI 상담사입니다\n기도, 성경, 고민 무엇이든 편하게 나눠주세요 🙏',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),

          // 개인 정보 연동 상태 표시
          _buildPersonaContextBanner(context, colorScheme),

          const SizedBox(height: 16),

          // 카테고리 탭
          _buildCategoryTabs(context),
          const SizedBox(height: 16),

          // 추천 질문 카드
          ..._filteredQuestions.map((q) => _buildQuestionCard(context, q)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 개인 정보 연동 상태 배너
  Widget _buildPersonaContextBanner(BuildContext context, ColorScheme colorScheme) {
    final persona = ref.watch(userPersonaProvider).valueOrNull;
    final hasPersona = persona != null &&
        (persona.gender.isNotEmpty || persona.nickname.isNotEmpty || persona.ageGroup.isNotEmpty || persona.churchRole.isNotEmpty || persona.interests.isNotEmpty);
    final hasActivity = _activitySummary.isNotEmpty;

    if (!hasPersona && !hasActivity) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/persona-edit'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '맞춤 설정을 하면 더 개인화된 상담이 가능해요',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      );
    }

    // 페르소나 + 활동 정보 표시
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '개인 맞춤 상담 활성화됨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (hasPersona) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      [
                        // 별명 + 호칭 조합
                        if (persona.nickname.isNotEmpty && persona.gender.isNotEmpty)
                          '${persona.nickname} ${persona.gender}님'
                        else if (persona.nickname.isNotEmpty)
                          '${persona.nickname}님'
                        else if (persona.gender.isNotEmpty)
                          '${persona.gender}님',
                        if (persona.churchRole.isNotEmpty) persona.churchRole,
                        if (persona.ageGroup.isNotEmpty) persona.ageGroup,
                        if (persona.interests.isNotEmpty) persona.interests.take(3).join('·'),
                      ].join(' | '),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (hasActivity) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      _activitySummary,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 카테고리 탭
  Widget _buildCategoryTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: CounselCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(category.label),
                ],
              ),
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: colorScheme.primaryContainer,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 추천 질문 카드
  Widget _buildQuestionCard(BuildContext context, SuggestedQuestion question) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = question.category.color ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _sendMessage(question.question),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(question.icon, size: 18, color: categoryColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 채팅 메시지 리스트
  Widget _buildChatList(BuildContext context) {
    final itemCount = _messages.length + (_isStreaming ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _messages.length) {
          return _buildMessageBubble(context, _messages[index]);
        } else {
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
      padding: const EdgeInsets.only(bottom: 16),
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
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],

          // 메시지 내용
          Flexible(
            child: Container(
              padding: isUser
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : const EdgeInsets.all(4),
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
              child: isUser
                  ? Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            height: 1.5,
                          ),
                    )
                  : _buildMarkdownBody(context, message.content),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// 마크다운 렌더링된 AI 응답 본문
  Widget _buildMarkdownBody(BuildContext context, String content) {
    final colorScheme = Theme.of(context).colorScheme;
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
        h1: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        h2: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        h3: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        listBullet: Theme.of(context).textTheme.bodyMedium,
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        tableBorder: TableBorder.all(color: colorScheme.outlineVariant),
      ),
    );
  }

  /// 스트리밍 중인 AI 응답 버블
  Widget _buildStreamingBubble(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: _streamingText.isEmpty
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : const EdgeInsets.all(4),
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
                  : _buildMarkdownBody(context, _streamingText),
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
      children: [
        Text(
          '은혜샘이 답변을 준비하고 있어요',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ],
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
                hintText: '은혜샘에게 질문하세요...',
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
          // 전송/중지 버튼
          Container(
            decoration: BoxDecoration(
              gradient: _isStreaming
                  ? null
                  : LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                    ),
              color: _isStreaming ? colorScheme.errorContainer : null,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isStreaming ? Icons.stop : Icons.send,
                color: _isStreaming
                    ? colorScheme.onErrorContainer
                    : Colors.white,
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

    final persona = ref.read(userPersonaProvider).valueOrNull;
    _streamSubscription = aiService.streamChat(
      _messages, text,
      persona: persona,
      activityContext: _activityContext,
    ).listen(
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
            content: '죄송합니다, 응답 중 오류가 발생했습니다. 다시 시도해 주세요. 🙏',
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
