import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Afri-Commerce Text Styles
/// Font families: Sora (display) + DM Sans (body)
class AppTextStyles {
  // ========== DISPLAY STYLES ==========

  /// Display Large - Hero text, splash screen
  /// Font: Sora, Weight: 700, Size: 32sp, Line Height: 40sp
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Sora',
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 40 / 32,
    color: AppColors.onBackgroundLight,
  );

  /// Display Medium - Page titles, major sections
  /// Font: Sora, Weight: 700, Size: 26sp, Line Height: 34sp
  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Sora',
    fontWeight: FontWeight.w700,
    fontSize: 26,
    height: 34 / 26,
    color: AppColors.onBackgroundLight,
  );

  // ========== HEADLINE ==========

  /// Headline - Section headers, card titles (large)
  /// Font: Sora, Weight: 600, Size: 20sp, Line Height: 28sp
  static const TextStyle headline = TextStyle(
    fontFamily: 'Sora',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 28 / 20,
    color: AppColors.onBackgroundLight,
  );

  // ========== TITLE ==========

  /// Title - Card titles, nav labels
  /// Font: Sora, Weight: 600, Size: 17sp, Line Height: 24sp
  static const TextStyle title = TextStyle(
    fontFamily: 'Sora',
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 24 / 17,
    color: AppColors.onBackgroundLight,
  );

  // ========== BODY STYLES ==========

  /// Body Large - Primary body text, descriptions
  /// Font: DM Sans, Weight: 400, Size: 16sp, Line Height: 24sp
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.onSurfaceLight,
  );

  /// Body Medium - Secondary text, card details
  /// Font: DM Sans, Weight: 400, Size: 14sp, Line Height: 20sp
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.onSurfaceLight,
  );

  /// Body Small - Tags, timestamps, captions
  /// Font: DM Sans, Weight: 400, Size: 12sp, Line Height: 18sp
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 18 / 12,
    color: AppColors.subtleLight,
  );

  // ========== LABEL ==========

  /// Label - Button labels, form labels
  /// Font: DM Sans, Weight: 600, Size: 14sp, Line Height: 20sp
  static const TextStyle label = TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.onSurfaceLight,
  );

  // ========== OVERLINE ==========

  /// Overline - Category labels, breadcrumbs
  /// Font: DM Sans, Weight: 500, Size: 11sp, Line Height: 16sp
  static const TextStyle overline = TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 16 / 11,
    color: AppColors.subtleLight,
    letterSpacing: 0.5,
  );

  // ========== PRICE ==========

  /// Price - Product prices in local currency
  /// Font: Sora, Weight: 700, Size: 18sp, Line Height: 24sp
  static const TextStyle price = TextStyle(
    fontFamily: 'Sora',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 24 / 18,
    color: AppColors.primary,
  );
}
