import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'endpoints.dart';
import '../models/social_models.dart';

class SocialService {
  final ApiClient _client;

  SocialService(this._client);

  // ── 친구 목록 ─────────────────────────────────────────

  /// GET /api/v1/social/friends
  Future<List<FriendModel>> getFriends() async {
    final resp = await _client.get(Endpoints.friends);
    final data = resp.data as Map<String, dynamic>;
    final list = data['friends'] as List<dynamic>;
    return list
        .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// DELETE /api/v1/social/friends/{friend_id}
  Future<void> deleteFriend(int friendId) async {
    await _client.delete(Endpoints.friend(friendId));
  }

  // ── 친구 요청 ─────────────────────────────────────────

  /// GET /api/v1/social/friends/requests
  Future<List<FriendRequestModel>> getReceivedRequests() async {
    final resp = await _client.get(Endpoints.friendRequests);
    final data = resp.data as Map<String, dynamic>;
    final list = data['requests'] as List<dynamic>;
    return list
        .map((e) => FriendRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/social/friends/request/{receiver_id}
  /// 반환: request_id
  Future<int> sendFriendRequest(int receiverId) async {
    final resp =
        await _client.post(Endpoints.sendFriendRequest(receiverId));
    final data = resp.data as Map<String, dynamic>;
    return data['request_id'] as int;
  }

  /// PATCH /api/v1/social/friends/requests/{request_id}/accept
  Future<void> acceptRequest(int requestId) async {
    await _client.patch(Endpoints.acceptRequest(requestId));
  }

  /// PATCH /api/v1/social/friends/requests/{request_id}/reject
  Future<void> rejectRequest(int requestId) async {
    await _client.patch(Endpoints.rejectRequest(requestId));
  }

  // ── 사용자 검색 ───────────────────────────────────────

  /// GET /api/v1/social/users/search?nickname=...
  Future<List<SearchUserModel>> searchUsers(String nickname) async {
    final resp = await _client.get(
      Endpoints.userSearch,
      queryParameters: {'nickname': nickname},
    );
    final data = resp.data as Map<String, dynamic>;
    final list = data['users'] as List<dynamic>;
    return list
        .map((e) => SearchUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final socialServiceProvider = Provider<SocialService>((ref) {
  return SocialService(ref.read(apiClientProvider));
});
