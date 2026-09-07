import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/firestore_auth_service.dart';
import '../../core/utils/validators.dart';
import 'package:go_router/go_router.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final authService = FirestoreAuthService();
    final result = await authService.changePassword(
      newPasswordController.text,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.passwordUpdatedSuccess)),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                AppLocalizations.of(context)!.passwordUpdateFailed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.addNewPassword),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(AppDefaults.margin),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding,
                  vertical: AppDefaults.padding * 3,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: AppDefaults.borderRadius,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.addNewPassword,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: AppDefaults.padding * 3),
                      Semantics(
                        label: l10n.newPassword,
                        child: Text(l10n.newPassword),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: l10n.newPassword,
                        child: TextFormField(
                          controller: newPasswordController,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          obscureText: _isNewPasswordObscured,
                          validator: Validators.password.call,
                          decoration: InputDecoration(
                            labelText: l10n.newPassword,
                            hintText: l10n.passwordHint,
                            suffixIcon: Material(
                              color: Colors.transparent,
                              child: Semantics(
                                button: true,
                                label: _isNewPasswordObscured
                                    ? l10n.showPassword
                                    : l10n.hidePassword,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isNewPasswordObscured =
                                          !_isNewPasswordObscured;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    AppIcons.eye,
                                    width: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      Semantics(
                        label: l10n.confirmPassword,
                        child: Text(l10n.confirmPassword),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: l10n.confirmPassword,
                        child: TextFormField(
                          controller: confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _isConfirmPasswordObscured,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.requiredField(l10n.confirmPassword);
                            }
                            if (value != newPasswordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _onSubmit(),
                          decoration: InputDecoration(
                            labelText: l10n.confirmPassword,
                            hintText: l10n.passwordHint,
                            suffixIcon: Material(
                              color: Colors.transparent,
                              child: Semantics(
                                button: true,
                                label: _isConfirmPasswordObscured
                                    ? l10n.showPassword
                                    : l10n.hidePassword,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordObscured =
                                          !_isConfirmPasswordObscured;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    AppIcons.eye,
                                    width: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDefaults.padding * 2),
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: l10n.done,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _onSubmit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.done),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
