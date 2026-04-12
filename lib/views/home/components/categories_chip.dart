import 'package:flutter/material.dart';
import '../../../core/constants/app_defaults.dart';

import '../../../core/constants/app_colors.dart';

class CategoriesChip extends StatelessWidget {
  const CategoriesChip({
    super.key,
    required this.isActive,
    required this.label,
    required this.onPressed,
  });

  final bool isActive;
  final String label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive
            ? Theme.of(context).colorScheme.onPrimary
            : AppColors.placeholder,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.padding * 1.5,
        ),
        minimumSize: const Size(40, 48),
        backgroundColor: isActive
            ? AppColors.primary
            : Theme.of(context).colorScheme.surface,
        side: const BorderSide(color: AppColors.primary),
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      child: Text(label),
    );
  }
}
