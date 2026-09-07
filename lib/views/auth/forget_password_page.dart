import 'package:flutter/material.dart';

import '../../core/components/afri_button.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/firestore_auth_service.dart';
import 'package:go_router/go_router.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  late TextEditingController phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final authService = FirestoreAuthService();
    final result = await authService.sendPasswordResetEmail(
      phoneController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordResetLinkSent),
        ),
      );
      context.push('/passwordReset');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                AppLocalizations.of(context)!.failedToSendResetLink,
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
        title: Text(l10n.forgotPassword),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: SafeArea(
        child: Center(
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
                            l10n.resetYourPassword,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppDefaults.padding),
                        Text(l10n.resetPasswordDescription),
                        const SizedBox(height: AppDefaults.padding * 3),
                        Semantics(
                          label: l10n.phoneNumber,
                          child: Text(l10n.phoneNumber),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          label: l10n.phoneNumber,
                          child: TextFormField(
                            controller: phoneController,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            onFieldSubmitted: (_) => _onSubmit(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.requiredField(l10n.phoneNumber);
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: l10n.phoneNumber,
                              hintText: l10n.emailHint,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDefaults.padding),
                        AfriButton(
                          label: l10n.sendMeLink,
                          isLoading: _isSubmitting,
                          isDisabled: _isSubmitting,
                          onPressed: _onSubmit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
