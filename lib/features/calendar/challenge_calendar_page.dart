import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/challenge/challenge_record_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 챌린지 달성 캘린더 페이지
/// - 월별 캘린더 (전/다음 달 이동)
/// - 날짜 셀: 완료 개수에 따라 색상 변화
/// - 선택된 날짜의 챌린지 상세 (토글 가능)
/// - 하단 월간 통계
class ChallengeCalendarPage extends ConsumerStatefulWidget {
  const ChallengeCalendarPage({super.key});

  @override
  ConsumerState<ChallengeCalendarPage> createState() =>
      _ChallengeCalendarPageState();
}

class _ChallengeCalendarPageState
    extends ConsumerState<ChallengeCalendarPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      // 이동한 달에 선택 날짜가 없으면 1일로 초기화
      _selectedDay =
          DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) {
      setState(() {
        _focusedMonth = next;
        // 다음 달이 현재 달이면 오늘 날짜로, 아니면 1일로
        final isCurrentMonth =
            next.year == now.year && next.month == now.month;
        _selectedDay = isCurrentMonth
            ? DateTime(now.year, now.month, now.day)
            : DateTime(next.year, next.month, 1);
      });
    }
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _focusedMonth.isBefore(DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    // 상태 변경 시 전체 리빌드
    ref.watch(challengeRecordProvider);
    final notifier = ref.read(challengeRecordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('달성 기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ── 캘린더 카드 ───────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _MonthNavigator(
                  focusedMonth: _focusedMonth,
                  canGoNext: _canGoNext,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),
                const SizedBox(height: 4),
                const _WeekdayHeader(),
                const SizedBox(height: 2),
                _CalendarGrid(
                  focusedMonth: _focusedMonth,
                  selectedDay: _selectedDay,
                  notifier: notifier,
                  onDaySelect: (date) =>
                      setState(() => _selectedDay = date),
                ),
                const SizedBox(height: 8),
                // 범례
                _Legend(),
              ],
            ),
          ),

          // ── 월간 통계 ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _MonthlyStats(
              focusedMonth: _focusedMonth,
              notifier: notifier,
            ),
          ),

          const SizedBox(height: 12),

          // ── 선택된 날짜 상세 ──────────────────────────
          Expanded(
            child: _DayDetail(
              selectedDay: _selectedDay,
              notifier: notifier,
              onToggle: (index) => notifier.toggle(_selectedDay, index),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 월 네비게이터 ──────────────────────────────────────
class _MonthNavigator extends StatelessWidget {
  final DateTime focusedMonth;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.focusedMonth,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  static const List<String> _months = [
    '',
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: onPrev,
          color: AppColors.textPrimary,
        ),
        Text(
          '${focusedMonth.year}년 ${_months[focusedMonth.month]}',
          style: AppTextStyles.titleLarge,
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: canGoNext
                ? AppColors.textPrimary
                : AppColors.borderDefault,
          ),
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

// ── 요일 헤더 ──────────────────────────────────────────
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const List<String> _weekdays = [
    '일', '월', '화', '수', '목', '금', '토',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _weekdays.map((day) {
        final isWeekend = day == '일' || day == '토';
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.labelSmall.copyWith(
                color: isWeekend
                    ? AppColors.statusHigh.withAlpha(160)
                    : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 캘린더 그리드 ──────────────────────────────────────
class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ChallengeRecordNotifier notifier;
  final ValueChanged<DateTime> onDaySelect;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.notifier,
    required this.onDaySelect,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    // 일요일 기준 시작 오프셋 (Dart weekday: 1=Mon..7=Sun)
    final startOffset = firstDay.weekday % 7;
    final totalCells = startOffset + daysInMonth;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset) return const SizedBox.shrink();

        final day = index - startOffset + 1;
        final date =
            DateTime(focusedMonth.year, focusedMonth.month, day);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = date.year == selectedDay.year &&
            date.month == selectedDay.month &&
            date.day == selectedDay.day;
        final isFuture = date.isAfter(today);
        final count = notifier.completedCount(date);
        final isFull = notifier.isFullyCompleted(date);

        return _DayCell(
          day: day,
          isToday: isToday,
          isSelected: isSelected,
          isFuture: isFuture,
          completedCount: count,
          isFull: isFull,
          onTap: isFuture ? null : () => onDaySelect(date),
        );
      },
    );
  }
}

// ── 날짜 셀 ────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final int completedCount;
  final bool isFull;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.completedCount,
    required this.isFull,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 배경 색상 결정
    Color bgColor;
    Color textColor;
    Border? border;

    if (isFull) {
      // 전체 달성: 진한 녹색 채우기
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isSelected && !isFuture) {
      // 선택된 날: 연한 녹색 채우기
      bgColor = AppColors.primarySurface;
      textColor = AppColors.primary;
    } else {
      bgColor = Colors.transparent;
      textColor = isFuture ? AppColors.borderDefault : AppColors.textPrimary;
    }

    // 오늘이면 테두리 추가 (전체 달성이 아닌 경우)
    if (isToday && !isFull) {
      border = Border.all(color: AppColors.primary, width: 1.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: (isToday || isFull)
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: textColor,
              ),
            ),
            // 부분 달성 도트 (1~3개)
            if (completedCount > 0 && !isFull)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(completedCount, (i) {
                    return Container(
                      width: 3.5,
                      height: 3.5,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 범례 ───────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.primary,
          label: '전체 달성',
          filled: true,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.primary,
          label: '부분 달성',
          filled: false,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.borderDefault,
          label: '미달성',
          filled: false,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool filled;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: filled ? null : Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

// ── 월간 통계 ──────────────────────────────────────────
class _MonthlyStats extends StatelessWidget {
  final DateTime focusedMonth;
  final ChallengeRecordNotifier notifier;

  const _MonthlyStats({
    required this.focusedMonth,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final stats = notifier.monthStats(focusedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(emoji: '📅', value: '${stats.activeDays}일', label: '활동한 날'),
          _VerticalDivider(),
          _StatItem(emoji: '🏆', value: '${stats.fullDays}일', label: '완전 달성'),
          _VerticalDivider(),
          _StatItem(
              emoji: '✅', value: '${stats.totalCompleted}회', label: '총 챌린지'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleSmall),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: AppColors.borderDefault,
    );
  }
}

// ── 선택된 날짜 상세 ────────────────────────────────────
class _DayDetail extends StatelessWidget {
  final DateTime selectedDay;
  final ChallengeRecordNotifier notifier;
  final ValueChanged<int> onToggle;

  const _DayDetail({
    required this.selectedDay,
    required this.notifier,
    required this.onToggle,
  });

  static const List<String> _weekdayLabels = [
    '', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일',
  ];

  @override
  Widget build(BuildContext context) {
    final completed = notifier.completedFor(selectedDay);
    final count = completed.length;
    final total = kDailyChallenges.length;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final isEditable = !selectedDay.isAfter(todayDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedDay.month}월 ${selectedDay.day}일 '
                      '${_weekdayLabels[selectedDay.weekday]}',
                      style: AppTextStyles.titleLarge,
                    ),
                    if (!isEditable)
                      Text(
                        '미래 날짜는 수정할 수 없어요',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              // 완료 배지
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: count == total
                      ? AppColors.primary
                      : count > 0
                          ? AppColors.primarySurface
                          : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count / $total 완료',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: count == total
                        ? Colors.white
                        : count > 0
                            ? AppColors.primary
                            : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 챌린지 목록
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: total,
              itemBuilder: (context, index) {
                final challenge = kDailyChallenges[index];
                final isDone = completed.contains(index);
                return _ChallengeDetailRow(
                  challenge: challenge,
                  isDone: isDone,
                  isEditable: isEditable,
                  onTap: isEditable ? () => onToggle(index) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 챌린지 행 (상세) ────────────────────────────────────
class _ChallengeDetailRow extends StatelessWidget {
  final ChallengeItem challenge;
  final bool isDone;
  final bool isEditable;
  final VoidCallback? onTap;

  const _ChallengeDetailRow({
    required this.challenge,
    required this.isDone,
    required this.isEditable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDone ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? AppColors.primary.withAlpha(80) : AppColors.borderLight,
            width: isDone ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(challenge.emoji,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(challenge.desc, style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 완료 체크 또는 읽기전용 아이콘
            if (isEditable)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? AppColors.primary
                        : AppColors.borderDefault,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 15)
                    : null,
              )
            else
              Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    isDone ? AppColors.primary : AppColors.borderDefault,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
