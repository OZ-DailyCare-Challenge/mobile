import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/landing/landing_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/health_input/health_input_page.dart';
import '../../features/result/result_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/challenge/challenge_page.dart';
import '../../features/calendar/challenge_calendar_page.dart';
import '../../features/friends/friends_page.dart';

/// 앱 라우트 경로 상수
/// 웹 저장소 경로와 동일하게 맞춤
abstract final class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String healthInput = '/health-input';
  static const String result = '/result';
  static const String dashboard = '/dashboard';
  static const String challenge = '/challenge';
  static const String calendar = '/calendar';
  static const String friends = '/friends';
}

/// GoRouter 인스턴스 - Riverpod Provider로 제공
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.landing,
    debugLogDiagnostics: true, // 개발 중 라우팅 로그 출력

    // ── 에러 페이지 ──────────────────────────────────
    errorBuilder: (context, state) => _ErrorPage(error: state.error),

    // ── 라우트 정의 ──────────────────────────────────
    routes: [
      // 1. 랜딩 페이지
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),

      // 2. 로그인 (Google OAuth)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // 3. 건강 데이터 입력
      GoRoute(
        path: AppRoutes.healthInput,
        name: 'healthInput',
        builder: (context, state) => const HealthInputPage(),
      ),

      // 4. 분석 결과
      GoRoute(
        path: AppRoutes.result,
        name: 'result',
        builder: (context, state) => const ResultPage(),
      ),

      // 5. 대시보드 (메인)
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // 6. 챌린지
      GoRoute(
        path: AppRoutes.challenge,
        name: 'challenge',
        builder: (context, state) => const ChallengePage(),
      ),

      // 7. 챌린지 달성 캘린더
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const ChallengeCalendarPage(),
      ),

      // 8. 친구
      GoRoute(
        path: AppRoutes.friends,
        name: 'friends',
        builder: (context, state) {
          final tab = int.tryParse(
                state.uri.queryParameters['tab'] ?? '0',
              ) ??
              0;
          return FriendsPage(initialTab: tab);
        },
      ),
    ],
  );
});

/// 라우팅 에러 페이지
class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('페이지를 찾을 수 없습니다.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '알 수 없는 오류',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.landing),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
