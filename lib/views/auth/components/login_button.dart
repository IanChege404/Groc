import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(l10n.login),
      ),
    );
  }
}
