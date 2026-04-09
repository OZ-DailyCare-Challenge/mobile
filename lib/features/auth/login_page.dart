import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 로그인 페이지
/// 웹: pages/Login/LoginPage.tsx 대응
/// - Google OAuth 로그인
/// - 분할 화면 디자인 (웹 기준) → 모바일은 단일 화면
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.landing),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // ── 로고 & 타이틀 ─────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'MyHealthBuddy',
                      style: AppTextStyles.logo,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI 기반 건강 관리 서비스',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 56),

              // ── 로그인 안내 ───────────────────────
              Text(
                '시작하기',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '소셜 계정으로 간편하게 로그인하세요',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 32),

              // ── Google 로그인 버튼 ────────────────
              _GoogleSignInButton(
                onTap: () {
                  // TODO: Google Sign-In 연동
                  // 임시: 로그인 성공 후 health-input으로 이동
                  context.go(AppRoutes.healthInput);
                },
              ),

              const SizedBox(height: 24),

              // ── 안내 문구 ─────────────────────────
              Center(
                child: Text(
                  '로그인 시 서비스 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.',
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
    );
  }
}

/// Google 로그인 버튼
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleSignInButton({required this.onTap});

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google 아이콘 (텍스트로 대체, 실제로는 SVG 사용 권장)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.g_mobiledata, size: 20, color: Colors.red),
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
      ),
    );
  }
}
