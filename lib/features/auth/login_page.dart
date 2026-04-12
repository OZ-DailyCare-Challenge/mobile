import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 로그인 페이지
/// 풀스크린 분할 디자인
/// - 상단 60%: 다크 그린 그래디언트 + 로고
/// - 하단 40%: 흰색 카드 + 소셜 로그인 + 비로그인 계속하기
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    Future<void> handleGoogleLogin() async {
      await ref.read(authProvider.notifier).loginWithGoogle();
      if (!context.mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        // 신규 가입이면 건강 정보 입력, 기존 회원이면 대시보드
        context.go(auth.isNewUser ? AppRoutes.healthInput : AppRoutes.dashboard);
      }
    }

    void handleGuestContinue() {
      ref.read(authProvider.notifier).continueAsGuest();
      context.go(AppRoutes.dashboard);
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── 상단 그래디언트 배경 ───────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.58,
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ),

          // ── 하단 흰색 배경 ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: const ColoredBox(color: AppColors.background),
          ),

          // ── 전체 콘텐츠 ───────────────────────────────
          Column(
            children: [
              // 뒤로 가기 버튼
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () => context.go(AppRoutes.landing),
                  ),
                ),
              ),

              // 로고 영역 (그린 배경 위)
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MyHealthBuddy',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI 기반 건강 관리 서비스',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withAlpha(178),
                      ),
                    ),
                  ],
                ),
              ),

              // 로그인 카드 (흰색 영역)
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('시작하기', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        '소셜 계정으로 간편하게 로그인하세요',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Google 로그인 버튼
                      _SocialButton(
                        onTap: handleGoogleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.g_mobiledata,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Google로 계속하기',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Apple 로그인 버튼
                      _SocialButton(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.apple,
                              size: 22,
                              color: AppColors.textDark,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Apple로 계속하기',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── 구분선 ─────────────────────────
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '또는',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── 비로그인으로 계속하기 ──────────
                      TextButton(
                        onPressed: handleGuestContinue,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '로그인 없이 둘러보기',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 이용약관 안내
                      Center(
                        child: Text(
                          '로그인 시 서비스 이용약관 및\n개인정보처리방침에 동의하는 것으로 간주됩니다.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 소셜 버튼 공통 래퍼 ────────────────────────────────
class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _SocialButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: child,
        ),
      ),
    );
  }
}
