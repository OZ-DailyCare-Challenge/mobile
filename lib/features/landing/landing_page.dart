import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 랜딩 페이지
/// 웹: pages/Landing/LandingPage.tsx 대응
/// - 앱 소개 및 주요 기능 쇼케이스
/// - 시작하기(로그인) CTA 버튼
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Hero 섹션 ───────────────────────────
              _HeroSection(
                onStart: () => context.go(AppRoutes.login),
              ),

              // ── Feature 섹션 ────────────────────────
              const _FeatureSection(),

              // ── Bottom CTA 섹션 ─────────────────────
              _BottomCTASection(
                onStart: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero 섹션 ──────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VoidCallback onStart;
  const _HeroSection({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고
          Text(
            'MyHealthBuddy',
            style: AppTextStyles.logo.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 32),

          // 메인 타이틀
          Text(
            'AI가 분석하는\n나만의 건강 관리',
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          // 서브 타이틀
          Text(
            '건강검진 데이터와 생활 습관을\n실행 가능한 건강 챌린지로 변환합니다.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withAlpha(204),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),

          // CTA 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '지금 시작하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature 섹션 ───────────────────────────────────────
class _FeatureSection extends StatelessWidget {
  const _FeatureSection();

  static const List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.analytics_outlined,
      title: 'AI 건강 분석',
      description: '심혈관 위험도를 포함한\n맞춤형 건강 분석 결과를 제공합니다.',
    ),
    _FeatureData(
      icon: Icons.emoji_events_outlined,
      title: '일일 챌린지',
      description: '매일 작은 건강 습관을\n챌린지로 만들어 실천해보세요.',
    ),
    _FeatureData(
      icon: Icons.people_outline,
      title: '친구와 함께',
      description: '친구와 챌린지를 공유하고\n함께 건강해져요.',
    ),
    _FeatureData(
      icon: Icons.track_changes_outlined,
      title: '건강 추적',
      description: '혈압, 혈당, 콜레스테롤 등\n주요 건강 지표를 추적합니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('주요 기능', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '건강한 삶을 위한 모든 기능',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 32),
          ...(_features.map((f) => _FeatureCard(data: f))),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom CTA 섹션 ────────────────────────────────────
class _BottomCTASection extends StatelessWidget {
  final VoidCallback onStart;
  const _BottomCTASection({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            '지금 바로 건강을\n관리해보세요',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '무료로 시작할 수 있어요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withAlpha(204),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '무료로 시작하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
