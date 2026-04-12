import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/auth_service.dart';
import '../models/user_model.dart';

/// 인증 상태
enum AuthStatus {
  unauthenticated,
  guest,
  authenticated,
}

/// 인증 상태 모델
@immutable
class AuthState {
  final AuthStatus status;
  final UserModel? user;

  /// 신규 가입 여부 (초기 프로필 설정 화면 진입 판단용)
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.isNewUser = false,
  });

  bool get isGuest => status == AuthStatus.guest;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// 대시보드·인사에서 사용할 닉네임
  String get nickname => user?.nickname ?? '게스트';
}

/// 인증 상태 노티파이어
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _restoreSession();
  }

  /// 앱 재시작 시 저장된 세션 복원
  Future<void> _restoreSession() async {
    final session = await _authService.restoreSession();
    if (session.userId != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: session.userId!,
          email: '',
          nickname: session.nickname ?? '',
        ),
      );
    }
  }

  /// 비로그인 게스트로 계속
  void continueAsGuest() {
    state = const AuthState(status: AuthStatus.guest);
  }

  /// Google 로그인
  /// google_sign_in으로 serverAuthCode 획득 → 백엔드로 전달
  Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // serverClientId: 'YOUR_BACKEND_CLIENT_ID', // 실제 배포 시 설정
    );

    final account = await googleSignIn.signIn();
    if (account == null) return; // 취소

    // serverAuthCode: 서버 측 OAuth 교환용 코드
    final serverAuthCode = account.serverAuthCode;
    if (serverAuthCode == null) {
      // serverAuthCode가 없는 환경(시뮬레이터 등)에서는 임시 처리
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: 0,
          email: account.email,
          nickname: account.displayName ?? account.email.split('@').first,
        ),
        isNewUser: false,
      );
      return;
    }

    final result = await _authService.loginWithGoogle(serverAuthCode);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: result.user,
      isNewUser: result.isNewUser,
    );
  }

  /// 초기 프로필 설정 완료 후 상태 업데이트
  Future<void> completeInitialProfile({
    required String gender,
    required int birthYear,
    String? nickname,
  }) async {
    final updatedUser = await _authService.setInitialProfile(
      gender: gender,
      birthYear: birthYear,
      nickname: nickname,
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      user: updatedUser,
      isNewUser: false,
    );
  }

  /// 프로필 수정
  Future<void> updateProfile({
    String? nickname,
    String? profileImage,
    int? birthYear,
  }) async {
    final updatedUser = await _authService.updateProfile(
      nickname: nickname,
      profileImage: profileImage,
      birthYear: birthYear,
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      user: updatedUser,
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

/// 전역 AuthProvider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
