import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 건강 분석 결과 페이지
/// 웹: pages/Result/ResultPage.tsx 대응
/// - 심혈관 위험도 평가 (low / medium / high)
/// - 건강 점수 (0-100)
/// - 위험 요인 목록
/// - 챌린지 추천
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Riverpod으로 실제 분석 데이터 연결
    const riskLevel = 'low';
    const healthScore = 82;
    const cardioAge = 38;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('건강 분석 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.healthInput),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 요약 카드 ─────────────────────────
              _SummaryCard(
                riskLevel: riskLevel,
                healthScore: healthScore,
                cardioAge: cardioAge,
              ),
              const SizedBox(height: 16),

              // ── 위험 요인 ─────────────────────────
              _RiskFactorCard(),
              const SizedBox(height: 16),

              // ── AI 코멘트 ─────────────────────────
              _AiCommentCard(riskLevel: riskLevel),
              const SizedBox(height: 16),

              // ── 추천 챌린지 ───────────────────────
              _RecommendedChallenges(),
              const SizedBox(height: 32),

              // ── 대시보드로 이동 ───────────────────
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('대시보드로 이동'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.healthInput),
                child: const Text('다시 입력하기'),
              ),
              const SizedBox(height: 8),
              Text(
                '※ 이 결과는 참고용이며 실제 의학적 진단을 대체하지 않습니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 요약 카드 ──────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String riskLevel;
  final int healthScore;
  final int cardioAge;
  const _SummaryCard({
    required this.riskLevel,
    required this.healthScore,
    required this.cardioAge,
  });

  Color get _riskColor {
    switch (riskLevel) {
      case 'low':    return AppColors.statusLow;
      case 'medium': return AppColors.statusMedium;
      case 'high':   return AppColors.statusHigh;
      default:       return AppColors.textMuted;
    }
  }

  String get _riskLabel {
    switch (riskLevel) {
      case 'low':    return '낮음';
      case 'medium': return '보통';
      case 'high':   return '높음';
      default:       return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text('종합 건강 결과', style: AppTextStyles.titleLarge),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                label: '심혈관 위험도',
                value: _riskLabel,
                valueColor: _riskColor,
              ),
              _Divider(),
              _MetricItem(
                label: '건강 점수',
                value: '$healthScore점',
                valueColor: AppColors.primary,
              ),
              _Divider(),
              _MetricItem(
                label: '심혈관 나이',
                value: '$cardioAge세',
                valueColor: AppColors.textDashboard,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 건강 점수 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: healthScore / 100,
              backgroundColor: AppColors.borderDefault,
              color: AppColors.primary,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _MetricItem({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.metric.copyWith(color: valueColor, fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.borderDefault);
  }
}

// ── 위험 요인 카드 ─────────────────────────────────────
class _RiskFactorCard extends StatelessWidget {
  // TODO: 실제 데이터로 대체
  final List<String> _factors = const [
    '혈압이 정상 범위를 약간 초과했습니다.',
    '규칙적인 운동이 부족합니다.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_outlined, color: AppColors.statusMedium, size: 20),
              const SizedBox(width: 8),
              Text('위험 요인', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          if (_factors.isEmpty)
            Text('위험 요인이 없습니다! 건강한 상태입니다.', style: AppTextStyles.bodyMedium)
          else
            ..._factors.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.statusMedium,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f, style: AppTextStyles.bodyMedium)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── AI 코멘트 카드 ─────────────────────────────────────
class _AiCommentCard extends StatelessWidget {
  final String riskLevel;
  const _AiCommentCard({required this.riskLevel});

  String get _comment {
    switch (riskLevel) {
      case 'low':
        return '전반적으로 건강한 상태입니다. 현재의 좋은 습관을 유지하고, 꾸준한 운동과 균형 잡힌 식단으로 건강을 지속하세요.';
      case 'medium':
        return '몇 가지 위험 요인이 발견되었습니다. 생활 습관 개선이 필요하며, 정기적인 건강 검진을 권장합니다.';
      case 'high':
        return '심혈관 위험 요인이 높습니다. 즉각적인 생활 습관 개선과 의료 전문가 상담을 강력히 권장합니다.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('AI 분석 코멘트', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          Text(_comment, style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
        ],
      ),
    );
  }
}

// ── 추천 챌린지 ────────────────────────────────────────
class _RecommendedChallenges extends StatelessWidget {
  // TODO: API 연동
  final List<Map<String, dynamic>> _challenges = const [
    {'icon': Icons.directions_walk, 'title': '매일 30분 걷기', 'desc': '심혈관 건강에 최고의 운동'},
    {'icon': Icons.water_drop_outlined, 'title': '하루 8잔 물 마시기', 'desc': '적정 수분 섭취로 혈액 순환 개선'},
    {'icon': Icons.eco_outlined, 'title': '채소 반찬 1가지 추가', 'desc': '식이섬유로 콜레스테롤 관리'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('추천 챌린지', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          ..._challenges.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(c['icon'] as IconData, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['title'] as String, style: AppTextStyles.titleSmall),
                        Text(c['desc'] as String, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
