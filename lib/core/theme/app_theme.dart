import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// MyHealthBuddy 글로벌 ThemeData
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',

        // ── ColorScheme ────────────────────────────────
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnDark,
          primaryContainer: AppColors.primarySurface,
          onPrimaryContainer: AppColors.heroDark,
          secondary: AppColors.primaryLight,
          onSecondary: AppColors.textOnDark,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textMuted,
          outline: AppColors.borderDefault,
          error: AppColors.statusHigh,
          onError: AppColors.textOnDark,
        ),

        // ── Scaffold ───────────────────────────────────
        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ─────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.shadow,
          titleTextStyle: AppTextStyles.titleLarge,
          centerTitle: false,
        ),

        // ── Card ───────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── ElevatedButton ─────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnDark,
            textStyle: AppTextStyles.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),

        // ── OutlinedButton ─────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // ── TextButton ─────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // ── InputDecoration ────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDefault),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDefault),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.statusHigh),
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),

        // ── Divider ────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── NavigationBar (Material 3) ─────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primarySurface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.textMuted, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            );
          }),
        ),

        // ── Chip ───────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primarySurface,
          labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ── TextTheme ──────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          displaySmall: AppTextStyles.displaySmall,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),
      );
}
