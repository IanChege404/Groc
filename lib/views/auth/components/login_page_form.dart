import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/components/afri_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/firestore_auth_service.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/validators.dart';
import 'package:go_router/go_router.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({super.key});

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  final _key = GlobalKey<FormState>();
  final FirestoreAuthService _authService = FirestoreAuthService();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool isPasswordShown = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  onPassShowClicked() {
    isPasswordShown = !isPasswordShown;
    setState(() {});
  }

  Future<void> onLogin() async {
    final bool isFormOkay = _key.currentState?.validate() ?? false;
    if (!isFormOkay || isSubmitting) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final result = await _authService.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSubmitting = false;
    });

    if (result.success) {
      context.go('/entry_point');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(result.message ?? AppLocalizations.of(context)!.loginFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: AppTheme.defaultTheme.copyWith(
        inputDecorationTheme: AppTheme.secondaryInputDecorationTheme,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: l10n.email,
                child: Text(l10n.email),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: l10n.email,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email.call,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: l10n.emailHint,
                  ),
                ),
              ),
              const SizedBox(height: AppDefaults.padding),
              Semantics(
                label: l10n.password,
                child: Text(l10n.password),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: l10n.password,
                child: TextFormField(
                  controller: passwordController,
                  validator: Validators.password.call,
                  onFieldSubmitted: (v) => onLogin(),
                  textInputAction: TextInputAction.done,
                  obscureText: !isPasswordShown,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    hintText: l10n.passwordHint,
                    suffixIcon: Material(
                      color: Colors.transparent,
                      child: Semantics(
                        button: true,
                        label:
                            isPasswordShown ? 'Hide password' : 'Show password',
                        child: IconButton(
                          onPressed: onPassShowClicked,
                          icon: SvgPicture.asset(AppIcons.eye, width: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push('/forgotPassword');
                  },
                  child: Text(l10n.forgotPassword),
                ),
              ),
              AfriButton(
                label: l10n.login,
                isLoading: isSubmitting,
                isDisabled: isSubmitting,
                onPressed: onLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
