================================================================================
    RESPONSIVE DESIGN TESTING GUIDE - Afri-Commerce Phase 3 QA
================================================================================

DEVICE SIZES TO TEST:
  1. Small Phone:  360×640px  (Galaxy A series - common in Kenya)
  2. Medium Phone: 390×844px  (iPhone 12 base)
  3. Large Phone:  414×896px  (iPhone Pro Max)
  4. Tablet:       768×1024px (iPad Mini)

================================================================================
TESTING PROCEDURE
================================================================================

STEP 1: Enable Responsive Preview in VS Code/Flutter DevTools
  Command: Flutter DevTools → Device Preview
  Or: Use emulator device rotation

STEP 2: Test Each Resolution
  For each device size listed above, perform these checks:

================================================================================
SCREEN-BY-SCREEN RESPONSIVE CHECKLIST
================================================================================

✓ ONBOARDING SCREENS (360×640, 390×844, 414×896, 768×1024)
  [ ] Illustration images scale correctly without overflow
  [ ] Text doesn't exceed container width
  [ ] Buttons remain easily tappable (48×48px minimum)
  [ ] Pagination dots visible and centered
  [ ] Next/Back buttons aligned properly

✓ AUTH SCREENS (Login/SignUp/OTP/ForgotPassword)
  [ ] Form fields expand to fill width with proper padding
  [ ] Input fields maintain 48×48px height
  [ ] Phone number field respects country picker icon width
  [ ] OTP digit boxes are square and properly spaced
  [ ] CTA buttons span full width with 16px margins
  [ ] Error messages display without truncation

✓ HOME SCREEN (all sizes)
  [ ] Header with search bar scales proportionally
  [ ] Carousel/Hero section maintains aspect ratio
  [ ] Category grid: 3-4 cols on phone, 6+ on tablet
  [ ] Product grid: 2 cols on small phone, 3 cols on tablet
  [ ] Flash sales countdown doesn't overflow
  [ ] Bottom nav: 5 icons visible without crowding
  [ ] "View All" buttons aligned right

✓ SEARCH & FILTERS
  [ ] Search input clears visibility of filter chips
  [ ] Filter bottom sheet takes 60-70% height on phone, full on tablet
  [ ] Filter options stack vertically without overflow
  [ ] Apply/Reset buttons accessible at bottom

✓ PRODUCT DETAIL PAGE
  [ ] Image gallery height: 35-40% of viewport
  [ ] Product info stacks below gallery
  [ ] Rating/review section readable on all sizes
  [ ] Variant selector buttons don't wrap awkwardly
  [ ] Price and quantity picker layout optimal
  [ ] "Add to Cart" button full-width at bottom

✓ CART PAGE
  [ ] Cart items: full width with proper padding
  [ ] Quantity stepper buttons centered
  [ ] Delete button icon visible without label
  [ ] Price summary visible on small screens
  [ ] Checkout button full-width and tappable

✓ CHECKOUT FLOW
  [ ] Address selection: cards stack vertically
  [ ] Address form inputs expand to fill width
  [ ] Delivery method options: radio buttons aligned left
  [ ] Payment method icons: 2 per row on phone, 4+ on tablet
  [ ] M-Pesa screen: phone icon centered, countdown visible
  [ ] Order confirmation: order number large enough to read

✓ PROFILE & MENU
  [ ] Menu items: 1 col on phone, 2-3 cols on tablet
  [ ] Avatar image: maintains aspect ratio
  [ ] Profile form fields: full width
  [ ] Settings toggles: aligned right with proper spacing

================================================================================
SAFE AREA TESTING (Notch/Home Indicator Handling)
================================================================================

Test on physical devices or emulators with notch:
  [ ] Status bar content visible
  [ ] Header doesn't hide behind notch/status bar
  [ ] Bottom nav doesn't hide behind home indicator (iOS)
  [ ] Modal/bottom sheet respects safe area
  [ ] All edges have proper padding

================================================================================
LANDSCAPE MODE TESTING (Optional but Recommended)
================================================================================

Tested on: 360×640 rotated to 640×360
  [ ] Layout adapts gracefully to landscape
  [ ] Navigation still accessible
  [ ] Text remains readable
  [ ] Touch targets remain 48×48px minimum

================================================================================
ACCESSIBILITY RESPONSIVE TESTING
================================================================================

For EACH device size, run screen reader (TalkBack/VoiceOver):
  [ ] All text labels readable
  [ ] Button labels announce action (not just "Button")
  [ ] Images have semantic descriptions
  [ ] Custom widgets have semantic role announced
  [ ] Form inputs announce required status
  [ ] Error messages announced to screen reader
  [ ] Focus order logical (top-to-bottom, left-to-right)

================================================================================
SAFE AREA INSETS VERIFICATION
================================================================================

Using ResponsiveHelper.getSafeAreaInsets(context):
  [ ] Top inset correctly handles notch (12-48px)
  [ ] Bottom inset correctly handles home indicator (0-34px)
  [ ] Left/right insets handle side notches (0-44px)
  [ ] All UI elements respect these insets

================================================================================
GRID COLUMN AUTO-CALCULATION
================================================================================

Using ResponsiveHelper.getGridColumns(context):
  [ ] Product grid: 2 cols @ 360px → adjust padding until 2 fit
  [ ] Product grid: 3 cols @ 390-414px → verify 3 items per row
  [ ] Product grid: 4+ cols @ 768px+ → optimal spacing on tablet

Expected Results:
  360px:  2 columns × (360-32)/2 = 164px each
  390px:  3 columns × (390-32)/3 = 119px each (small forced 2 cols)
  414px:  3 columns × (414-32)/3 = 127px each
  768px:  4 columns × (768-32)/4 = 184px each

================================================================================
KEYBOARD BEHAVIOR
================================================================================

Test text input (Phone & Tablet):
  [ ] Keyboard appears without hiding CTA buttons
  [ ] Keyboard dismisses when input unfocused
  [ ] Focus moves to next field on keyboard "Next" (not "Done")
  [ ] Properly using ResizableKeyboardView pattern

================================================================================
IMAGE LOADING PERFORMANCE
================================================================================

Test on slow 3G network (DevTools → slow network):
  [ ] Skeleton loaders appear while images load
  [ ] Placeholder images visible in dark mode
  [ ] No white flashes on transparent backgrounds
  [ ] Loading completes within 2-3 seconds

================================================================================
DARK MODE RESPONSIVE TESTING
================================================================================

Repeat entire checklist above with Dark Mode enabled:
  [ ] Text contrast sufficient on all sizes
  [ ] Shadows visible (opacity adjusted)
  [ ] Images render properly on dark backgrounds
  [ ] Input fields visible in dark mode
  [ ] Icons/buttons stand out from background

================================================================================
TESTING SUMMARY
================================================================================

After testing all device sizes, fill this summary:

DEVICE          | STATUS  | NOTES
360×640 (Small) | [ ] OK  | 
390×844 (Medium)| [ ] OK  | 
414×896 (Large) | [ ] OK  | 
768×1024 (Tab)  | [ ] OK  | 
Dark Mode All   | [ ] OK  | 

Overall Status: [ ] PASS  [ ] NEEDS FIXES

Issues Found:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

================================================================================
RESPONSIVE HELPER UTILITIES - USAGE REFERENCE
================================================================================

import 'package:flutter/material.dart';
import 'lib/core/utils/responsive_helper.dart';

// Get current device size
final size = ResponsiveHelper.getDeviceSizeFromContext(context);

// Get responsive padding based on device
final padding = ResponsiveHelper.getResponsivePadding(context);
// Returns: 12px (small), 16px (medium), 20px (large)

// Get grid columns automatically
final columns = ResponsiveHelper.getGridColumns(context);
// Returns: 2 (phone), 3 (large phone), 4+ (tablet)

// Use ResponsiveBuilder for conditional UI
ResponsiveBuilder(
  builder: (context, size) {
    if (size == DeviceSize.small) {
      return Column(...);  // Stack vertically
    } else {
      return Row(...);     // Show side-by-side
    }
  },
)

// Use ResponsiveContainer for centered max-width layout
ResponsiveContainer(
  padding: 16,
  child: Container(...),  // Will be centered and max 1200px on tablet
)

================================================================================
END OF RESPONSIVE TESTING GUIDE
================================================================================
