import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isNavigating = false;

  static const String _onboardingKey = AppPreferenceKeys.onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/splash_animation.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    if (_isNavigating) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    // Navigate when video reaches the end (or near end)
    if (position >= duration - const Duration(milliseconds: 300)) {
      _navigateToApp();
    }
  }

  Future<void> _navigateToApp() async {
    if (_isNavigating) return;
    _isNavigating = true;

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(_onboardingKey) ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (currentUser != null) {
      context.go('/entry_point');
    } else if (!onboardingDone) {
      context.go('/onboarding');
    } else {
      context.go('/intro_login');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}