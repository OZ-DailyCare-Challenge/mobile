import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/challenge/challenge_record_provider.dart';
import '../../core/friend/friend_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 대시보드 페이지
/// - 인사 섹션 (닉네임, 연속 달성일)
/// - 게스트 배너 (비로그인 시)
/// - 건강 점수 카드
/// - 건강 메트릭 (혈압, 혈당, 콜레스테롤, 걸음수)
/// - 일일 챌린지 (4가지)
/// - 친구 기능
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

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
            onPressed: () => _onProfileTap(context, auth),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 게스트 배너 (비로그인 시만) ──────────
              if (auth.isGuest) ...[
                _GuestBanner(
                  onLoginTap: () => context.go(AppRoutes.login),
                ),
                const SizedBox(height: 16),
              ],

              // ── 인사 섹션 ─────────────────────────
              _GreetingSection(
                nickname: auth.nickname,
                streakDays: auth.isGuest ? 0 : 7,
                isGuest: auth.isGuest,
              ),
              const SizedBox(height: 16),

              // ── 건강 점수 카드 ────────────────────
              _HealthScoreCard(score: auth.isGuest ? null : 82),
              const SizedBox(height: 16),

              // ── 건강 메트릭 ───────────────────────
              _HealthMetricsSection(isGuest: auth.isGuest),
              const SizedBox(height: 16),

              // ── 일일 챌린지 ───────────────────────
              const _DailyChallengesSection(),
              const SizedBox(height: 16),

              // ── 친구 피드 ─────────────────────────
              _FriendFeedSection(
                isGuest: auth.isGuest,
                onChallengeTap: () => context.go(AppRoutes.challenge),
                onLoginTap: () => context.go(AppRoutes.login),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── 하단 네비게이션 (Material 3) ──────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go(AppRoutes.challenge);
          if (index == 2) {
            if (auth.isGuest) {
              _showLoginBottomSheet(context);
            } else {
              context.go(AppRoutes.friends);
            }
          }
          if (index == 3) _onProfileTap(context, auth);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: '챌린지',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: '친구',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  void _onProfileTap(BuildContext context, AuthState auth) {
    if (auth.isGuest) {
      _showLoginBottomSheet(context);
    }
  }

  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LoginPromptSheet(),
    );
  }
}

// ── 게스트 배너 ────────────────────────────────────────
class _GuestBanner extends StatelessWidget {
  final VoidCallback onLoginTap;
  const _GuestBanner({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '로그인하면 건강 데이터가 저장됩니다',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.heroDark,
              ),
            ),
          ),
          TextButton(
            onPressed: onLoginTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('로그인'),
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
  final bool isGuest;
  const _GreetingSection({
    required this.nickname,
    required this.streakDays,
    required this.isGuest,
  });

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
              isGuest ? '오늘 건강 정보를 입력해보세요!' : '오늘도 건강한 하루 보내세요!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        if (!isGuest)
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
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
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
  /// null이면 게스트 (점수 미입력 상태)
  final int? score;
  const _HealthScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      // 게스트: 건강 정보 입력 유도 카드
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
                    '건강 점수',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '건강 정보를\n입력해주세요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.healthInput),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.heroDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('지금 입력하기'),
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
              child: const Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      );
    }

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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score점',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score! / 100,
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
  final bool isGuest;
  const _HealthMetricsSection({required this.isGuest});

  static const List<_MetricData> _metrics = [
    _MetricData(
      icon: Icons.favorite_border,
      label: '혈압',
      value: '120/80',
      unit: 'mmHg',
      status: 'normal',
    ),
    _MetricData(
      icon: Icons.water_drop_outlined,
      label: '공복혈당',
      value: '95',
      unit: 'mg/dL',
      status: 'normal',
    ),
    _MetricData(
      icon: Icons.bar_chart,
      label: '콜레스테롤',
      value: '195',
      unit: 'mg/dL',
      status: 'normal',
    ),
    _MetricData(
      icon: Icons.directions_walk,
      label: '걸음수',
      value: '6,234',
      unit: '걸음',
      status: 'warning',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('건강 지표', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        if (isGuest)
          _GuestMetricPlaceholder(
            onTap: () => context.go(AppRoutes.healthInput),
          )
        else
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

class _GuestMetricPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestMetricPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              '건강 정보를 입력하면\n지표를 확인할 수 있어요',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              '건강 정보 입력하기 →',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String status;
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
      case 'warning':
        return AppColors.statusMedium;
      case 'danger':
        return AppColors.statusHigh;
      default:
        return AppColors.statusLow;
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
class _DailyChallengesSection extends ConsumerWidget {
  const _DailyChallengesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(challengeRecordProvider);
    final notifier = ref.read(challengeRecordProvider.notifier);
    final today = DateTime.now();
    final completed = notifier.completedFor(today);
    final doneCount = completed.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('오늘의 챌린지', style: AppTextStyles.titleLarge),
            Row(
              children: [
                Text(
                  '$doneCount/${kDailyChallenges.length} 완료',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                // 캘린더 진입 버튼
                GestureDetector(
                  onTap: () => context.push(AppRoutes.calendar),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...kDailyChallenges.asMap().entries.map(
          (entry) => _ChallengeItem(
            emoji: entry.value.emoji,
            title: entry.value.title,
            desc: entry.value.desc,
            isDone: completed.contains(entry.key),
            onToggle: () => notifier.toggle(today, entry.key),
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
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
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
                  color:
                      isDone ? AppColors.primary : AppColors.borderDefault,
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
class _FriendFeedSection extends ConsumerWidget {
  final bool isGuest;
  final VoidCallback onChallengeTap;
  final VoidCallback onLoginTap;

  const _FriendFeedSection({
    required this.isGuest,
    required this.onChallengeTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendProvider).friends;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('친구 챌린지', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: isGuest
                  ? null
                  : () => context.go(AppRoutes.friends),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isGuest)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: _GuestFriendPlaceholder(onLoginTap: onLoginTap),
          )
        else if (friends.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 40,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  '아직 친구가 없어요',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '친구를 추가하고 함께 챌린지를 달성해보세요!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go(
                    '${AppRoutes.friends}?tab=2',
                  ),
                  icon: const Icon(Icons.person_search_rounded, size: 18),
                  label: const Text('친구 찾기'),
                ),
              ],
            ),
          )
        else
          // 친구 최대 3명 미리보기
          Column(
            children: friends.take(3).map((friend) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        friend.nickname.isNotEmpty
                            ? friend.nickname.characters.first
                            : '?',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(friend.nickname,
                              style: AppTextStyles.titleSmall),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                '레벨 ${friend.characterStage}',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _GuestFriendPlaceholder extends StatelessWidget {
  final VoidCallback onLoginTap;
  const _GuestFriendPlaceholder({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 40,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 12),
        Text(
          '로그인이 필요한 기능이에요',
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          '로그인하면 친구와 챌린지를\n함께 달성할 수 있어요!',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onLoginTap,
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('로그인하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ── 로그인 유도 바텀시트 ────────────────────────────────
class _LoginPromptSheet extends StatelessWidget {
  const _LoginPromptSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '로그인이 필요해요',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '로그인하면 건강 데이터 저장, 친구 기능,\n맞춤 분석 등을 사용할 수 있어요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('로그인하기'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '나중에 하기',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
