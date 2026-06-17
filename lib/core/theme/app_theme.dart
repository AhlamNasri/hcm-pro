import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_account.dart';

/// "Terracotta & Ink" — a warm, editorial palette chosen to read as
/// human-crafted rather than a generic blue-grey SaaS template. Role colors
/// are intentionally scoped to identity touch points (banners, the logged-in
/// user's own header, avatar rings, bottom-nav, login chips) — buttons,
/// links and FABs always stay brand terracotta so the app doesn't feel like
/// it's wearing a different skin every time someone else logs in.
class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFFC1622D); // burnt terracotta
  static const primaryLight = Color(0xFFD98952);
  static const primaryLighter = Color(0xFFF6E6D9);
  static const primaryDark = Color(0xFF8C481E); // header/cover blocks
  static const accent = Color(0xFF1F6F5C); // deep emerald
  static const accentLight = Color(0xFFDCEDE7);

  // Surfaces & text — warm ivory, not cold blue-grey
  static const surface = Color(0xFFFBF7F2);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF2B2422); // warm ink
  static const textSecondary = Color(0xFF7A6F66);
  static const textLight = Color(0xFFC2B8AD);
  static const divider = Color(0xFFEFE6DB);
  static const shimmerBase = Color(0xFFEFE6DB);
  static const shimmerHighlight = Color(0xFFFBF7F2);

  // Semantic — re-tuned warm so they sit comfortably next to terracotta/ink
  static const success = Color(0xFF3F7D52);
  static const successLight = Color(0xFFE3EFE2);
  static const warning = Color(0xFFC78A2E);
  static const warningLight = Color(0xFFF6E9D3);
  static const danger = Color(0xFFB6453A);
  static const dangerLight = Color(0xFFF5E1DD);
  static const pending = Color(0xFF6B2D5C); // deep plum, doubles as Owner role color
  static const pendingLight = Color(0xFFEDE0E9);

  // Role identity colors — scoped usage only, see class doc.
  static const roleOwner = Color(0xFF6B2D5C); // deep plum
  static const roleHrManager = Color(0xFFC1622D); // terracotta (brand primary)
  static const roleManager = Color(0xFF1F6F5C); // emerald (brand accent)
  static const roleEmployee = Color(0xFFB8860B); // warm ochre

  static Color roleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return roleOwner;
      case UserRole.hrManager:
        return roleHrManager;
      case UserRole.manager:
        return roleManager;
      case UserRole.employee:
        return roleEmployee;
    }
  }
}

class AppTextStyles {
  AppTextStyles._();

  // Display/heading — Fraunces, a warm serif with real character.
  static TextStyle get displayLarge => GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get heading1 => GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get heading2 => GoogleFonts.fraunces(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading3 => GoogleFonts.fraunces(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Body/UI — Plus Jakarta Sans, warmer and rounder than plain Inter.
  static TextStyle get body1 => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get body2 => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      );

  static TextStyle get button => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  static TextStyle get stat => GoogleFonts.fraunces(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.fraunces(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primaryLighter.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.body2,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLighter,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.label,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: const StadiumBorder(),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
