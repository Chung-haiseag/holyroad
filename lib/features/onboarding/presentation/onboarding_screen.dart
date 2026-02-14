import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 온보딩 화면: 첫 사용자에게 앱 기능을 안내합니다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPageData(
      icon: Icons.church,
      title: 'Holy Road에 오신 것을 환영합니다',
      subtitle: '한국 기독교 113개 성지를\n손끝에서 만나보세요',
      color: Color(0xFF6750A4),
    ),
    _OnboardingPageData(
      icon: Icons.map,
      title: '지도로 성지 탐색',
      subtitle: '전국 곳곳에 숨겨진 믿음의 역사를\n지도에서 찾아보세요',
      color: Color(0xFF1565C0),
    ),
    _OnboardingPageData(
      icon: Icons.auto_awesome,
      title: 'AI 순례 가이드',
      subtitle: 'AI가 들려주는 성지의 역사, 인물,\n묵상, 기도를 경험하세요',
      color: Color(0xFF2E7D32),
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active,
      title: '성지 근처에서 알림',
      subtitle: '성지 근처에 가면 자동으로 알려드려요\n위치 권한을 허용해 주세요',
      color: Color(0xFFE65100),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 페이지 뷰
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _buildPage(context, page);
            },
          ),

          // 하단 컨트롤
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 페이지 인디케이터
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? _pages[_currentPage].color
                                : Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // 버튼
                    if (_currentPage == _pages.length - 1)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _completeOnboarding,
                          style: FilledButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                          ),
                          child: const Text(
                            '시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _completeOnboarding,
                            child: const Text('건너뛰기'),
                          ),
                          FilledButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _pages[_currentPage].color,
                            ),
                            child: const Text('다음'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, _OnboardingPageData page) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 100), // 하단 버튼 공간 확보
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
