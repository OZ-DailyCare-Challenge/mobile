import 'package:flutter/material.dart';

/// MyHealthBuddy 디자인 시스템 - 색상 정의
/// GitHub 저장소(OZ-DailyCare-Challenge/frontend) CSS 기준으로 작성
abstract final class AppColors {
  // ── Primary (Green) ────────────────────────────────
  static const Color primary = Color(0xFF4C9A5F);         // 메인 녹색 (#4c9a5f)
  static const Color primaryLight = Color(0xFF6DBA7B);    // 연한 녹색 (#6dba7b)
  static const Color primaryDark = Color(0xFF3A7A4A);     // 진한 녹색
  static const Color primarySurface = Color(0xFFE8F5EA);  // 매우 연한 녹색 배경 (#e8f5ea)

  // ── Background ─────────────────────────────────────
  static const Color background = Color(0xFFF8FBF6);      // 앱 전체 배경 (#f8fbf6)
  static const Color backgroundAlt = Color(0xFFF7FBF8);   // 대체 배경 (#f7fbf8)
  static const Color surface = Color(0xFFFFFFFF);         // 카드·시트 배경
  static const Color surfaceVariant = Color(0xFFF2F7F3);  // 연한 카드 배경

  // ── Hero / Dark Section ────────────────────────────
  static const Color heroDark = Color(0xFF1B442D);        // 히어로 섹션 어두운 녹색 (#1b442d)
  static const Color heroDarker = Color(0xFF143823);      // 히어로 그래디언트 끝 (#143823)

  // ── Text ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111111);     // 본문 기본 텍스트 (#111111)
  static const Color textDark = Color(0xFF213547);        // 어두운 텍스트 (#213547)
  static const Color textDashboard = Color(0xFF1F2F24);   // 대시보드 텍스트 (#1f2f24)
  static const Color textMuted = Color(0xFF6D7C72);       // 보조 텍스트 (#6d7c72)
  static const Color textOnDark = Color(0xFFFFFFFF);      // 어두운 배경 위 텍스트

  // ── Border ─────────────────────────────────────────
  static const Color borderLight = Color(0x334C9A5F);     // 연한 녹색 테두리 (rgba(76,154,95,0.2))
  static const Color borderDefault = Color(0xFFD4E8D8);   // 기본 테두리

  // ── Status ─────────────────────────────────────────
  static const Color statusLow = Color(0xFF4C9A5F);       // 낮은 위험도 (녹색)
  static const Color statusMedium = Color(0xFFF59E0B);    // 중간 위험도 (노란색)
  static const Color statusHigh = Color(0xFFEF4444);      // 높은 위험도 (빨간색)
  static const Color statusInfo = Color(0xFF3B82F6);      // 정보 (파란색)

  // ── Divider / Shadow ───────────────────────────────
  static const Color divider = Color(0xFFE5EDE7);
  static const Color shadow = Color(0x1A4C9A5F);          // 녹색 계열 그림자

  // ── Gradient ───────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroDark, heroDarker],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
}
