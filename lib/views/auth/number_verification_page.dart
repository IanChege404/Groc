import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_images.dart';
import '../../core/themes/app_themes.dart';
import 'dialogs/verified_dialogs.dart';

class NumberVerificationPage extends StatelessWidget {
  const NumberVerificationPage({super.key});

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
                  child: const Column(
                    children: [
                      NumberVerificationHeader(),
                      OTPTextFields(),
                      SizedBox(height: AppDefaults.padding * 3),
                      ResendButton(),
                      SizedBox(height: AppDefaults.padding),
                      VerifyButton(),
                      SizedBox(height: AppDefaults.padding),
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
  const VerifyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        button: true,
        label: 'Verify OTP',
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Validation happens in OTPTextFields when last digit is entered
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter all 4 digits')),
            );
          },
          child: const Text('Verify'),
        ),
      ),
    );
  }
}

class ResendButton extends StatelessWidget {
  const ResendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Did you don\'t get code?'),
        Semantics(
          button: true,
          label: 'Resend code',
          child: TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            child: const Text('Resend'),
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
    return Column(
      children: [
        const SizedBox(height: AppDefaults.padding),
        Text(
          'Entry Your 4 digit code',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDefaults.padding),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: const AspectRatio(
            aspectRatio: 1 / 1,
            child: NetworkImageWithLoader(AppImages.numberVerfication),
          ),
        ),
        const SizedBox(height: AppDefaults.padding * 3),
      ],
    );
  }
}

class OTPTextFields extends StatefulWidget {
  const OTPTextFields({super.key});

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
    if (otp.length == 4 && otp == '1234') {
      // Valid OTP
      HapticFeedback.lightImpact();
      _showVerificationDialog();
    } else {
      _triggerShake();
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
