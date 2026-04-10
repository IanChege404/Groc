import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AfriErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final bool showButton;
  final Widget? illustration;

  const AfriErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonLabel = 'Try Again',
    this.onButtonPressed,
    this.showButton = true,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (illustration != null) ...[
              SizedBox(width: 120, height: 120, child: illustration!),
              const SizedBox(height: 24),
            ] else ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark
                    ? AppColors.onSurfaceDark
                    : AppColors.onSurfaceLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.subtleDark : AppColors.subtleLight,
                ),
              ),
            ],
            if (showButton && buttonLabel != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  child: Text(buttonLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
