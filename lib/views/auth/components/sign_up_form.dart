import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/afri_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/firestore_auth_service.dart';
import '../../../core/utils/validators.dart';
import 'already_have_accout.dart';
import 'package:go_router/go_router.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreAuthService _authService = FirestoreAuthService();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  bool isPasswordVisible = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || isSubmitting) {
      return;
    }

    final fullName = nameController.text.trim();
    final nameParts =
        fullName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    setState(() {
      isSubmitting = true;
    });

    final result = await _authService.signup(
      firstName: firstName,
      lastName: lastName,
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
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
          content: Text(
              result.message ?? AppLocalizations.of(context)!.signupFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(AppDefaults.margin),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: AppDefaults.boxShadow,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: l10n.name,
              child: Text(l10n.name),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: l10n.name,
              child: TextFormField(
                controller: nameController,
                validator: Validators.requiredWithFieldName(l10n.name).call,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.nameHint,
                  suffixIcon: const Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Semantics(
              label: l10n.email,
              child: Text(l10n.email),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: l10n.email,
              child: TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                validator: Validators.email.call,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: l10n.email,
                  hintText: l10n.emailHint,
                  suffixIcon: const Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Semantics(
              label: l10n.phoneNumber,
              child: Text(l10n.phoneNumber),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: l10n.phoneNumber,
              child: TextFormField(
                controller: phoneController,
                textInputAction: TextInputAction.next,
                validator: Validators.required.call,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  hintText: l10n.phoneHint,
                  suffixIcon: const Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
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
                textInputAction: TextInputAction.done,
                obscureText: !isPasswordVisible,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: l10n.password,
                  hintText: l10n.passwordHint,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '*',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Semantics(
                          button: true,
                          label: isPasswordVisible
                              ? 'Hide password'
                              : 'Show password',
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            icon: SvgPicture.asset(AppIcons.eye, width: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            AfriButton(
              label: l10n.signUp,
              isLoading: isSubmitting,
              isDisabled: isSubmitting,
              onPressed: _onSignup,
            ),
            const AlreadyHaveAnAccount(),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }
}
