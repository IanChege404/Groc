import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class VerifiedDialog extends StatelessWidget {
  const VerifiedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDefaults.padding * 3,
          horizontal: AppDefaults.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              image: true,
              label: 'Verification success illustration',
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: const AspectRatio(
                  aspectRatio: 1 / 1,
                  child: NetworkImageWithLoader(
                    AppImages.verified,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Semantics(
              header: true,
              child: Text(
                l10n.verified,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Text(
              l10n.verifiedSuccessMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDefaults.padding),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/entry_point'),
                child: Text(l10n.browseHome),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
