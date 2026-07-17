# Dark Mode Guide

## Overview

Pro Grocery provides complete dark mode support with automatic theme switching. Both light and dark themes are defined separately and applied consistently across all UI components.

## Theme Files

| File | Purpose |
|------|---------|
| `lib/core/themes/app_themes.dart` | Light theme definition |
| `lib/core/themes/app_theme_dark.dart` | Dark theme definition |
| `lib/core/constants/app_colors.dart` | Color palette (light + dark variants) |

## How It Works

### Theme Registration

```dart
// In main.dart
MaterialApp(
  theme: AppThemes.lightTheme,      // Light theme
  darkTheme: AppThemes.darkTheme,   // Dark theme
  themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
)
```

### Theme Toggle

Dark mode is managed by `SettingsProvider` and persisted in SharedPreferences:

```dart
// Toggle dark mode
final settings = Provider.of<SettingsProvider>(context);
settings.toggleDarkMode();

// Check current state
bool isDark = settings.isDarkMode;
```

### User Control

Users can toggle dark mode from:
- Settings screen (`/settings`)
- Quick toggle in profile menu

## Color System

### Light Theme Colors
```dart
class AppColors {
  static const primary = Color(0xFF6EC566);      // Brand green
  static const secondary = Color(0xFFFF6B6B);     // Accent red
  static const background = Color(0xFFFAFAFA);     // Page background
  static const surface = Color(0xFFFFFFFF);        // Card background
  static const textPrimary = Color(0xFF1A1A1A);    // Main text
  static const textSecondary = Color(0xFF666666);  // Muted text
  static const border = Color(0xFFE0E0E0);        // Borders
}
```

### Dark Theme Colors
```dart
class AppColors {
  static const darkPrimary = Color(0xFF5BA84F);    // Brand green (dark)
  static const darkSecondary = Color(0xFFFF5252);   // Accent red (dark)
  static const darkBackground = Color(0xFF1A1A1A);  // Page background
  static const darkSurface = Color(0xFF2D2D2D);     // Card background
  static const darkTextPrimary = Color(0xFFFFFFFF);  // Main text
  static const darkTextSecondary = Color(0xFFB0B0B0); // Muted text
  static const darkBorder = Color(0xFF404040);       // Borders
}
```

## Using Theme Colors in Widgets

### Preferred: Use Theme.of(context)
```dart
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)
```

### Using AppColors Directly (for static values)
```dart
import 'package:grocery/core/constants/app_colors.dart';

// For light-only contexts
Container(color: AppColors.primary)

// For dark-aware contexts, use Theme instead
Container(color: Theme.of(context).colorScheme.primary)
```

## Component Theming

### Cards
```dart
Card(
  color: Theme.of(context).colorScheme.surface,
  elevation: isDarkMode ? 0 : 2,  // Flat in dark mode
  child: ...
)
```

### Buttons
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  child: Text('Buy'),
)
```

### Text Fields
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
  ),
)
```

## Dark Mode Testing Checklist

### Visual Verification
- [ ] All text readable (4.5:1 contrast ratio)
- [ ] Shadows visible with adjusted opacity
- [ ] Icons distinct from background (3:1 contrast)
- [ ] Input fields visible with clear borders
- [ ] Focus indicators visible
- [ ] Error states visible
- [ ] Success states visible

### Component Checks
- [ ] Cards have visible boundaries
- [ ] Dividers visible
- [ ] Buttons have clear states (normal, pressed, disabled)
- [ ] Bottom navigation selected state clear
- [ ] Status bar text readable

### Image Handling
- [ ] Product images don't show white flash
- [ ] Transparent PNGs render on dark background
- [ ] Placeholder images visible in dark mode
- [ ] No white borders around images

### Animation Checks
- [ ] Loading skeletons use dark theme colors
- [ ] Transitions smooth between themes
- [ ] No color flickering during theme switch

## Accessibility in Dark Mode

- All contrast ratios must still meet WCAG 2.1 AA (4.5:1 for text, 3:1 for large text)
- Focus indicators must remain visible (3:1 contrast against dark background)
- Error messages must be readable
- Semantic labels must work with screen readers in dark mode

## Common Dark Mode Issues

### White flash on image load
**Cause:** Images with transparent backgrounds on white containers
**Fix:** Use `color: Colors.transparent` or `BoxFit.cover` on image containers

### Invisible shadows
**Cause:** Light shadows on dark background
**Fix:** Reduce elevation in dark mode or use `Shadow` with lighter color

### Poor contrast on text
**Cause:** Using light theme text color in dark mode
**Fix:** Always use `Theme.of(context).colorScheme.onSurface` for text

### Status bar unreadable
**Cause:** Dark status bar text on dark background
**Fix:** Set `SystemUiOverlayStyle` based on theme:
```dart
SystemChrome.setSystemUIOverlayStyle(
  Theme.of(context).brightness == Brightness.dark
    ? SystemUiOverlayStyle.light
    : SystemUiOverlayStyle.dark,
)
```
