import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/social_service.dart';
import '../models/social_models.dart';

// ── 상태 ───────────────────────────────────────────────

@immutable
class FriendState {
  final List<FriendModel> friends;
  final List<FriendRequestModel> receivedRequests;

  /// 내가 요청을 보낸 상대방 ID 집합 (로컬 낙관적 업데이트용)
  final Set<int> sentRequestIds;

  final bool isLoading;
  final String? error;

  const FriendState({
    this.friends = const [],
    this.receivedRequests = const [],
    this.sentRequestIds = const {},
    this.isLoading = false,
    this.error,
  });

  FriendState copyWith({
    List<FriendModel>? friends,
    List<FriendRequestModel>? receivedRequests,
    Set<int>? sentRequestIds,
    bool? isLoading,
    String? error,
  }) {
    return FriendState(
      friends: friends ?? this.friends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequestIds: sentRequestIds ?? this.sentRequestIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── 노티파이어 ─────────────────────────────────────────

class FriendNotifier extends StateNotifier<FriendState> {
  final SocialService _service;

  FriendNotifier(this._service) : super(const FriendState()) {
    loadAll();
  }

  /// 친구 목록 + 받은 요청 동시 로드
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getFriends(),
        _service.getReceivedRequests(),
      ]);
      state = state.copyWith(
        friends: results[0] as List<FriendModel>,
        receivedRequests: results[1] as List<FriendRequestModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── 검색 ──────────────────────────────────────────

  /// 닉네임 검색 → SearchUserModel 리스트 반환 (상태 저장 안 함)
  Future<List<SearchUserModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    return _service.searchUsers(query.trim());
  }

  // ── 친구 요청 보내기 ──────────────────────────────

  Future<void> sendRequest(int userId) async {
    // 낙관적 업데이트
    state = state.copyWith(
      sentRequestIds: {...state.sentRequestIds, userId},
    );
    try {
      await _service.sendFriendRequest(userId);
    } catch (e) {
      // 롤백
      state = state.copyWith(
        sentRequestIds: state.sentRequestIds.difference({userId}),
        error: e.toString(),
      );
    }
  }

  // ── 요청 수락 ─────────────────────────────────────

  Future<void> acceptRequest(int requestId) async {
    try {
      await _service.acceptRequest(requestId);
      // 목록 갱신
      await loadAll();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── 요청 거절 ─────────────────────────────────────

  Future<void> rejectRequest(int requestId) async {
    // 낙관적 업데이트
    state = state.copyWith(
      receivedRequests:
          state.receivedRequests.where((r) => r.id != requestId).toList(),
    );
    try {
      await _service.rejectRequest(requestId);
    } catch (e) {
      // 실패 시 재로드
      await loadAll();
      state = state.copyWith(error: e.toString());
    }
  }

  // ── 친구 삭제 ─────────────────────────────────────

  Future<void> removeFriend(int friendId) async {
    // 낙관적 업데이트
    state = state.copyWith(
      friends: state.friends.where((f) => f.friendId != friendId).toList(),
    );
    try {
      await _service.deleteFriend(friendId);
    } catch (e) {
      // 실패 시 재로드
      await loadAll();
      state = state.copyWith(error: e.toString());
    }
  }
}

final friendProvider =
    StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  return FriendNotifier(ref.read(socialServiceProvider));
});
