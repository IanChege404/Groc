import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable animation utilities for consistent micro-interactions
class AnimationUtils {
  // ========== BUTTON PRESS FEEDBACK ==========
  /// Scales button on press with haptic feedback
  static Future<void> buttonPressAnimation(BuildContext context) async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Haptics not supported
    }
  }

  /// Creates scale-down animation for button press
  static Widget scaleOnPress({
    required Widget child,
    required VoidCallback onTap,
    double scaleFactor = 0.95,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: duration,
        scale: 1.0,
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }

  // ========== CART ITEM DELETION ANIMATION ==========
  /// Slide + fade animation for removing cart items
  static Widget slideAndFadeOut({
    required Widget child,
    required VoidCallback onAnimationComplete,
    Duration duration = const Duration(milliseconds: 400),
    bool shouldAnimate = false,
  }) {
    return AnimatedSlide(
      duration: duration,
      offset: shouldAnimate ? const Offset(1, 0) : Offset.zero,
      curve: Curves.easeInOut,
      onEnd: shouldAnimate ? onAnimationComplete : null,
      child: AnimatedOpacity(
        duration: duration,
        opacity: shouldAnimate ? 0 : 1,
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }

  // ========== WISHLIST HEART ANIMATION ==========
  /// Pop animation on wishlist heart tap
  static Widget popAnimation({
    required Widget child,
    required bool isAnimating,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return AnimatedScale(
      duration: duration,
      scale: !isAnimating ? 1.0 : 1.2,
      curve: Curves.elasticOut,
      child: AnimatedRotation(
        duration: duration,
        turns: !isAnimating ? 0 : 0.1,
        child: child,
      ),
    );
  }

  // ========== SKELETON-TO-CONTENT FADE ==========
  /// Fade-in transition from skeleton to content
  static Widget skeletonFadeTransition({
    required Widget skeleton,
    required Widget content,
    required bool isLoading,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return AnimatedCrossFade(
      firstChild: skeleton,
      secondChild: content,
      crossFadeState: isLoading
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: duration,
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
    );
  }

  // ========== OTP BOX SHAKE ON ERROR ==========
  /// Shake animation for OTP input error feedback
  static Widget shakeAnimation({
    required Widget child,
    required bool shouldShake,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: shouldShake ? 1 : 0),
      duration: duration,
      curve: shouldShake ? Curves.elasticInOut : Curves.easeOut,
      builder: (context, value, _) {
        final shakeAmount = shouldShake
            ? 10 * (value - value.truncate()).sign
            : 0;
        final dx = shakeAmount.toDouble();
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }

  /// Simple shake widget alternative
  static Widget simpleShake({
    required Widget child,
    required bool trigger,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return ShakeWidget(
      key: ValueKey(trigger),
      duration: duration,
      child: child,
    );
  }

  // ========== RATING BAR TAP ANIMATION ==========
  /// Ripple effect on rating bar star tap
  static Widget ratingStarAnimation({
    required int starIndex,
    required int currentRating,
    required VoidCallback onTap,
    double size = 32,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: starIndex == currentRating ? 1.2 : 1.0,
        curve: Curves.elasticOut,
        child: Icon(
          starIndex <= currentRating ? Icons.star : Icons.star_border,
          size: size,
          color: Colors.amber,
        ),
      ),
    );
  }

  // ========== BOTTOM SHEET CURVES ==========
  /// Custom animation curve for bottom sheet enter/exit
  static Future<T?> animatedBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return showModalBottomSheet<T>(context: context, builder: builder);
  }

  // ========== PAGE TRANSITION VARIANTS ==========
  /// Slide transition from right
  static Route slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition
  static Route fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Scale transition (pops in)
  static Route scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// ========== SHAKE WIDGET (STATEFUL) ==========
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        const double shakeOffset = 10.0;
        final progress = _controller.value;
        final shake = shakeOffset * (0.5 - (progress - 0.5).abs());
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: widget.child,
    );
  }
}
