# Localization Guide

## Overview

Pro Grocery supports English and Swahili using Flutter's ARB (App Resource Bundle) localization system. The app has 237+ translated strings.

## File Structure

```
lib/core/l10n/
├── app_en.arb                     # English strings (source of truth)
├── app_sw.arb                     # Swahili translations
└── app_localizations.dart          # Generated (DO NOT EDIT)
```

## Adding a New String

### Step 1: Add to English ARB
```json
// lib/core/l10n/app_en.arb
{
  "addToCart": "Add to Cart",
  "@addToCart": {
    "description": "Button label for adding item to cart"
  }
}
```

### Step 2: Add to Swahili ARB
```json
// lib/core/l10n/app_sw.arb
{
  "addToCart": "Ongeza Kwenye Kikapu"
}
```

### Step 3: Regenerate Localizations
```bash
flutter gen-l10n
# Or rebuild: flutter run
```

### Step 4: Use in Code
```dart
import 'package:grocery/core/l10n/app_localizations.dart';

// In a widget:
Text(AppLocalizations.of(context)!.addToCart)

// In a StatelessWidget:
final l10n = AppLocalizations.of(context)!;
ElevatedButton(
  onPressed: () {},
  child: Text(l10n.addToCart),
)
```

## String Naming Conventions

| Pattern | Example | Use Case |
|---------|---------|----------|
| `noun` | `cart`, `profile` | Screen/section titles |
| `verbNoun` | `addToCart`, `removeItem` | Action labels |
| `adjectiveNoun` | `emptyCart`, `invalidEmail` | State descriptions |
| `questionNoun` | `confirmDelete?` | Confirmation dialogs |
| `labelX` | `labelEmail`, `labelPassword` | Form field labels |

## Parameterized Strings

```json
// app_en.arb
{
  "itemsInCart": "{count} items in cart",
  "@itemsInCart": {
    "description": "Cart item count",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  }
}
```

```json
// app_sw.arb
{
  "itemsInCart": "Vitu {count} kwenye kikapu"
}
```

Usage:
```dart
Text(AppLocalizations.of(context)!.itemsInCart(5))
// English: "5 items in cart"
// Swahili: "Vitu 5 kwenye kikapu"
```

## ICU Message Formats

### Plurals
```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

### Gender
```json
{
  "greeting": "{gender, female{Hello Ms.} male{Hello Mr.} other{Hello}}",
  "@greeting": {
    "placeholders": {
      "gender": { "type": "String" }
    }
  }
}
```

## Locale Provider

The current locale is managed by `LocaleProvider` at `lib/core/l10n/locale_provider.dart`:

- User preference stored in SharedPreferences
- System theme detection (optional)
- Locale switching persists across app restarts

```dart
// Switch locale
final localeProvider = Provider.of<LocaleProvider>(context);
localeProvider.setLocale(const Locale('sw')); // Swahili
localeProvider.setLocale(const Locale('en')); // English
```

## Language Selection Screen

Users can change language from:
- Onboarding screen (first launch)
- Settings → Language settings (`/settingsLanguage`)

## Current Translations Status

| Locale | Language | String Count | Completeness |
|--------|----------|-------------|--------------|
| `en` | English | 237+ | 100% (source) |
| `sw` | Swahili | 237+ | 100% |

## Adding a New Language

1. Create `lib/core/l10n/app_{locale}.arb` (e.g., `app_fr.arb`)
2. Copy all keys from `app_en.arb`
3. Translate all values
4. Run `flutter gen-l10n`
5. Add locale to supported locales in `main.dart`:
```dart
supportedLocales: [
  Locale('en'),
  Locale('sw'),
  Locale('fr'),  // Add here
]
```

## Common Pitfalls

### Missing key in one ARB file
**Error:** `MissingTranslationException`
**Fix:** Add the key to BOTH `app_en.arb` and `app_sw.arb`, then regenerate.

### Forgetting to regenerate
**Symptom:** New strings don't appear in code
**Fix:** Run `flutter gen-l10n` or restart with `flutter run`

### Editing generated file
**Never edit** `app_localizations.dart` — it's auto-generated and will be overwritten.

### Hardcoded strings in code
```dart
// BAD — hardcoded
Text('Add to Cart')

// GOOD — localized
Text(AppLocalizations.of(context)!.addToCart)
```

## Translation Quality Guidelines

- **Keep it concise:** Mobile screens have limited space
- **Use natural Swahili:** Not word-for-word translation
- **Preserve meaning:** Technical terms may stay in English (e.g., "M-Pesa")
- **Test on device:** Verify text fits in UI components
- **Consider cultural context:** Colors, symbols, date formats
