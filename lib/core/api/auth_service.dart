import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  /// Google OAuth 인가 코드로 로그인/회원가입
  /// serverAuthCode → POST /api/v1/auth/login/google
  /// 반환: (user, isNewUser)
  Future<({UserModel user, bool isNewUser})> loginWithGoogle(
      String serverAuthCode) async {
    final resp = await _client.post(
      Endpoints.loginGoogle,
      data: {'code': serverAuthCode},
    );

    final data = resp.data as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final isNewUser = data['is_new_user'] as bool? ?? false;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    // 토큰 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.accessToken, token);
    await prefs.setInt(StorageKeys.userId, user.id);
    await prefs.setString(StorageKeys.userNickname, user.nickname);

    return (user: user, isNewUser: isNewUser);
  }

  /// 초기 프로필 설정 (신규 가입자 최초 1회)
  /// PUT /api/v1/users/profile/initial
  Future<UserModel> setInitialProfile({
    required String gender,
    required int birthYear,
    String? nickname,
  }) async {
    final body = <String, dynamic>{
      'gender': gender,
      'birth_year': birthYear,
      'nickname': ?nickname,
    };
    final resp = await _client.put(Endpoints.profileInitial, data: body);
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 프로필 수정
  /// PATCH /api/v1/users/profile
  Future<UserModel> updateProfile({
    String? nickname,
    String? profileImage,
    int? birthYear,
  }) async {
    final body = <String, dynamic>{
      'nickname': ?nickname,
      'profile_image': ?profileImage,
      'birth_year': ?birthYear,
    };
    final resp = await _client.patch(Endpoints.profile, data: body);
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// 저장된 사용자 정보 복원 (앱 재시작 시)
  Future<({int? userId, String? nickname})> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      return (userId: null, nickname: null);
    }
    return (
      userId: prefs.getInt(StorageKeys.userId),
      nickname: prefs.getString(StorageKeys.userNickname),
    );
  }

  /// 로그아웃 (로컬 토큰 삭제)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userNickname);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});
