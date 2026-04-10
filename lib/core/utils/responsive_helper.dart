import 'package:flutter/material.dart';

/// Device size categories
enum DeviceSize { small, medium, large, tablet }

class ResponsiveHelper {
  // ========== DEVICE BREAKPOINTS ==========
  /// Small phone: 360×640 (Galaxy A series, common in Kenya)
  static const double smallWidth = 360;
  static const double smallHeight = 640;

  /// Medium phone: ~390×844 (iPhone 14/15 standard)
  static const double mediumWidth = 390;
  static const double mediumHeight = 844;

  /// Large phone: 414×896 (iPhone Pro Max)
  static const double largeWidth = 414;
  static const double largeHeight = 896;

  /// Tablet: 768×1024 (iPad Mini)
  static const double tabletWidth = 768;
  static const double tabletHeight = 1024;

  // ========== DEVICE SIZE DETECTION ==========
  static DeviceSize getDeviceSize(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    if (width >= tabletWidth) return DeviceSize.tablet;
    if (width >= largeWidth) return DeviceSize.large;
    if (width >= mediumWidth) return DeviceSize.medium;
    return DeviceSize.small;
  }

  static DeviceSize getDeviceSizeFromContext(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getDeviceSize(BoxConstraints(maxWidth: width));
  }

  static bool isSmallDevice(BuildContext context) =>
      getDeviceSizeFromContext(context) == DeviceSize.small;

  static bool isTablet(BuildContext context) =>
      getDeviceSizeFromContext(context) == DeviceSize.tablet;

  // ========== SAFE AREA HELPERS ==========
  /// Get safe insets from MediaQuery
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get bottom safe area (for notch/home indicator)
  static double getBottomSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// Get top safe area (for notch)
  static double getTopSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// Get viewinsets (keyboard height)
  static double getKeyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  static bool isKeyboardVisible(BuildContext context) =>
      getKeyboardHeight(context) > 0;

  // ========== RESPONSIVE PADDING/MARGIN ==========
  /// Scale padding based on device size
  static double getResponsivePadding(BuildContext context) {
    final size = getDeviceSizeFromContext(context);
    switch (size) {
      case DeviceSize.small:
        return 12; // Tight spacing for small phones
      case DeviceSize.medium:
        return 16; // Standard
      case DeviceSize.large:
      case DeviceSize.tablet:
        return 20; // More breathing room on large screens
    }
  }

  /// Scale margins based on device width
  static double getResponsiveMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 12;
    if (width < 600) return 16;
    return 24;
  }

  /// Dynamic horizontal padding with safe area awareness
  static EdgeInsets getResponsiveHPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Dynamic vertical padding with safe area awareness
  static EdgeInsets getResponsiveVPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(vertical: padding);
  }

  // ========== LAYOUT BREAKPOINTS ==========
  /// Number of columns for grid based on device
  static int getGridColumns(BuildContext context) {
    final size = getDeviceSizeFromContext(context);
    switch (size) {
      case DeviceSize.small:
        return 2;
      case DeviceSize.medium:
        return 2;
      case DeviceSize.large:
        return 2;
      case DeviceSize.tablet:
        return 3;
    }
  }

  /// Cross axis extent for gridview
  static double getGridCrossAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = getGridColumns(context);
    return (width - 32) / columns; // 32 = 16 padding on each side
  }

  /// Get container max width for centered layouts (common for tablet)
  static double getMaxContainerWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 900; // Desktop-like
    if (width > 768) return 600; // Tablet in portrait
    return width; // Phone
  }

  // ========== RESPONSIVE FONT SIZES ==========
  static double getResponsiveFontSize(
    BuildContext context, {
    double smallSize = 14,
    double mediumSize = 16,
    double largeSize = 18,
  }) {
    final size = getDeviceSizeFromContext(context);
    switch (size) {
      case DeviceSize.small:
        return smallSize;
      case DeviceSize.medium:
        return mediumSize;
      case DeviceSize.large:
      case DeviceSize.tablet:
        return largeSize;
    }
  }

  // ========== ORIENTATION HELPERS ==========
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Get viewport height (useful for full-screen layouts)
  static double getViewportHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return size.height - padding.top - padding.bottom;
  }

  /// Get viewport width
  static double getViewportWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return size.width - padding.left - padding.right;
  }

  // ========== ASPECT RATIO SCALERS ==========
  /// Get scaled height maintaining aspect ratio
  static double getScaledHeight(
    BuildContext context,
    double baseHeight,
    double baseWidth,
  ) {
    final screenWidth = getViewportWidth(context);
    return (screenWidth / baseWidth) * baseHeight;
  }
}

// ========== RESPONSIVE WIDGET BUILDER ==========
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceSize) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.getDeviceSizeFromContext(context);
    return builder(context, size);
  }
}

// ========== RESPONSIVE CONTAINER ==========
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContainerWidth(context),
          ),
          child: Padding(
            padding: padding ?? ResponsiveHelper.getResponsiveHPadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}
