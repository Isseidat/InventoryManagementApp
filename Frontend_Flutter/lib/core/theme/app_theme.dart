import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bảng màu token chuẩn — KHÔNG dùng thuần #000 hay #FFF
class AppColors {
  // ── LIGHT MODE ────────────────────────────────────────────────
  static const lightBgPrimary   = Color(0xFFF0F2F7); // nền chính - xanh xám nhạt
  static const lightBgCard      = Color(0xFFFFFFFF); // card (trắng tinh vẫn ok cho card)
  static const lightBgSidebar   = Color(0xFFF8FAFC); // sidebar sáng
  static const lightBgTopbar    = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecond  = Color(0xFF64748B);
  static const lightBorder      = Color(0xFFE2E8F0);

  // ── DARK MODE (GitHub-style) ───────────────────────────────────
  static const darkBgPrimary    = Color(0xFF0D1117); // nền chính
  static const darkBgCard       = Color(0xFF21262D); // card
  static const darkBgSidebar    = Color(0xFF161B22); // sidebar
  static const darkBgTopbar     = Color(0xFF161B22);
  static const darkTextPrimary  = Color(0xFFE6EDF3);
  static const darkTextSecond   = Color(0xFF8B949E);
  static const darkBorder       = Color(0xFF30363D);

  // ── ACCENT (chung 2 mode) ─────────────────────────────────────
  static const accentLight      = Color(0xFF6366F1); // indigo
  static const accentDark       = Color(0xFF818CF8); // indigo sáng hơn
  static const accentGreen      = Color(0xFF10B981);
  static const accentOrange     = Color(0xFFF59E0B);
  static const accentRed        = Color(0xFFEF4444);
  static const accentBlue       = Color(0xFF3B82F6);
  static const accentPurple     = Color(0xFF8B5CF6);
}

class AppTheme {
  // ── LIGHT THEME ───────────────────────────────────────────────
  static ThemeData get light {
    final baseTheme = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentLight,
        brightness: Brightness.light,
      ),
      cardColor: AppColors.lightBgCard,
      dividerColor: AppColors.lightBorder,
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary),
        bodyMedium: GoogleFonts.inter(color: AppColors.lightTextPrimary.withValues(alpha: 0.7)),
      ),
      inputDecorationTheme: _inputTheme(
        fillColor: AppColors.lightBgPrimary,
        borderColor: AppColors.lightBorder,
        focusColor: AppColors.accentLight,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.accentLight),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder()},
      ),
    );
  }

  // ── DARK THEME ────────────────────────────────────────────────
  static ThemeData get dark {
    final baseTheme = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentDark,
        brightness: Brightness.dark,
      ),
      cardColor: AppColors.darkBgCard,
      dividerColor: AppColors.darkBorder,
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        bodyMedium: GoogleFonts.inter(color: AppColors.darkTextPrimary.withValues(alpha: 0.7)),
      ),
      inputDecorationTheme: _inputTheme(
        fillColor: AppColors.darkBgCard,
        borderColor: AppColors.darkBorder,
        focusColor: AppColors.accentDark,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.accentDark),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder()},
      ),
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusColor,
  }) => InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focusColor, width: 1.5),
    ),
  );

  static ElevatedButtonThemeData _elevatedButtonTheme(Color accent) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return accent.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.pressed)) {
              return accent.withValues(alpha: 0.85);
            }
            if (states.contains(WidgetState.hovered)) {
              return accent.withValues(alpha: 0.9);
            }
            return accent;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.hovered)) return 4;
            return 0;
          }),
          animationDuration: const Duration(milliseconds: 150),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
