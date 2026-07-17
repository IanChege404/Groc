import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/constants.dart';
import 'package:go_router/go_router.dart';

class AddNewCardRow extends StatelessWidget {
  const AddNewCardRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Row(
        children: [
          Text(
            'My Card',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.push('/paymentCardAdd');
            },
            icon: SvgPicture.asset(AppIcons.cardAdd),
          ),
        ],
      ),
    );
  }
}
