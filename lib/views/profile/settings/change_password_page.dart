import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/firestore_auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSignInAgain)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentController.text,
      );
      await user.reauthenticateWithCredential(credential);

      final result = await FirestoreAuthService().changePassword(
        _newController.text,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.passwordUpdatedSuccess)),
        );
        Navigator.pop(context);
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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message ??
                AppLocalizations.of(context)!.passwordUpdateFailed)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.errorUpdatingPassword}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.updatePassword),
      ),
      backgroundColor: AppColors.cardColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(AppDefaults.padding),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: AppDefaults.padding * 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: AppDefaults.borderRadius,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.currentPassword),
                  const SizedBox(height: 8),
                  Semantics(
                    label: l10n.currentPassword,
                    child: TextFormField(
                      controller: _currentController,
                      obscureText: _obscureCurrent,
                      validator: (value) => (value == null || value.isEmpty)
                          ? l10n.requiredField(l10n.currentPassword)
                          : null,
                      decoration: InputDecoration(
                        labelText: l10n.currentPassword,
                        suffixIcon: Material(
                          color: Colors.transparent,
                          child: Semantics(
                            button: true,
                            label: _obscureCurrent
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            child: IconButton(
                              icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  Text(l10n.newPassword),
                  const SizedBox(height: 8),
                  Semantics(
                    label: l10n.newPassword,
                    child: TextFormField(
                      controller: _newController,
                      obscureText: _obscureNew,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.requiredField(l10n.newPassword);
                        }
                        if (value.length < 8) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: l10n.newPassword,
                        suffixIcon: Material(
                          color: Colors.transparent,
                          child: Semantics(
                            button: true,
                            label: _obscureNew
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            child: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  Text(l10n.confirmPassword),
                  const SizedBox(height: 8),
                  Semantics(
                    label: l10n.confirmPassword,
                    child: TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.requiredField(l10n.confirmPassword);
                        }
                        if (value != _newController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                        suffixIcon: Material(
                          color: Colors.transparent,
                          child: Semantics(
                            button: true,
                            label: _obscureConfirm
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            child: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: l10n.updatePassword,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _updatePassword,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.updatePassword),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
