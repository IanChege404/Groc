import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/firestore_auth_service.dart';

class ChangePhoneNumberPage extends ConsumerStatefulWidget {
  const ChangePhoneNumberPage({super.key});

  @override
  ConsumerState<ChangePhoneNumberPage> createState() =>
      _ChangePhoneNumberPageState();
}

class _ChangePhoneNumberPageState extends ConsumerState<ChangePhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _confirmPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isSending = false;
  bool _isVerifying = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _confirmPhoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final phone = _phoneController.text.trim();
    final result = await FirestoreAuthService().verifyPhoneNumber(
      phoneNumber: phone,
      onAutoVerified: (credential) async {
        await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);
      },
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        if (mounted) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to phone number')),
          );
        }
      },
      onFailed: (error) {
        if (mounted) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Verification failed')),
          );
        }
      },
    );

    if (!mounted) return;
    if (!result.success) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyAndUpdate() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please request OTP first')));
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'Please sign in again to update your phone number.',
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      final result = await FirestoreAuthService().updatePhoneNumber(credential);

      if (result.success) {
        await _firestoreService.updateUserProfile(user.uid, {
          'phone': _phoneController.text.trim(),
        });

        ref.invalidate(userProfileProvider);
        ref.invalidate(userDataProvider(user.uid));
      }

      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? 'Phone number updated'
                : (result.message ?? 'Update failed'),
          ),
        ),
      );
      if (result.success) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Change Phone Number'),
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
                  const Text('New Phone Number'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter a valid phone number'
                        : null,
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const Text('Retype Phone Number'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value != _phoneController.text
                        ? 'Phone numbers do not match'
                        : null,
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendOtp,
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send OTP'),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const Text('OTP Code'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Enter the OTP code'
                        : null,
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyAndUpdate,
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Phone Number'),
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
