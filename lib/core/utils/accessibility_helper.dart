import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  /// Minimum touch target size (48×48px as per Material Design 3)
  static const double minTouchTarget = 48;

  /// Recommended spacing between touch targets
  static const double minTouchSpacing = 8;

  /// Standard WCAG AA contrast ratio (4.5:1 for text, 3:1 for UI)
  static const double wcagAAContrastRatio = 4.5;
  static const double wcagUIContrastRatio = 3.0;

  // ========== TOUCH TARGET VALIDATION ==========
  /// Validate if button has sufficient touch target
  static String validateTouchTarget(
    double width,
    double height, {
    bool verbose = false,
  }) {
    if (width >= minTouchTarget && height >= minTouchTarget) {
      return 'PASS: Touch target is ${width.toStringAsFixed(0)}×${height.toStringAsFixed(0)}';
    }

    final warning =
        'WARN: Touch target (${width.toStringAsFixed(0)}×${height.toStringAsFixed(0)}) '
        'below minimum 48×48px';

    if (verbose) {
      return '$warning. Users with motor impairments may struggle to tap this target.';
    }
    return warning;
  }

  /// Check if widget is tappable
  static bool isTappable(double width, double height) =>
      width >= minTouchTarget && height >= minTouchTarget;

  // ========== SEMANTIC LABELING ==========
  /// Apply semantic label to icon/image for screen readers
  static Widget semanticLabel(
    Widget child, {
    required String label,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      enabled: enabled,
      button: true,
      child: child,
    );
  }

  /// Accessibility wrapper for interactive elements
  static Widget accessibleButton({
    required Widget child,
    required String label,
    required VoidCallback onTap,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Label for images/icons
  static Widget labeledImage({
    required ImageProvider image,
    required String semanticLabel,
    double? width,
    double? height,
  }) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Image(
        image: image,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
      ),
    );
  }

  // ========== CONTRAST RATIO REFERENCE GUIDE ==========
  /// Get contrast ratio guidance
  static String getContrastGuidance() {
    return '''
# Contrast Ratio Guidelines (WCAG)

## Levels
- **A (Minimum)**: 4.5:1 for text, 3:1 for graphics
- **AA (Enhanced)**: 7:1 for text, 4.5:1 for graphics
- **AAA (Enhanced)**: 7:1 for text and graphics

## Tools to Check
1. **WebAIM Contrast Checker**: https://webaim.org/resources/contrastchecker/
2. **Color Contrast Analyzer**: https://www.tpgi.com/color-contrast-checker/
3. **Deque axe DevTools**: Chrome extension
4. **Flutter DevTools**: Accessibility inspector

## Quick Reference
- Black (#000000) on White (#FFFFFF): 21:1 ✓ (Perfect)
- Primary Red (#C8442A) on Light BG (#FAF7F2): ~5.2:1 ✓ (AA for normal text)
- Light Gray on Light BG: ❌ (Too low)
- Dark text on dark BG: ❌ (Too low)

## Colors to Avoid
- Light text on light backgrounds
- Dark text on dark backgrounds
- Yellow text (especially on white)
- Orange/red text on light backgrounds (unless large)
''';
  }

  // ========== SCREEN READER HELPERS ==========
  /// Announce message to screen reader
  static Future<void> announceForAccessibility(
    BuildContext context,
    String message,
  ) async {
    try {
      // ignore: deprecated_member_use
      await SemanticsService.announce(message, TextDirection.ltr);
    } catch (_) {
      // SemanticsService might not be available
    }
  }

  /// Create announcement for common actions
  static Future<void> announceItemAdded(
    BuildContext context, {
    required String itemName,
  }) => announceForAccessibility(context, '$itemName added');

  static Future<void> announceItemRemoved(
    BuildContext context, {
    required String itemName,
  }) => announceForAccessibility(context, '$itemName removed');

  static Future<void> announceSuccess(
    BuildContext context, {
    required String message,
  }) => announceForAccessibility(context, 'Success. $message');

  static Future<void> announceError(
    BuildContext context, {
    required String message,
  }) => announceForAccessibility(context, 'Error. $message');

  // ========== TEXT SIZE SCALING ==========
  /// Get text scale factor from system settings
  static double getTextScaleFactor(BuildContext context) =>
      MediaQuery.of(context).textScaler.scale(1.0);

  /// Check if user has requested larger text (accessibility setting)
  static bool isLargeTextRequested(BuildContext context) =>
      getTextScaleFactor(context) > 1.0;

  /// Apply responsive text size that respects user preferences
  static TextStyle getAccessibleTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final scale = getTextScaleFactor(context);
    // Limit scaling to between 0.8x and 1.5x for readability
    final clampedScale = scale.clamp(0.8, 1.5);
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * clampedScale,
    );
  }

  // ========== BOLD TEXT FOR BETTER READABILITY ==========
  /// Enhance text boldness for accessibility
  static TextStyle enhanceTextWeight(TextStyle style) {
    return style.copyWith(
      fontWeight: style.fontWeight == null
          ? FontWeight
                .w600 // Default to semi-bold
          : style.fontWeight == FontWeight.normal
          ? FontWeight
                .w600 // Upgrade normal to semi-bold
          : style.fontWeight,
    );
  }

  // ========== FOCUS/HIGHLIGHT HELPERS ==========
  /// Add focus highlight for keyboard navigation
  static BoxDecoration getFocusDecoration(
    BuildContext context, {
    Color? focusColor,
    double width = 2,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: focusColor ?? Theme.of(context).primaryColor,
        width: width,
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Enhance tap target with visual feedback
  static Widget enhanceTouchTarget({
    required Widget child,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }

  // ========== ACCESSIBILITY CHECKLIST ==========
  static String getAccessibilityChecklist() {
    return '''
# Accessibility Audit Checklist

## Touch Targets
- [ ] All buttons ≥ 48×48px
- [ ] Padding between targets ≥ 8px
- [ ] Icon-only buttons have label text

## Color & Contrast
- [ ] Text: 4.5:1 contrast ratio (AA)
- [ ] Graphics: 3:1 contrast ratio (AA)
- [ ] No color-only indicators (use icons/text too)
- [ ] Link colors differ from text

## Text & Typography
- [ ] Font size ≥ 16px for body text
- [ ] Line height ≥ 1.5x font size
- [ ] Line length ≤ 80 characters
- [ ] Supports text scaling (100-200%)

## Navigation
- [ ] Skip links for long content
- [ ] Logical tab order (top-to-bottom, left-to-right)
- [ ] Focus indicators visible
- [ ] Page title changes on navigation

## Images & Icons
- [ ] All images have alt text
- [ ] Icon-only buttons have labels
- [ ] Decorative images marked as such

## Forms
- [ ] Labels associated with inputs
- [ ] Error messages announced
- [ ] Required fields marked
- [ ] Form validation is accessible

## Testing
- [ ] Tested with TalkBack (Android)
- [ ] Tested with VoiceOver (iOS)
- [ ] Tested with keyboard-only navigation
- [ ] Different text size settings (100%, 150%, 200%)
''';
  }
}

// ========== WRAPPER CLASS FOR MAKING ELEMENTS ACCESSIBLE ==========
class AccessibleWidget extends StatefulWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final bool isButton;

  const AccessibleWidget({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onTap,
    this.isButton = false,
  });

  @override
  State<AccessibleWidget> createState() => _AccessibleWidgetState();
}

class _AccessibleWidgetState extends State<AccessibleWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (HardwareKeyboard.instance.isLogicalKeyPressed(
          LogicalKeyboardKey.enter,
        )) {
          widget.onTap?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        label: widget.label,
        hint: widget.hint,
        button: widget.isButton,
        enabled: widget.onTap != null,
        onTap: widget.onTap,
        focusable: widget.isButton,
        focused: _focusNode.hasFocus,
        customSemanticsActions: widget.onTap != null
            ? <CustomSemanticsAction, VoidCallback>{
                const CustomSemanticsAction(label: 'activate'): widget.onTap!,
              }
            : null,
        child: widget.child,
      ),
    );
  }
}
