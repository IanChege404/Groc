import 'package:flutter/material.dart';

/// Afri-Commerce Design Constants
class AppDefaults {
  // ========== SPACING SCALE (4px base) ==========
  static const double spacingXs = 4; // xs - tight gaps, icon padding
  static const double spacingSm = 8; // sm - chip padding, list item gaps
  static const double spacingMdSm = 12; // md-sm - card inner padding
  static const double spacingMd = 16; // md - standard horizontal margin
  static const double spacingMdLg = 20; // md-lg - section padding
  static const double spacingLg = 24; // lg - card padding, section gap
  static const double spacingXl = 32; // xl - hero padding
  static const double spacing2xl = 48; // 2xl - large section breaks

  // ========== LEGACY (For backward compatibility) ==========
  static const double radius = 15;
  static const double margin = 16;
  static const double padding = 16;

  // ========== BORDER RADIUS ==========
  static BorderRadius borderRadius = BorderRadius.circular(12);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(16);
  static BorderRadius borderRadiusRounded = BorderRadius.circular(20);

  /// Used For Bottom Sheet
  static BorderRadius bottomSheetRadius = const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );

  /// Used For Top Sheet
  static BorderRadius topSheetRadius = const BorderRadius.only(
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );

  // ========== SHADOWS ==========
  /// Level 0 - Flat
  static const List<BoxShadow> noShadow = [];

  /// Level 1 - Cards, list tiles
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      blurRadius: 3,
      spreadRadius: 0,
      offset: const Offset(0, 1),
      color: Colors.black.withValues(alpha: 0.08),
    ),
  ];

  /// Level 2 - Bottom nav, sticky headers
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
      color: Colors.black.withValues(alpha: 0.10),
    ),
  ];

  /// Level 3 - Floating buttons, modals
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
      color: Colors.black.withValues(alpha: 0.14),
    ),
  ];

  /// Level 4 - Bottom sheets, drawers
  static List<BoxShadow> shadowXl = [
    BoxShadow(
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
      color: Colors.black.withValues(alpha: 0.18),
    ),
  ];

  /// Default Box Shadow (Level 1)
  static List<BoxShadow> boxShadow = shadowMd;

  // ========== ANIMATIONS ==========
  /// UI feedback animation duration (button press, toggle, etc)
  static const Duration durationShort = Duration(milliseconds: 200);

  /// Standard animation duration (navigation, state change)
  static const Duration duration = Duration(milliseconds: 300);

  /// Lazy load animation duration (skeleton -> content)
  static const Duration durationLong = Duration(milliseconds: 500);

  /// Legacy duration
  static const Duration durationDefault = duration;
}
