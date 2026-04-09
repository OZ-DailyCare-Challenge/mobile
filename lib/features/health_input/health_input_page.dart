import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 건강 데이터 입력 페이지
/// 웹: pages/HealthInput/HealthInputPage.tsx 대응
/// - 기본정보 (닉네임, 나이, 성별, 키, 몸무게)
/// - 건강지표 (혈압, 공복혈당, 콜레스테롤, HDL)
/// - 생활습관 (흡연, 음주, 운동)
class HealthInputPage extends StatelessWidget {
  const HealthInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('건강 정보 입력'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 진행 상태 표시
              _ProgressIndicatorBar(step: 1, total: 3),
              const SizedBox(height: 24),

              // 섹션 1: 기본 정보
              _SectionCard(
                title: '기본 정보',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _InputField(label: '닉네임', hint: '사용할 닉네임을 입력하세요'),
                    _InputField(label: '나이', hint: '예: 35', keyboardType: TextInputType.number),
                    _GenderSelector(),
                    _InputField(label: '키 (cm)', hint: '예: 170', keyboardType: TextInputType.number),
                    _InputField(label: '몸무게 (kg)', hint: '예: 65', keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 섹션 2: 건강 지표
              _SectionCard(
                title: '건강 지표',
                icon: Icons.favorite_border,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _InputField(label: '수축기 혈압', hint: '120', keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _InputField(label: '이완기 혈압', hint: '80', keyboardType: TextInputType.number)),
                      ],
                    ),
                    _InputField(label: '공복혈당 (mg/dL)', hint: '예: 95', keyboardType: TextInputType.number),
                    _InputField(label: '총 콜레스테롤 (mg/dL)', hint: '예: 200', keyboardType: TextInputType.number),
                    _InputField(label: 'HDL 콜레스테롤 (mg/dL)', hint: '예: 55', keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 섹션 3: 생활 습관
              _SectionCard(
                title: '생활 습관',
                icon: Icons.directions_run,
                child: Column(
                  children: [
                    _DropdownField(
                      label: '흡연 여부',
                      items: const ['비흡연', '과거 흡연', '현재 흡연'],
                    ),
                    _DropdownField(
                      label: '음주 빈도',
                      items: const ['거의 안함', '월 1-3회', '주 1-2회', '주 3회 이상'],
                    ),
                    _DropdownField(
                      label: '운동 빈도',
                      items: const ['거의 안함', '주 1-2회', '주 3-4회', '주 5회 이상'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 다음 버튼
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.result),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('분석 결과 보기'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
  const _SectionCard({required this.title, required this.icon, required this.child});

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

// ── 입력 필드 ──────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  const _InputField({required this.label, required this.hint, this.keyboardType});

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
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

// ── 성별 선택기 ────────────────────────────────────────
class _GenderSelector extends StatefulWidget {
  @override
  State<_GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<_GenderSelector> {
  String _selected = '남성';

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
            children: ['남성', '여성'].map((gender) {
              final isSelected = _selected == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = gender),
                  child: Container(
                    margin: EdgeInsets.only(right: gender == '남성' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySurface : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderDefault,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        gender,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 드롭다운 필드 ──────────────────────────────────────
class _DropdownField extends StatefulWidget {
  final String label;
  final List<String> items;
  const _DropdownField({required this.label, required this.items});

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _value,
            decoration: const InputDecoration(),
            hint: Text('선택해주세요', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
            items: widget.items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
    );
  }
}
