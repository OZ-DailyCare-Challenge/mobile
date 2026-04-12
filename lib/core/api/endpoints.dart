/// MyHealthBuddy API 엔드포인트 정의
abstract final class Endpoints {
  // ── Base ───────────────────────────────────────────
  static const String baseUrl = 'http://54.180.116.239';
  static const String apiVersion = '/api/v1';

  // ── Auth (SEC) ─────────────────────────────────────
  /// POST {code} → access_token + user
  static const String loginGoogle = '$apiVersion/auth/login/google';

  /// GET (refresh_token cookie) → access_token
  static const String tokenRefresh = '$apiVersion/auth/token/refresh';

  // ── User (USER) ────────────────────────────────────
  /// GET → dashboard summary
  static const String dashboard = '$apiVersion/users/dashboard';

  /// PUT {gender, birth_year} → user profile (최초 1회)
  static const String profileInitial = '$apiVersion/users/profile/initial';

  /// PATCH {nickname?, profile_image?, birth_year?} → user profile
  static const String profile = '$apiVersion/users/profile';

  // ── Health Records (HLTH) ──────────────────────────
  /// POST → health record
  static const String healthRecords = '$apiVersion/health/records';

  /// GET / PATCH / DELETE
  static String healthRecord(int id) => '$apiVersion/health/records/$id';

  // ── AI Analysis (HLTH) ────────────────────────────
  /// POST (JWT) → analysis result or task_id
  static String analysis(int recordId) =>
      '$apiVersion/health/analysis/$recordId';

  /// POST (no auth) → analysis result or task_id
  static const String analysisGuest = '$apiVersion/health/analysis/guest';

  /// GET → long-poll 최대 30초 대기
  static String analysisWait(String taskId) =>
      '$apiVersion/health/analysis/$taskId/wait';

  /// GET → 즉시 현재 상태 반환
  static String analysisStatus(String taskId) =>
      '$apiVersion/health/analysis/$taskId';

  // ── Social – Friends (SOCL) ────────────────────────
  /// GET → friend list
  static const String friends = '$apiVersion/social/friends';

  /// DELETE {friend_id}
  static String friend(int friendId) =>
      '$apiVersion/social/friends/$friendId';

  /// GET → received pending requests
  static const String friendRequests = '$apiVersion/social/friends/requests';

  /// POST {receiver_id}
  static String sendFriendRequest(int receiverId) =>
      '$apiVersion/social/friends/request/$receiverId';

  /// PATCH → accept
  static String acceptRequest(int requestId) =>
      '$apiVersion/social/friends/requests/$requestId/accept';

  /// PATCH → reject
  static String rejectRequest(int requestId) =>
      '$apiVersion/social/friends/requests/$requestId/reject';

  /// GET ?nickname=... → search users (max 20)
  static const String userSearch = '$apiVersion/social/users/search';
}
