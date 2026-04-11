import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/firestore_auth_service.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/validators.dart';
import 'login_button.dart';

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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.entryPoint,
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message ?? 'Login failed')));
  }

  @override
  Widget build(BuildContext context) {
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
              // Email Field
              const Text("Email"),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email.call,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              // Password Field
              const Text("Password"),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                validator: Validators.password.call,
                onFieldSubmitted: (v) => onLogin(),
                textInputAction: TextInputAction.done,
                obscureText: !isPasswordShown,
                decoration: InputDecoration(
                  suffixIcon: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: onPassShowClicked,
                      icon: SvgPicture.asset(AppIcons.eye, width: 24),
                    ),
                  ),
                ),
              ),

              // Forget Password labelLarge
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text('Forget Password?'),
                ),
              ),

              // Login labelLarge
              LoginButton(onPressed: isSubmitting ? null : onLogin),
            ],
          ),
        ),
      ),
    );
  }
}
