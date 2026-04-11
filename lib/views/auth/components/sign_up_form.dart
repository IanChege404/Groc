import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firestore_auth_service.dart';
import '../../../core/utils/validators.dart';
import 'already_have_accout.dart';
import 'sign_up_button.dart';

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
    final nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.entryPoint,
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message ?? 'Signup failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.margin),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppDefaults.boxShadow,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              validator: Validators.requiredWithFieldName('Name').call,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Email"),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              validator: Validators.email.call,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: phoneController,
              textInputAction: TextInputAction.next,
              validator: Validators.required.call,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              validator: Validators.password.call,
              textInputAction: TextInputAction.done,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: Material(
                  color: Colors.transparent,
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
            ),
            const SizedBox(height: AppDefaults.padding),
            SignUpButton(onPressed: isSubmitting ? null : _onSignup),
            const AlreadyHaveAnAccount(),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }
}
