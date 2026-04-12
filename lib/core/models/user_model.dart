import 'package:flutter/foundation.dart';

/// 로그인 / 프로필 API 응답의 사용자 모델
@immutable
class UserModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImage;
  final String? gender; // 'M' | 'F'
  final int? age;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
    this.gender,
    this.age,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profile_image'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
    );
  }

  UserModel copyWith({
    String? nickname,
    String? profileImage,
    String? gender,
    int? age,
  }) {
    return UserModel(
      id: id,
      email: email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }
}
