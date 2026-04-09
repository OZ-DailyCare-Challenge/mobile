import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 대시보드 페이지
/// 웹: pages/Dashboard/DashboardPage.tsx 대응
/// - 인사 섹션 (닉네임, 연속 달성일)
/// - 건강 점수 카드
/// - 건강 메트릭 (혈압, 혈당, 콜레스테롤, 걸음수)
/// - 일일 챌린지 (4가지)
/// - 친구 기능
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('MyHealthBuddy', style: AppTextStyles.logo),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 인사 섹션 ─────────────────────────
              const _GreetingSection(nickname: '건강이', streakDays: 7),
              const SizedBox(height: 16),

              // ── 건강 점수 카드 ────────────────────
              const _HealthScoreCard(score: 82),
              const SizedBox(height: 16),

              // ── 건강 메트릭 ───────────────────────
              const _HealthMetricsSection(),
              const SizedBox(height: 16),

              // ── 일일 챌린지 ───────────────────────
              const _DailyChallengesSection(),
              const SizedBox(height: 16),

              // ── 친구 피드 ─────────────────────────
              _FriendFeedSection(
                onChallengeTap: () => context.go(AppRoutes.challenge),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── 하단 네비게이션 ────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go(AppRoutes.challenge);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: '챌린지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: '친구',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

// ── 인사 섹션 ──────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String nickname;
  final int streakDays;
  const _GreetingSection({required this.nickname, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, $nickname님 👋',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '오늘도 건강한 하루 보내세요!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '$streakDays일 연속',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 건강 점수 카드 ─────────────────────────────────────
class _HealthScoreCard extends StatelessWidget {
  final int score;
  const _HealthScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 건강 점수',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score점',
                  style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.white24,
                    color: AppColors.primaryLight,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

// ── 건강 메트릭 섹션 ───────────────────────────────────
class _HealthMetricsSection extends StatelessWidget {
  const _HealthMetricsSection();

  static const List<_MetricData> _metrics = [
    _MetricData(icon: Icons.favorite_border, label: '혈압', value: '120/80', unit: 'mmHg', status: 'normal'),
    _MetricData(icon: Icons.water_drop_outlined, label: '공복혈당', value: '95', unit: 'mg/dL', status: 'normal'),
    _MetricData(icon: Icons.bar_chart, label: '콜레스테롤', value: '195', unit: 'mg/dL', status: 'normal'),
    _MetricData(icon: Icons.directions_walk, label: '걸음수', value: '6,234', unit: '걸음', status: 'warning'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('건강 지표', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: _metrics.map((m) => _MetricCard(data: m)).toList(),
        ),
      ],
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String status; // normal | warning | danger
  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

  Color get _statusColor {
    switch (data.status) {
      case 'warning': return AppColors.statusMedium;
      case 'danger':  return AppColors.statusHigh;
      default:        return AppColors.statusLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, color: AppColors.primary, size: 18),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
              ),
              Text(
                '${data.label} · ${data.unit}',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 일일 챌린지 섹션 ───────────────────────────────────
class _DailyChallengesSection extends StatefulWidget {
  const _DailyChallengesSection();

  @override
  State<_DailyChallengesSection> createState() => _DailyChallengeSectionState();
}

class _DailyChallengeSectionState extends State<_DailyChallengesSection> {
  final List<bool> _done = [false, false, false, false];

  static const List<Map<String, dynamic>> _challenges = [
    {'icon': '🚭', 'title': '담배 안 피웠나요?', 'desc': '금연 챌린지'},
    {'icon': '🚶', 'title': '30분 걸었나요?', 'desc': '유산소 운동'},
    {'icon': '💧', 'title': '물 8잔 마셨나요?', 'desc': '수분 섭취'},
    {'icon': '🥦', 'title': '채소 먹었나요?', 'desc': '균형 잡힌 식단'},
  ];

  @override
  Widget build(BuildContext context) {
    final doneCount = _done.where((d) => d).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('오늘의 챌린지', style: AppTextStyles.titleLarge),
            Text(
              '$doneCount/${_challenges.length} 완료',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._challenges.asMap().entries.map(
          (entry) => _ChallengeItem(
            emoji: entry.value['icon'] as String,
            title: entry.value['title'] as String,
            desc: entry.value['desc'] as String,
            isDone: _done[entry.key],
            onToggle: () => setState(() => _done[entry.key] = !_done[entry.key]),
          ),
        ),
      ],
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool isDone;
  final VoidCallback onToggle;

  const _ChallengeItem({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.isDone,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone ? AppColors.primary : AppColors.borderLight,
            width: isDone ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  Text(desc, style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.borderDefault,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 친구 피드 섹션 ─────────────────────────────────────
class _FriendFeedSection extends StatelessWidget {
  final VoidCallback onChallengeTap;
  const _FriendFeedSection({required this.onChallengeTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('친구 챌린지', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: onChallengeTap,
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              const Icon(Icons.people_outline, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                '아직 친구가 없어요',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                '친구를 추가하고 함께 챌린지를 달성해보세요!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('친구 추가'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
