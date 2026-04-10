import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../utils/animation_utils.dart';

enum AfriButtonVariant { primary, secondary, ghost }

class AfriButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AfriButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextStyle? textStyle;

  const AfriButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AfriButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52,
    this.prefixIcon,
    this.suffixIcon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (variant == AfriButtonVariant.primary) {
      return _buildPrimaryButton(context, isDark);
    } else if (variant == AfriButtonVariant.secondary) {
      return _buildSecondaryButton(context, isDark);
    } else {
      return _buildGhostButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading || isDisabled
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                await AnimationUtils.buttonPressAnimation(context);
                onPressed?.call();
              },
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? AppColors.onPrimaryDark
                          : AppColors.onPrimaryLight,
                    ),
                  ),
                )
              : _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading || isDisabled
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                await AnimationUtils.buttonPressAnimation(context);
                onPressed?.call();
              },
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                )
              : _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildGhostButton(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: TextButton(
        onPressed: isLoading || isDisabled
            ? null
            : () async {
                HapticFeedback.lightImpact();
                await AnimationUtils.buttonPressAnimation(context);
                onPressed?.call();
              },
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
        Text(label, style: textStyle),
        if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
      ],
    );
  }
}
