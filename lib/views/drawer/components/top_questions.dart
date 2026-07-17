import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/constants.dart';
import 'help_models.dart';

class TopQuestions extends StatelessWidget {
  const TopQuestions({super.key, required this.items, required this.onTap});

  final List<HelpQuestionItem> items;
  final ValueChanged<HelpQuestionItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDefaults.padding / 2),
        Text(
          'Top Questions',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDefaults.padding / 2),
        for (final question in items)
          AppSettingsListTile(
            label: question.question,
            trailing: SvgPicture.asset(AppIcons.right),
            onTap: () => onTap(question),
          ),
      ],
    );
  }
}
