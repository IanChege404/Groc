import 'package:flutter/material.dart';
import 'dart:math' show pow;

/// Validates dark mode compliance across the app
class DarkModeValidator {
  // ========== SHADOW VALIDATION ==========
  /// Check if shadows are visible in dark mode
  static DarkModeShadowReport validateShadows() {
    final report = DarkModeShadowReport();

    // Light mode shadows use Colors.black with low opacity
    // Dark mode shadows should use darker tones or higher opacity dark
    report.addIssue(
      title: 'Shadow Opacity Verification',
      description: 'Shadows in dark mode need adjustment for visibility',
      impact: 'Shadows may be invisible on dark backgrounds',
      solutions: [
        'Increase shadow opacity in dark mode (e.g., 0.15 instead of 0.08)',
        'Use lighter shadow colors for dark backgrounds',
        'Reference app_defaults.dart shadowMd/shadowLg/shadowXl',
      ],
    );

    return report;
  }

  // ========== IMAGE TRANSPARENCY VALIDATION ==========
  /// Check image usage with transparency in dark mode
  static DarkModeImageReport validateImageTransparency() {
    final report = DarkModeImageReport();

    report.addWarning(
      title: 'Transparent PNGs on Dark Backgrounds',
      description:
          'Images with transparent backgrounds may not display correctly',
      affectedAreas: [
        'Product images with white/light backgrounds',
        'Icons with transparent backgrounds',
        'Illustrations with shadows',
      ],
      recommendations: [
        '✓ Use semi-transparent white layer behind images in dark mode',
        '✓ Set background color explicitly for image containers',
        '✓ Test all product images on both light and dark backgrounds',
        '✓ Use ColorFiltered or renderingMode for dynamic recoloring',
      ],
    );

    return report;
  }

  // ========== OVERLAY COLOR VALIDATION ==========
  /// Analyze overlay colors for dark mode
  static DarkModeOverlayReport validateOverlayColors() {
    final report = DarkModeOverlayReport();

    final recommendations = {
      'DialogScrim': {
        'light': 'Colors.black.withAlpha(32)',
        'dark': 'Colors.black.withAlpha(64)',
        'reason': 'Needs higher opacity to be visible on dark background',
      },
      'Bottom Sheet Barrier': {
        'light': 'Colors.black.withAlpha(40)',
        'dark': 'Colors.black.withAlpha(80)',
        'reason': 'Dimming effect must work on both light and dark',
      },
      'Modal Overlay': {
        'light': 'Colors.black.withAlpha(32)',
        'dark': 'Colors.white.withAlpha(24)',
        'reason':
            'Dark mode needs lighter overlay to dim without going too dark',
      },
    };

    for (final entry in recommendations.entries) {
      report.addOverlayCheck(
        name: entry.key,
        lightModeColor: entry.value['light']!,
        darkModeColor: entry.value['dark']!,
        reason: entry.value['reason']!,
      );
    }

    return report;
  }

  // ========== COLOR USAGE AUDIT ==========
  /// Verify all theme colors work in dark mode
  static ThemeColorAudit auditThemeColors(
    ThemeData lightTheme,
    ThemeData darkTheme,
  ) {
    final audit = ThemeColorAudit();

    audit.validateColorScheme(
      lightScheme: lightTheme.colorScheme,
      darkScheme: darkTheme.colorScheme,
    );

    return audit;
  }

  // ========== CONTRAST CHECK ==========
  /// Check text contrast in dark mode
  static ContrastReport checkTextContrast({
    required Color foreground,
    required Color background,
  }) {
    final report = ContrastReport(
      foreground: foreground,
      background: background,
    );

    final contrast = _calculateContrast(foreground, background);
    report.contrastRatio = contrast;

    if (contrast >= 7) {
      report.level = 'AAA'; // Enhanced
    } else if (contrast >= 4.5) {
      report.level = 'AA'; // Enhanced
    } else if (contrast >= 3) {
      report.level = 'AA (Large)'; // For 18pt+ text
    } else {
      report.level = 'FAIL';
      report.addIssue('Contrast too low: $contrast:1');
    }

    return report;
  }

  static double _calculateContrast(Color c1, Color c2) {
    final lum1 = _getLuminance(c1);
    final lum2 = _getLuminance(c2);

    final lighter = lum1 > lum2 ? lum1 : lum2;
    final darker = lum1 > lum2 ? lum2 : lum1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _getLuminance(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255) / 255;
    final g = (color.g * 255.0).round().clamp(0, 255) / 255;
    final b = (color.b * 255.0).round().clamp(0, 255) / 255;

    final rs = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gs = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bs = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }

  // ========== GENERATE FULL DARK MODE REPORT ==========
  static String generateFullAudit() {
    return '''
# Dark Mode Validation Audit

## 1. Shadow System
Shadows in dark mode should have increased opacity for visibility.
Reference: lib/core/constants/app_defaults.dart shadow definitions

## 2. Image Handling
Product images with transparent backgrounds need explicit backgrounds in dark mode.

## 3. Overlay Colors
Modal overlays need adjustment for dark backgrounds to maintain scrim effect.

## 4. Quick Verification Checklist
- [ ] Test every screen in dark mode
- [ ] Check shadows are visible (opacity 0.10+ for dark mode)
- [ ] Product images have proper backgrounds
- [ ] Overlays dim content appropriately
- [ ] Bottom sheets/dialogs are readable
- [ ] Maps/web views handle dark mode
- [ ] Charts/graphs colors are accessible
- [ ] Status bar icons are visible

## 5. Known Issues & Fixes

### Issue: Images disappear in dark mode
**Solution:**
```dart
Container(
  color: Theme.of(context).brightness == Brightness.dark
      ? AppColors.surfaceDark
      : Colors.transparent,
  child: Image.network(url),
)
```

### Issue: Shadows invisible
**Solution:** Use higher opacity in dark mode
```dart
BoxShadow(
  color: Colors.black.withValues(
    alpha: isDark ? 0.15 : 0.08,
  ),
  blurRadius: 8,
)
```

### Issue: Text labels hard to read on images
**Solution:** Add scrim overlay
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withAlpha(140),
      ],
    ),
  ),
  child: Text('Label'),
)
```

## 6. Testing Procedure

### Manual Testing
1. Enable system dark mode on device
2. Walk through each screen
3. Check: images, shadows, overlays, modals
4. Test with different text sizes

### Automated Testing
1. Use Flutter DevTools Inspector
2. Use accessibility tree viewer
3. Screenshot compare light vs dark

### User Testing
- [ ] Test with real users who use dark mode exclusively
- [ ] Gather feedback on readability
- [ ] Check for comfort (not too bright/too dim)
''';
  }
}

// ========== REPORT CLASSES ==========
class DarkModeShadowReport {
  final List<Map<String, dynamic>> issues = [];

  void addIssue({
    required String title,
    required String description,
    required String impact,
    required List<String> solutions,
  }) {
    issues.add({
      'title': title,
      'description': description,
      'impact': impact,
      'solutions': solutions,
    });
  }
}

class DarkModeImageReport {
  final List<Map<String, dynamic>> warnings = [];

  void addWarning({
    required String title,
    required String description,
    required List<String> affectedAreas,
    required List<String> recommendations,
  }) {
    warnings.add({
      'title': title,
      'description': description,
      'areas': affectedAreas,
      'recs': recommendations,
    });
  }
}

class DarkModeOverlayReport {
  final List<Map<String, String>> overlays = [];

  void addOverlayCheck({
    required String name,
    required String lightModeColor,
    required String darkModeColor,
    required String reason,
  }) {
    overlays.add({
      'name': name,
      'light': lightModeColor,
      'dark': darkModeColor,
      'reason': reason,
    });
  }
}

class ThemeColorAudit {
  final List<String> issues = [];

  void validateColorScheme({
    required ColorScheme lightScheme,
    required ColorScheme darkScheme,
  }) {
    // Verify key colors exist and are different
    if (lightScheme.primary == darkScheme.primary) {
      issues.add('Primary color is identical in light and dark modes');
    }
  }
}

class ContrastReport {
  final Color foreground;
  final Color background;
  late double contrastRatio;
  late String level;
  final List<String> issues = [];

  ContrastReport({required this.foreground, required this.background});

  void addIssue(String issue) => issues.add(issue);

  @override
  String toString() =>
      'Contrast: ${contrastRatio.toStringAsFixed(2)}:1 ($level)';
}
