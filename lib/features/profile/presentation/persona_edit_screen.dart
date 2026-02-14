import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:holyroad/core/providers/user_persona_provider.dart';
import 'package:holyroad/features/auth/domain/entities/user_persona.dart';

/// AI 맞춤 설정 – 회원 페르소나 편집 화면.
/// 연령대, 직분, 관심사항을 설정하면 AI 가이드가 개인화됩니다.
class PersonaEditScreen extends ConsumerStatefulWidget {
  const PersonaEditScreen({super.key});

  @override
  ConsumerState<PersonaEditScreen> createState() => _PersonaEditScreenState();
}

class _PersonaEditScreenState extends ConsumerState<PersonaEditScreen> {
  String _gender = '';
  String _nickname = '';
  String _ageGroup = '';
  String _churchRole = '';
  List<String> _interests = [];
  bool _isLoading = false;
  bool _initialized = false;

  final TextEditingController _nicknameController = TextEditingController();

  static const _genderOptions = ['형제', '자매'];
  static const _ageGroups = ['10대', '20대', '30대', '40대', '50대', '60대 이상'];
  static const _churchRoles = ['학생', '청년', '집사', '권사', '장로', '전도사', '목사'];

  /// 성경 인물 추천 목록 (남성/여성 구분)
  static const _bibleMaleNames = [
    {'name': '다윗', 'desc': '용기와 찬양의 왕'},
    {'name': '바울', 'desc': '이방인의 사도'},
    {'name': '모세', 'desc': '출애굽의 지도자'},
    {'name': '아브라함', 'desc': '믿음의 조상'},
    {'name': '요셉', 'desc': '꿈과 용서의 사람'},
    {'name': '베드로', 'desc': '반석 위의 제자'},
    {'name': '여호수아', 'desc': '약속의 땅을 정복한 지도자'},
    {'name': '다니엘', 'desc': '지혜와 기도의 사람'},
    {'name': '사무엘', 'desc': '하나님의 부름을 들은 소년'},
    {'name': '엘리야', 'desc': '불의 선지자'},
  ];

  static const _bibleFemaleNames = [
    {'name': '에스더', 'desc': '용기 있는 왕비'},
    {'name': '룻', 'desc': '충성과 헌신의 여인'},
    {'name': '마리아', 'desc': '예수님의 어머니'},
    {'name': '한나', 'desc': '기도의 여인'},
    {'name': '드보라', 'desc': '이스라엘의 여사사'},
    {'name': '라합', 'desc': '믿음의 여인'},
    {'name': '사라', 'desc': '믿음의 어머니'},
    {'name': '리브가', 'desc': '섬김의 여인'},
    {'name': '미리암', 'desc': '찬양의 여인'},
    {'name': '막달라 마리아', 'desc': '부활의 첫 증인'},
  ];
  static const _interestOptions = [
    '역사',
    '기도',
    '선교',
    '찬양',
    '성경공부',
    '묵상',
    '봉사',
    '성지순례',
  ];

  @override
  Widget build(BuildContext context) {
    final personaAsync = ref.watch(userPersonaProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 초기값 세팅 (한 번만)
    personaAsync.whenData((persona) {
      if (!_initialized && persona != null) {
        _gender = persona.gender;
        _nickname = persona.nickname;
        _nicknameController.text = persona.nickname;
        _ageGroup = persona.ageGroup;
        _churchRole = persona.churchRole;
        _interests = List<String>.from(persona.interests);
        _initialized = true;
      }
      if (!_initialized && persona == null) {
        _initialized = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 맞춤 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── 안내 카드 ──
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '나이, 직분, 관심사를 설정하면\nAI 가이드가 맞춤형 콘텐츠를 제공합니다.',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── 호칭 (성별) ──
          _buildSectionTitle(context, '호칭', Icons.person_outline),
          const SizedBox(height: 4),
          Text(
            'AI 상담사가 형제님/자매님으로 올바르게 불러드립니다',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _genderOptions.map((g) {
              final selected = _gender == g;
              return ChoiceChip(
                label: Text('$g님'),
                selected: selected,
                onSelected: (val) {
                  setState(() => _gender = val ? g : '');
                },
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: selected ? colorScheme.onPrimaryContainer : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── 별명 (성경 인물) ──
          _buildSectionTitle(context, '별명', Icons.auto_stories),
          const SizedBox(height: 4),
          Text(
            '성경 인물 이름이나 원하는 별명을 설정하세요',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          // 자유 입력 필드
          TextField(
            controller: _nicknameController,
            onChanged: (val) => setState(() => _nickname = val.trim()),
            decoration: InputDecoration(
              hintText: '별명을 입력하세요 (예: 다윗, 에스더)',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(Icons.edit, size: 20, color: colorScheme.primary),
              suffixIcon: _nickname.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _nicknameController.clear();
                        setState(() => _nickname = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLength: 10,
          ),
          // 성경 인물 추천 칩
          _buildBibleNameChips(context, colorScheme),
          const SizedBox(height: 24),

          // ── 연령대 ──
          _buildSectionTitle(context, '연령대', Icons.cake_outlined),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ageGroups.map((age) {
              final selected = _ageGroup == age;
              return ChoiceChip(
                label: Text(age),
                selected: selected,
                onSelected: (val) {
                  setState(() => _ageGroup = val ? age : '');
                },
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: selected ? colorScheme.onPrimaryContainer : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── 직분 ──
          _buildSectionTitle(context, '직분', Icons.church_outlined),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _churchRoles.map((role) {
              final selected = _churchRole == role;
              return ChoiceChip(
                label: Text(role),
                selected: selected,
                onSelected: (val) {
                  setState(() => _churchRole = val ? role : '');
                },
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: selected ? colorScheme.onPrimaryContainer : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── 관심사항 (다중 선택) ──
          _buildSectionTitle(context, '관심사항 (복수 선택 가능)', Icons.interests_outlined),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestOptions.map((interest) {
              final selected = _interests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _interests.add(interest);
                    } else {
                      _interests.remove(interest);
                    }
                  });
                },
                selectedColor: colorScheme.secondaryContainer,
                checkmarkColor: colorScheme.onSecondaryContainer,
                labelStyle: TextStyle(
                  color: selected ? colorScheme.onSecondaryContainer : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // ── 미리보기 ──
          if (_gender.isNotEmpty || _nickname.isNotEmpty || _ageGroup.isNotEmpty || _churchRole.isNotEmpty || _interests.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI에게 전달될 정보',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 호칭 미리보기 (별명 + 호칭 조합)
                    if (_nickname.isNotEmpty || _gender.isNotEmpty)
                      Text('• 호칭: ${_buildCallName()}'),
                    if (_ageGroup.isNotEmpty) Text('• 연령대: $_ageGroup'),
                    if (_churchRole.isNotEmpty) Text('• 직분: $_churchRole'),
                    if (_interests.isNotEmpty)
                      Text('• 관심사: ${_interests.join(", ")}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── 저장 버튼 ──
          FilledButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isLoading ? '저장 중...' : '저장'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          // ── 초기화 버튼 ──
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isLoading ? null : _reset,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('초기화'),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 성경 인물 추천 칩 위젯
  Widget _buildBibleNameChips(BuildContext context, ColorScheme colorScheme) {
    // 호칭에 따라 적절한 성경 인물 목록 선택
    final List<Map<String, String>> names;
    if (_gender == '자매') {
      names = _bibleFemaleNames;
    } else if (_gender == '형제') {
      names = _bibleMaleNames;
    } else {
      // 성별 미선택 시 남녀 혼합 (각 5명씩)
      names = [..._bibleMaleNames.take(5), ..._bibleFemaleNames.take(5)];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 성경 인물',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: names.map((item) {
            final name = item['name']!;
            final desc = item['desc']!;
            final selected = _nickname == name;
            return Tooltip(
              message: desc,
              child: ActionChip(
                avatar: selected
                    ? Icon(Icons.check, size: 16, color: colorScheme.onPrimaryContainer)
                    : null,
                label: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : null,
                    color: selected ? colorScheme.onPrimaryContainer : null,
                  ),
                ),
                backgroundColor: selected ? colorScheme.primaryContainer : null,
                onPressed: () {
                  setState(() {
                    if (selected) {
                      _nickname = '';
                      _nicknameController.clear();
                    } else {
                      _nickname = name;
                      _nicknameController.text = name;
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 별명 + 호칭을 조합한 호칭 문자열 생성
  String _buildCallName() {
    if (_nickname.isNotEmpty && _gender.isNotEmpty) {
      return '$_nickname $_gender님';
    } else if (_nickname.isNotEmpty) {
      return '$_nickname님';
    } else if (_gender.isNotEmpty) {
      return '$_gender님';
    }
    return '순례자님';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final persona = UserPersona(
        gender: _gender,
        nickname: _nickname,
        ageGroup: _ageGroup,
        churchRole: _churchRole,
        interests: _interests,
      );
      await saveUserPersona(uid, persona);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ AI 맞춤 설정이 저장되었습니다'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _reset() {
    _nicknameController.clear();
    setState(() {
      _gender = '';
      _nickname = '';
      _ageGroup = '';
      _churchRole = '';
      _interests = [];
    });
  }
}
