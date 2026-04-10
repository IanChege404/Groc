import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const String _onboardingKey = AppPreferenceKeys.onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _determineInitialRoute();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _determineInitialRoute() async {
    // Allow the splash animation to play briefly
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(_onboardingKey) ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (currentUser != null) {
      // User is already logged in — go straight to the app
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.entryPoint,
        (route) => false,
      );
    } else if (!onboardingDone) {
      // First launch — show onboarding
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.onboarding,
        (route) => false,
      );
    } else {
      // Returning user who is not logged in
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.introLogin,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/app_logo_splash.png',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
  }
}
