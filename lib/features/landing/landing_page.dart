import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

/// 랜딩 페이지 (모바일 온보딩)
/// 풀스크린 PageView로 3개의 슬라이드를 보여주고
/// 마지막 슬라이드에서 로그인 화면으로 이동
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      emoji: '🏥',
      title: 'AI가 분석하는\n나만의 건강 관리',
      subtitle: '건강검진 데이터를 입력하면\nAI가 맞춤형 건강 분석을 제공합니다.',
    ),
    _OnboardingData(
      emoji: '🏆',
      title: '매일 작은 챌린지로\n건강 습관 만들기',
      subtitle: '작은 실천이 쌓여\n큰 건강 변화를 만들어냅니다.',
    ),
    _OnboardingData(
      emoji: '👥',
      title: '친구와 함께\n더 건강하게',
      subtitle: '챌린지를 친구와 공유하고\n함께 건강 목표를 달성해요.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 온보딩 화면에서는 상태바 아이콘을 흰색으로
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    // 로그인 화면에서는 상태바 아이콘 다시 어둡게
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── 배경 그래디언트 ───────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          ),

          // ── 슬라이드 콘텐츠 ───────────────────────────
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _OnboardingSlide(data: _pages[i]),
          ),

          // ── 상단: 건너뛰기 버튼 ───────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedOpacity(
                  opacity: isLast ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLast ? null : _goToLogin,
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 하단: 페이지 닷 + 버튼 ───────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 페이지 인디케이터 닷
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // 다음 / 시작하기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.heroDark,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLast ? '시작하기' : '다음',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // 버튼 아래 여백 (건너뛰기 버튼과 높이 맞추기)
                    const SizedBox(height: 44),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 온보딩 데이터 ──────────────────────────────────────
class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

// ── 온보딩 슬라이드 ────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // 하단은 버튼 영역 확보
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지 아이콘 원형 컨테이너
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Center(
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 52),

            // 메인 타이틀
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // 서브 타이틀
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withAlpha(200),
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
