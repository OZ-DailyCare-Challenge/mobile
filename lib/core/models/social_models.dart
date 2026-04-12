import 'package:flutter/foundation.dart';

// ── 친구 목록 항목 ────────────────────────────────────────

@immutable
class FriendModel {
  final int friendId;
  final String nickname;
  final String? profileImage;

  /// 캐릭터 단계 (1~5)
  final int characterStage;
  final String createdAt;

  const FriendModel({
    required this.friendId,
    required this.nickname,
    this.profileImage,
    required this.characterStage,
    required this.createdAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendId: json['friend_id'] as int,
      nickname: json['nickname'] as String,
      profileImage: json['profile_image'] as String?,
      characterStage: json['character_stage'] as int? ?? 1,
      createdAt: json['created_at'] as String,
    );
  }
}

// ── 받은 친구 요청 ────────────────────────────────────────

@immutable
class FriendRequestModel {
  final int id;
  final int requesterId;
  final String requesterNickname;
  final String? requesterProfileImage;
  final String createdAt;

  const FriendRequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterNickname,
    this.requesterProfileImage,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as int,
      requesterId: json['requester_id'] as int,
      requesterNickname: json['requester_nickname'] as String,
      requesterProfileImage: json['requester_profile_image'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

// ── 사용자 검색 결과 ──────────────────────────────────────

@immutable
class SearchUserModel {
  final int id;
  final String nickname;
  final String? profileImage;
  final int characterStage;
  final bool isFriend;

  const SearchUserModel({
    required this.id,
    required this.nickname,
    this.profileImage,
    required this.characterStage,
    required this.isFriend,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      profileImage: json['profile_image'] as String?,
      characterStage: json['character_stage'] as int? ?? 1,
      isFriend: json['is_friend'] as bool? ?? false,
    );
  }
}
