import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';
import '../constants/app_text_styles.dart';

class AppThemeDark {
  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: "Sora",
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // ========== COLOR SCHEME ==========
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        error: AppColors.errorDark,
      ),

      // ========== APP BAR THEME ==========
      appBarTheme: const AppBarTheme(
        elevation: 0.3,
        backgroundColor: AppColors.surfaceDark,
        iconTheme: IconThemeData(color: AppColors.onSurfaceDark),
        titleTextStyle: TextStyle(
          color: AppColors.onSurfaceDark,
          fontWeight: FontWeight.bold,
          fontFamily: "Sora",
          fontSize: 20,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: AppColors.surfaceDark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // ========== TEXT THEME ==========
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.onBackgroundDark,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.onBackgroundDark,
        ),
        headlineSmall: AppTextStyles.headline.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        titleLarge: AppTextStyles.title.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.subtleDark,
        ),
      ),

      // ========== ELEVATED BUTTON THEME ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimaryDark,
          padding: const EdgeInsets.all(AppDefaults.padding),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: "Sora",
          ),
        ),
      ),

      // ========== OUTLINED BUTTON THEME ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryDark),
          padding: const EdgeInsets.all(AppDefaults.padding),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // ========== TEXT BUTTON THEME ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Sora',
          ),
        ),
      ),

      // ========== INPUT DECORATION THEME ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: AppDefaults.borderRadius,
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDefaults.borderRadius,
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDefaults.borderRadius,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDefaults.borderRadius,
          borderSide: const BorderSide(color: AppColors.errorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDefaults.borderRadius,
          borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.subtleDark,
          fontFamily: "DM Sans",
        ),
        labelStyle: const TextStyle(
          color: AppColors.onSurfaceDark,
          fontFamily: "Sora",
        ),
      ),

      // ========== CARD THEME ==========
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
      ),

      // ========== DIVIDER THEME ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        space: 1,
        thickness: 1,
      ),

      // ========== FLOATING ACTION BUTTON THEME ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
