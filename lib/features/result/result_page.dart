import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/health/health_provider.dart';
import '../../core/models/health_models.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 건강 분석 결과 페이지
/// healthProvider의 analysisResult를 표시
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);
    final result = healthState.analysisResult;

    // 아직 분석 중이거나 결과 없음
    if (result == null || healthState.isAnalyzing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('건강 분석 결과')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('AI가 분석 중입니다...'),
            ],
          ),
        ),
      );
    }

    if (result.isFailed) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('건강 분석 결과')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.statusHigh),
              const SizedBox(height: 16),
              const Text('분석에 실패했습니다.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.healthInput),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final predict = result.ml1Predict!;
    final comment = result.ml1Comment!;

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
              _SummaryCard(predict: predict),
              const SizedBox(height: 16),

              // ── 위험 요인 ─────────────────────────
              _RiskFactorCard(factors: predict.topRiskFactors),
              const SizedBox(height: 16),

              // ── AI 코멘트 ─────────────────────────
              _AiCommentCard(comment: comment),
              const SizedBox(height: 16),

              // ── 맞춤 미션 ─────────────────────────
              _MissionsCard(missions: comment.missions),
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
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textMuted),
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
  final Ml1Predict predict;
  const _SummaryCard({required this.predict});

  Color get _riskColor {
    switch (predict.riskGrade) {
      case '낮음':
        return AppColors.statusLow;
      case '보통':
        return AppColors.statusMedium;
      case '중간':
        return AppColors.statusMedium;
      case '높음':
        return AppColors.statusHigh;
      case '매우높음':
        return AppColors.statusHigh;
      default:
        return AppColors.textMuted;
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
                value: predict.riskGrade,
                valueColor: _riskColor,
              ),
              _Divider(),
              _MetricItem(
                label: '위험도 (%)',
                value: '${predict.riskPercent.toStringAsFixed(1)}%',
                valueColor: AppColors.primary,
              ),
              _Divider(),
              _MetricItem(
                label: '심혈관 나이',
                value: '${predict.heartAge}세',
                valueColor: AppColors.textDashboard,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 위험도 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (predict.riskPercent / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.borderDefault,
              color: _riskColor,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          // 캐릭터 단계
          _CharacterStageBadge(stage: predict.characterStage),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _MetricItem(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.metric
                .copyWith(color: valueColor, fontSize: 20)),
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

class _CharacterStageBadge extends StatelessWidget {
  final int stage;
  const _CharacterStageBadge({required this.stage});

  static const _labels = ['새싹', '초보', '중수', '고수', '마스터'];
  static const _colors = [
    Color(0xFF86EFAC),
    Color(0xFF60A5FA),
    Color(0xFFFBBF24),
    Color(0xFFF97316),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = (stage - 1).clamp(0, 4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _colors[idx].withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colors[idx]),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16),
          const SizedBox(width: 6),
          Text(
            '건강 레벨 $stage · ${_labels[idx]}',
            style: AppTextStyles.labelMedium
                .copyWith(color: _colors[idx], fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── 위험 요인 카드 ─────────────────────────────────────
class _RiskFactorCard extends StatelessWidget {
  final List<String> factors;
  const _RiskFactorCard({required this.factors});

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
              const Icon(Icons.warning_amber_outlined,
                  color: AppColors.statusMedium, size: 20),
              const SizedBox(width: 8),
              Text('주요 위험 요인', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          if (factors.isEmpty)
            Text('위험 요인이 없습니다! 건강한 상태입니다.',
                style: AppTextStyles.bodyMedium)
          else
            ...factors.map(
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
                    Expanded(
                        child: Text(f, style: AppTextStyles.bodyMedium)),
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
  final Ml1Comment comment;
  const _AiCommentCard({required this.comment});

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
              const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('AI 건강 평가', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment.evaluation,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
          if (comment.alert != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusHigh.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.statusHigh),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AppColors.statusHigh, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment.alert!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.statusHigh),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            comment.encouragement,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 맞춤 미션 카드 ─────────────────────────────────────
class _MissionsCard extends StatelessWidget {
  final List<String> missions;
  const _MissionsCard({required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) return const SizedBox.shrink();

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
              const Icon(Icons.emoji_events_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('맞춤 건강 미션', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          ...missions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(entry.value,
                        style: AppTextStyles.bodyMedium),
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
