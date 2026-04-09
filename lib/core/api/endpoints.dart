/// MyHealthBuddy API 엔드포인트 정의
/// 웹 저장소(src/api/endpoints.ts) 기준으로 작성
abstract final class Endpoints {
  // ── Base ───────────────────────────────────────────
  /// 환경별 Base URL (.env의 VITE_API_BASE_URL 대응)
  /// 실제 배포 시 변경 필요
  static const String baseUrl = 'https://api.myhealthbuddy.com';
  static const String apiVersion = '/api/v1';

  // ── Auth ───────────────────────────────────────────
  /// Google OAuth 로그인
  static const String loginGoogle = '$apiVersion/auth/login/google';

  /// 액세스 토큰 갱신
  static const String tokenRefresh = '$apiVersion/auth/token/refresh';

  // ── User ───────────────────────────────────────────
  /// 대시보드 데이터 조회
  static const String dashboard = '$apiVersion/users/dashboard';

  /// 프로필 정보 조회
  static const String profile = '$apiVersion/users/profile';

  /// 회원 탈퇴
  static const String withdraw = '$apiVersion/users/withdraw';

  // ── Health ─────────────────────────────────────────
  /// 건강 데이터 제출
  static const String healthInput = '$apiVersion/health/input';

  /// 건강 분석 결과 조회
  static const String healthResult = '$apiVersion/health/result';

  // ── Challenge ──────────────────────────────────────
  /// 챌린지 목록 조회
  static const String challenges = '$apiVersion/challenges';

  /// 챌린지 완료 처리
  static String challengeComplete(String id) =>
      '$apiVersion/challenges/$id/complete';
}
