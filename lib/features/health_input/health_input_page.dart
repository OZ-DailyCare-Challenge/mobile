import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/health/health_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 건강 데이터 입력 페이지
/// 회원: 기록 생성 → AI 분석 → result 페이지
/// 비회원(게스트): 직접 AI 분석 → result 페이지
class HealthInputPage extends ConsumerStatefulWidget {
  const HealthInputPage({super.key});

  @override
  ConsumerState<HealthInputPage> createState() => _HealthInputPageState();
}

class _HealthInputPageState extends ConsumerState<HealthInputPage> {
  // ── 컨트롤러 ──────────────────────────────────────────
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _cholesterolCtrl = TextEditingController();
  final _glucoseCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController(); // 비회원용 (YYYY-MM-DD)

  String _gender = 'M';
  bool _smokeYn = false;
  bool _alcoholYn = false;
  bool _exerciseYn = false;

  @override
  void dispose() {
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _cholesterolCtrl.dispose();
    _glucoseCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _birthDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final notifier = ref.read(healthProvider.notifier);
    final isGuest = ref.read(authProvider).isGuest;

    // 폼 유효성 검사
    final systolic = int.tryParse(_systolicCtrl.text);
    final diastolic = int.tryParse(_diastolicCtrl.text);
    final cholesterol = int.tryParse(_cholesterolCtrl.text);
    final glucose = int.tryParse(_glucoseCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);

    if (systolic == null ||
        diastolic == null ||
        cholesterol == null ||
        glucose == null ||
        height == null ||
        weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 올바르게 입력해주세요.')),
      );
      return;
    }

    // 비회원 생년월일 필수
    if (isGuest && _birthDateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 입력해주세요. (예: 1990-01-15)')),
      );
      return;
    }

    notifier.updateForm(
      HealthInputForm(
        systolicBp: systolic,
        diastolicBp: diastolic,
        totalCholesterol: cholesterol,
        glucose: glucose,
        height: height,
        weight: weight,
        smokeYn: _smokeYn,
        alcoholYn: _alcoholYn,
        exerciseYn: _exerciseYn,
        birthDate: isGuest ? _birthDateCtrl.text : null,
        gender: _gender,
      ),
    );

    if (isGuest) {
      await notifier.submitGuestAnalysis();
    } else {
      await notifier.submitAndAnalyze();
    }

    if (!mounted) return;

    final healthState = ref.read(healthProvider);
    if (healthState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: ${healthState.error}')),
      );
    } else {
      context.go(AppRoutes.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(authProvider).isGuest;
    final healthState = ref.watch(healthProvider);
    final isLoading =
        healthState.isSubmitting || healthState.isAnalyzing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('건강 정보 입력'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProgressIndicatorBar(step: 1, total: 2),
                  const SizedBox(height: 24),

                  // 비회원 기본 정보 (생년월일 + 성별)
                  if (isGuest) ...[
                    _SectionCard(
                      title: '기본 정보',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          _InputField(
                            label: '생년월일',
                            hint: '예: 1990-01-15',
                            controller: _birthDateCtrl,
                          ),
                          _GenderSelector(
                            selected: _gender,
                            onChanged: (v) =>
                                setState(() => _gender = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 신체 정보
                  _SectionCard(
                    title: '신체 정보',
                    icon: Icons.straighten_rounded,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _InputField(
                                label: '키 (cm)',
                                hint: '예: 170',
                                controller: _heightCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InputField(
                                label: '몸무게 (kg)',
                                hint: '예: 65',
                                controller: _weightCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 건강 지표
                  _SectionCard(
                    title: '건강 지표',
                    icon: Icons.favorite_border,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _InputField(
                                label: '수축기 혈압',
                                hint: '120',
                                controller: _systolicCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InputField(
                                label: '이완기 혈압',
                                hint: '80',
                                controller: _diastolicCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        _InputField(
                          label: '총 콜레스테롤 (mg/dL)',
                          hint: '예: 200',
                          controller: _cholesterolCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        _InputField(
                          label: '공복혈당 (mg/dL)',
                          hint: '예: 95',
                          controller: _glucoseCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 생활 습관
                  _SectionCard(
                    title: '생활 습관',
                    icon: Icons.directions_run,
                    child: Column(
                      children: [
                        _ToggleRow(
                          label: '흡연 여부',
                          value: _smokeYn,
                          onChanged: (v) => setState(() => _smokeYn = v),
                        ),
                        _ToggleRow(
                          label: '음주 여부',
                          value: _alcoholYn,
                          onChanged: (v) =>
                              setState(() => _alcoholYn = v),
                        ),
                        _ToggleRow(
                          label: '규칙적인 운동',
                          value: _exerciseYn,
                          onChanged: (v) =>
                              setState(() => _exerciseYn = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isLoading ? '분석 중...' : '분석 결과 보기',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 로딩 오버레이
          if (isLoading)
            Container(
              color: Colors.black.withAlpha(80),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        healthState.isSubmitting
                            ? '건강 데이터를 저장하는 중...'
                            : 'AI가 분석하는 중...',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '잠시만 기다려주세요',
                        style: AppTextStyles.bodySmall,
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
}

// ── 진행 표시 바 ───────────────────────────────────────
class _ProgressIndicatorBar extends StatelessWidget {
  final int step;
  final int total;
  const _ProgressIndicatorBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('정보 입력 중', style: AppTextStyles.labelMedium),
            Text('$step / $total', style: AppTextStyles.labelSmall),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: step / total,
            backgroundColor: AppColors.borderDefault,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── 섹션 카드 ──────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ── 텍스트 입력 필드 ───────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

// ── 성별 선택 ──────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _GenderSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('성별', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _GenderOption(
                label: '남성',
                value: 'M',
                selected: selected,
                onTap: onChanged,
              ),
              const SizedBox(width: 8),
              _GenderOption(
                label: '여성',
                value: 'F',
                selected: selected,
                onTap: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _GenderOption(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primarySurface : Colors.white,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.borderDefault,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 토글 행 (흡연/음주/운동) ───────────────────────────
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow(
      {required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
