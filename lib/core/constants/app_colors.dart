import 'package:flutter/material.dart';

/// Afri-Commerce Color Palette
/// Based on Afrocentric design language: Terracotta Red & Kente Gold
/// Full light + dark mode support
class AppColors {
  // ========== LIGHT MODE ==========

  /// Primary Brand Color - Terracotta Red
  static const Color primary = Color(0xFFC8442A);
  static const Color primaryVariant = Color(0xFFA0341A); // Pressed state

  /// Secondary Brand Color - Kente Gold
  static const Color secondary = Color(0xFFF4A535);

  /// Background Colors
  static const Color backgroundLight = Color(0xFFFAF7F2); // Warm Cream
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF2EDE4);

  /// Text Colors
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF1A1A1A);
  static const Color onSurfaceLight = Color(0xFF2C2C2C);

  /// Utility Colors
  static const Color subtleLight = Color(0xFF8A8A8A); // Placeholders, captions
  static const Color dividerLight = Color(0xFFE8E2D9);

  /// Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFE65100);
  static const Color info = Color(0xFF1565C0);

  // ========== DARK MODE ==========

  static const Color primaryDark = Color(0xFFE5604A);
  static const Color primaryVariantDark = Color(0xFFC8442A); // Pressed state

  static const Color secondaryDark = Color(0xFFF4A535);

  /// Background Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  /// Text Colors
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFF0ECE4);
  static const Color onSurfaceDark = Color(0xFFE0DDD6);

  /// Utility Colors
  static const Color subtleDark = Color(0xFF6A6A6A); // Placeholders, captions
  static const Color dividerDark = Color(0xFF333333);

  /// Status Colors (Dark mode variants)
  static const Color successDark = Color(0xFF4CAF50);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warningDark = Color(0xFFFF9800);
  static const Color infoDark = Color(0xFF42A5F5);

  // ========== LEGACY COLORS (Compatibility) ==========
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color scaffoldWithBoxBackground = Color(0xFFF7F7F7);
  static const Color cardColor = Color(0xFFF2F2F2);
  static const Color coloredBackground = Color(0xFFE4F8EA);
  static const Color placeholder = Color(0xFF8B8B97);
  static const Color textInputBackground = Color(0xFFF7F7F7);
  static const Color separator = Color(0xFFFAFAFA);
  static const Color gray = Color(0xFFE1E1E1);
}
