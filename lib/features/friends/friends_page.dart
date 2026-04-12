import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/friend/friend_provider.dart';
import '../../core/models/social_models.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 친구 페이지
/// TabBar 3개:
///   0. 친구 목록  - 친구 카드 (캐릭터 단계) + 삭제
///   1. 친구 요청  - 받은 요청 (수락/거절) + 보낸 요청
///   2. 친구 검색  - 닉네임 검색 + 요청 보내기
class FriendsPage extends ConsumerStatefulWidget {
  final int initialTab;
  const FriendsPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendState = ref.watch(friendProvider);
    final pendingCount = friendState.receivedRequests.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('친구'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            const Tab(text: '친구 목록'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('요청'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 4),
                    _Badge(count: pendingCount),
                  ],
                ],
              ),
            ),
            const Tab(text: '검색'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FriendListTab(),
          _RequestTab(),
          _SearchTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) context.go(AppRoutes.dashboard);
          if (index == 1) context.go(AppRoutes.challenge);
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
            icon: Icon(Icons.people_rounded),
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
}

// ── 배지 ───────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.statusHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// 탭 1: 친구 목록
// ═══════════════════════════════════════════════════════
class _FriendListTab extends ConsumerWidget {
  const _FriendListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendProvider);
    final notifier = ref.read(friendProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.friends.isEmpty) {
      return const _EmptyState(
        emoji: '👥',
        message: '아직 친구가 없어요',
        subMessage: '검색 탭에서 친구를 찾아보세요!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.friends.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final friend = state.friends[index];
        return _FriendCard(
          friend: friend,
          onDelete: () => _confirmDelete(context, friend, notifier),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    FriendModel friend,
    FriendNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteConfirmSheet(
        nickname: friend.nickname,
        onConfirm: () => notifier.removeFriend(friend.friendId),
      ),
    );
  }
}

// ── 친구 카드 ──────────────────────────────────────────
class _FriendCard extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onDelete;
  const _FriendCard({required this.friend, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _Avatar(nickname: friend.nickname),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.nickname, style: AppTextStyles.titleSmall),
                const SizedBox(height: 6),
                // 캐릭터 단계 표시
                _StatChip(
                  icon: Icons.star_rounded,
                  label: '레벨 ${friend.characterStage}',
                  color: _stageColor(friend.characterStage),
                ),
              ],
            ),
          ),

          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.person_remove_outlined,
                size: 20, color: AppColors.textMuted),
            onPressed: onDelete,
            tooltip: '친구 삭제',
          ),
        ],
      ),
    );
  }

  Color _stageColor(int stage) {
    const colors = [
      AppColors.textMuted,
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      AppColors.statusHigh,
    ];
    return colors[(stage - 1).clamp(0, colors.length - 1)];
  }
}

// ─── 삭제 확인 바텀시트 ────────────────────────────────
class _DeleteConfirmSheet extends StatelessWidget {
  final String nickname;
  final VoidCallback onConfirm;
  const _DeleteConfirmSheet({
    required this.nickname,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          const Icon(Icons.person_remove_outlined,
              size: 44, color: AppColors.statusHigh),
          const SizedBox(height: 16),
          Text(
            '$nickname 님을\n친구 목록에서 삭제할까요?',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '삭제하면 서로의 챌린지를 볼 수 없어요.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusHigh,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('삭제'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// 탭 2: 친구 요청
// ═══════════════════════════════════════════════════════
class _RequestTab extends ConsumerWidget {
  const _RequestTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendProvider);
    final notifier = ref.read(friendProvider.notifier);
    final received = state.receivedRequests;
    final sentCount = state.sentRequestIds.length;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (received.isEmpty && sentCount == 0) {
      return const _EmptyState(
        emoji: '📬',
        message: '요청이 없어요',
        subMessage: '검색 탭에서 친구에게 요청을 보내보세요!',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (received.isNotEmpty) ...[
          _SectionHeader(title: '받은 요청', count: received.length),
          const SizedBox(height: 10),
          ...received.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReceivedRequestCard(
                request: req,
                onAccept: () => notifier.acceptRequest(req.id),
                onReject: () => notifier.rejectRequest(req.id),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (sentCount > 0) ...[
          _SectionHeader(title: '보낸 요청', count: sentCount),
          const SizedBox(height: 10),
          ...state.sentRequestIds.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SentRequestCard(userId: id),
            ),
          ),
        ],
      ],
    );
  }
}

// ── 받은 요청 카드 ─────────────────────────────────────
class _ReceivedRequestCard extends StatelessWidget {
  final FriendRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _ReceivedRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  String _timeAgo(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              _Avatar(nickname: request.requesterNickname),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.requesterNickname,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(request.createdAt),
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.borderDefault),
                    foregroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('거절'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('수락'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 보낸 요청 카드 ─────────────────────────────────────
class _SentRequestCard extends StatelessWidget {
  final int userId;
  const _SentRequestCard({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _Avatar(nickname: '#$userId'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사용자 #$userId', style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '요청 대기 중',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.statusMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// 탭 3: 친구 검색
// ═══════════════════════════════════════════════════════
class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final TextEditingController _controller = TextEditingController();
  List<SearchUserModel> _results = [];
  bool _searched = false;
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(friendProvider.notifier).search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _searched = true;
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // sentRequestIds 변경 시 버튼 갱신
    ref.watch(friendProvider.select((s) => s.sentRequestIds));

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _controller,
            autofocus: false,
            textInputAction: TextInputAction.search,
            onSubmitted: _search,
            onChanged: (v) {
              if (v.isEmpty) {
                setState(() {
                  _results = [];
                  _searched = false;
                });
              } else {
                _search(v);
              }
            },
            decoration: InputDecoration(
              hintText: '닉네임으로 검색',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _searched = false;
                        });
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        Expanded(
          child: _searching
              ? const Center(child: CircularProgressIndicator())
              : _searched
                  ? _results.isEmpty
                      ? const _EmptyState(
                          emoji: '🔍',
                          message: '검색 결과가 없어요',
                          subMessage: '다른 닉네임으로 검색해보세요',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _results.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              _SearchResultCard(user: _results[i]),
                        )
                  : _SearchHint(),
        ),
      ],
    );
  }
}

// ── 검색 결과 카드 ─────────────────────────────────────
class _SearchResultCard extends ConsumerWidget {
  final SearchUserModel user;
  const _SearchResultCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentIds = ref.watch(friendProvider.select((s) => s.sentRequestIds));
    final notifier = ref.read(friendProvider.notifier);
    final hasSent = sentIds.contains(user.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _Avatar(nickname: user.nickname),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nickname, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                _StatChip(
                  icon: Icons.star_rounded,
                  label: '레벨 ${user.characterStage}',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RequestButton(
            isFriend: user.isFriend,
            hasSent: hasSent,
            userId: user.id,
            notifier: notifier,
          ),
        ],
      ),
    );
  }
}

// ── 친구 요청 버튼 (상태별) ────────────────────────────
class _RequestButton extends StatelessWidget {
  final bool isFriend;
  final bool hasSent;
  final int userId;
  final FriendNotifier notifier;
  const _RequestButton({
    required this.isFriend,
    required this.hasSent,
    required this.userId,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    if (isFriend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '친구',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (hasSent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Text(
          '요청 중',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => notifier.sendRequest(userId),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        '친구 추가',
        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }
}

// ── 검색 힌트 ──────────────────────────────────────────
class _SearchHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search_rounded,
              size: 60, color: AppColors.borderDefault),
          const SizedBox(height: 16),
          Text(
            '닉네임으로 친구를 찾아보세요',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text('예: 달리는호랑이, 건강지킴이', style: AppTextStyles.bodySmall),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── 공통 위젯 ──────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String nickname;
  const _Avatar({required this.nickname});

  Color _avatarColor() {
    const colors = [
      Color(0xFF4C9A5F),
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ];
    if (nickname.isEmpty) return colors[0];
    return colors[nickname.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isNotEmpty ? nickname.characters.first : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: _avatarColor().withAlpha(40),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _avatarColor(),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String message;
  final String subMessage;
  const _EmptyState({
    required this.emoji,
    required this.message,
    required this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(message,
              style:
                  AppTextStyles.titleSmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(subMessage, style: AppTextStyles.bodySmall),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
