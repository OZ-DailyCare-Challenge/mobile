import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 챌린지 페이지
/// 웹: pages/Challenge/ChallengePage.tsx 대응
/// - 전체 챌린지 목록
/// - 카테고리 필터
/// - 챌린지 카드 (진행률, 참여 인원)
class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  int _selectedCategory = 0;

  static const List<String> _categories = [
    '전체', '운동', '식단', '수면', '금연', '수분',
  ];

  // TODO: API 연동
  static const List<Map<String, dynamic>> _challenges = [
    {
      'emoji': '🚶',
      'title': '매일 30분 걷기',
      'desc': '꾸준한 유산소 운동으로 심혈관 건강을 지켜요',
      'category': '운동',
      'participants': 1284,
      'progress': 0.6,
      'joined': true,
    },
    {
      'emoji': '💧',
      'title': '하루 물 2L 마시기',
      'desc': '충분한 수분 섭취로 신진대사를 활발하게',
      'category': '수분',
      'participants': 987,
      'progress': 0.4,
      'joined': false,
    },
    {
      'emoji': '🥗',
      'title': '채소 반찬 2가지 먹기',
      'desc': '식이섬유로 콜레스테롤과 혈당을 관리해요',
      'category': '식단',
      'participants': 743,
      'progress': 0.0,
      'joined': false,
    },
    {
      'emoji': '🚭',
      'title': '하루 금연 챌린지',
      'desc': '오늘 하루 담배 없이 건강하게 지내봐요',
      'category': '금연',
      'participants': 532,
      'progress': 1.0,
      'joined': true,
    },
    {
      'emoji': '😴',
      'title': '11시 이전 취침하기',
      'desc': '규칙적인 수면으로 면역력과 회복력을 높여요',
      'category': '수면',
      'participants': 421,
      'progress': 0.0,
      'joined': false,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 0) return _challenges;
    final cat = _categories[_selectedCategory];
    return _challenges.where((c) => c['category'] == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('건강 챌린지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 카테고리 필터 ─────────────────────
            _CategoryFilter(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (i) => setState(() => _selectedCategory = i),
            ),

            // ── 챌린지 목록 ───────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _ChallengeCard(data: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),

      // ── 하단 네비게이션 ────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go(AppRoutes.dashboard);
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

// ── 카테고리 필터 ──────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onSelect;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderDefault,
                ),
              ),
              child: Text(
                categories[i],
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 챌린지 카드 ────────────────────────────────────────
class _ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ChallengeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isJoined = data['joined'] as bool;
    final progress = data['progress'] as double;
    final participants = data['participants'] as int;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJoined ? AppColors.borderLight : AppColors.borderDefault,
          width: isJoined ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 아이콘 + 제목 + 참여 여부
          Row(
            children: [
              Text(data['emoji'] as String, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'] as String, style: AppTextStyles.titleSmall),
                    Text(data['desc'] as String, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isJoined)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '참여중',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),

          // 참여 중인 경우 진행률 바 표시
          if (isJoined && progress > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.borderDefault,
                      color: progress >= 1.0 ? AppColors.statusLow : AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // 하단: 참여자 수 + 참여/취소 버튼
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${_formatCount(participants)}명 참여 중',
                style: AppTextStyles.labelSmall,
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: isJoined
                    ? OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          side: const BorderSide(color: AppColors.borderDefault),
                          foregroundColor: AppColors.textMuted,
                        ),
                        child: const Text('포기하기'),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('참여하기'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

// ── 빈 상태 ────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 56, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            '해당 카테고리의 챌린지가 없어요',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
