import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ChipVariant { filter, category, status }

class AfriChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final ChipVariant variant;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final bool showDeleteButton;
  final VoidCallback? onDelete;

  const AfriChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onPressed,
    this.variant = ChipVariant.filter,
    this.icon,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = selectedBackgroundColor ?? AppColors.primary;
    final fgColor = selectedTextColor ?? AppColors.onPrimaryLight;

    switch (variant) {
      case ChipVariant.filter:
        return _buildFilterChip(bgColor, fgColor, isDark);
      case ChipVariant.category:
        return _buildCategoryChip(isDark);
      case ChipVariant.status:
        return _buildStatusChip(isDark);
    }
  }

  Widget _buildFilterChip(Color bgColor, Color fgColor, bool isDark) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed?.call(),
      backgroundColor:
          backgroundColor ??
          (isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight),
      selectedColor: bgColor,
      labelStyle: TextStyle(
        color: selected
            ? fgColor
            : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? bgColor
              : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(bool isDark) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.onSurfaceDark
                    : AppColors.onSurfaceLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
    final Color statusColor = _getStatusColor(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(bool isDark) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('processing') || lowerLabel.contains('pending')) {
      return AppColors.warning;
    } else if (lowerLabel.contains('delivered') ||
        lowerLabel.contains('completed')) {
      return AppColors.success;
    } else if (lowerLabel.contains('cancelled') ||
        lowerLabel.contains('failed')) {
      return AppColors.error;
    } else if (lowerLabel.contains('shipped') ||
        lowerLabel.contains('in-transit')) {
      return AppColors.info;
    }
    return isDark ? AppColors.subtleDark : AppColors.subtleLight;
  }
}
