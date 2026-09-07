import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';

class AdSpace extends StatelessWidget {
  const AdSpace({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Semantics(
        label: AppLocalizations.of(context)!.adSpace,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const AspectRatio(
            aspectRatio: 16 / 9,
            child: NetworkImageWithLoader(
              'https://i.imgur.com/8hBIsS5.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
