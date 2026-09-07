import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_images.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/firestore_auth_service.dart';
import '../../core/themes/app_themes.dart';
import 'dialogs/verified_dialogs.dart';

class NumberVerificationPage extends StatefulWidget {
  const NumberVerificationPage({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  State<NumberVerificationPage> createState() => _NumberVerificationPageState();
}

class _NumberVerificationPageState extends State<NumberVerificationPage> {
  String? _verificationId;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _sendVerificationCode();
    }
  }

  Future<void> _sendVerificationCode() async {
    if (widget.phoneNumber == null) return;

    setState(() => _isResending = true);

    final authService = FirestoreAuthService();
    await authService.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber!,
      onAutoVerified: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) _showVerificationDialog();
      },
      onCodeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _isResending = false;
        });
      },
      onFailed: (error) {
        if (!mounted) return;
        setState(() => _isResending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ??
                  AppLocalizations.of(context)!.phoneVerificationFailed,
            ),
          ),
        );
      },
    );
  }

  Future<void> _verifyOtp(String otp) async {
    if (_verificationId == null) return;

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) _showVerificationDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? AppLocalizations.of(context)!.invalidOtp,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidOtp)),
      );
    }
  }

  void _showVerificationDialog() {
    showGeneralDialog(
      barrierLabel: 'Dialog',
      barrierDismissible: true,
      context: context,
      pageBuilder: (ctx, anim1, anim2) => const VerifiedDialog(),
      transitionBuilder: (ctx, anim1, anim2, child) =>
          ScaleTransition(scale: anim1, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  margin: const EdgeInsets.all(AppDefaults.margin),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: AppDefaults.borderRadius,
                  ),
                  child: Column(
                    children: [
                      const NumberVerificationHeader(),
                      OTPTextFields(
                        onOtpComplete: _verifyOtp,
                        isVerifying: _isVerifying,
                      ),
                      const SizedBox(height: AppDefaults.padding * 3),
                      ResendButton(
                        onResend: _sendVerificationCode,
                        isResending: _isResending,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      VerifyButton(
                        onPressed: () {},
                        isVerifying: _isVerifying,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                    ],
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

class VerifyButton extends StatelessWidget {
  const VerifyButton({
    super.key,
    required this.onPressed,
    this.isVerifying = false,
  });

  final VoidCallback onPressed;
  final bool isVerifying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Semantics(
        button: true,
        label: l10n.verifyOtp,
        child: ElevatedButton(
          onPressed: isVerifying ? null : onPressed,
          child: isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.verify),
        ),
      ),
    );
  }
}

class ResendButton extends StatelessWidget {
  const ResendButton({
    super.key,
    required this.onResend,
    this.isResending = false,
  });

  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.didntGetCode),
        Semantics(
          button: true,
          label: l10n.resendCode,
          child: TextButton(
            onPressed: isResending
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onResend();
                  },
            child: isResending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.resend),
          ),
        ),
      ],
    );
  }
}

class NumberVerificationHeader extends StatelessWidget {
  const NumberVerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: AppDefaults.padding),
        Semantics(
          header: true,
          child: Text(
            l10n.enterYourDigitCode,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppDefaults.padding),
        Semantics(
          image: true,
          label: 'Phone verification illustration',
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: const AspectRatio(
              aspectRatio: 1 / 1,
              child: NetworkImageWithLoader(AppImages.numberVerfication),
            ),
          ),
        ),
        const SizedBox(height: AppDefaults.padding * 3),
      ],
    );
  }
}

class OTPTextFields extends StatefulWidget {
  const OTPTextFields({
    super.key,
    required this.onOtpComplete,
    this.isVerifying = false,
  });

  final Function(String otp) onOtpComplete;
  final bool isVerifying;

  @override
  State<OTPTextFields> createState() => _OTPTextFieldsState();
}

class _OTPTextFieldsState extends State<OTPTextFields>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0)).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _triggerShake() {
    HapticFeedback.vibrate();
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _validateOTP() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4 && otp.split('').every((c) => c.isNotEmpty)) {
      HapticFeedback.lightImpact();
      widget.onOtpComplete(otp);
    } else {
      _triggerShake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _shakeAnimation,
      child: Theme(
        data: AppTheme.defaultTheme.copyWith(
          inputDecorationTheme: AppTheme.otpInputDecorationTheme,
        ),
        child: Semantics(
          label: 'OTP Input',
          enabled: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              return Semantics(
                label: 'Digit ${index + 1} of 4',
                textField: true,
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: !widget.isVerifying,
                    onChanged: (v) {
                      if (v.length == 1) {
                        if (index < 3) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_focusNodes[index + 1]);
                        } else {
                          _focusNodes[index].unfocus();
                          _validateOTP();
                        }
                      } else if (v.isEmpty && index > 0) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index - 1]);
                      }
                    },
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    obscureText: false,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
