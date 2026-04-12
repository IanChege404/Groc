import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

/// M-Pesa STK Push Processing Screen
///
/// Shown while waiting for M-Pesa STK push confirmation from the phone.
/// Displays animated phone icon, countdown, and resend/cancel actions.
class MpesaProcessingScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? amount;

  const MpesaProcessingScreen({super.key, this.phoneNumber, this.amount});

  @override
  State<MpesaProcessingScreen> createState() => _MpesaProcessingScreenState();
}

class _MpesaProcessingScreenState extends State<MpesaProcessingScreen>
    with TickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _timer;
  bool _canResend = false;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _waveAnimation;

  static const int _countdownSeconds = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _countdownSeconds;
    _startCountdown();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for logo
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    // Wave animation for phone icon
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _timer?.cancel();
          _canResend = true;
          _secondsRemaining = 0;
        }
      });
    });
  }

  Future<void> _resendRequest() async {
    if (_canResend) {
      setState(() {
        _secondsRemaining = _countdownSeconds;
        _canResend = false;
      });
      _startCountdown();
    }
  }

  void _cancel() {
    _timer?.cancel();
    _pulseController.dispose();
    Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.spacingLg,
            vertical: AppDefaults.spacingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // M-Pesa Logo / Identity with rotation
              RotationTransition(
                turns: _rotateAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00A651), // M-Pesa Green
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDefaults.spacingXl),

              // Pulsing Phone Icon with wave effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer wave circle
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.8).animate(
                      CurvedAnimation(
                        parent: _waveController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(
                                alpha: (1 - _waveAnimation.value) * 0.3,
                              ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Phone icon with pulse
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Icon(
                      Icons.phone,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDefaults.spacingXl),

              // "Check your phone" Message
              Text(
                'Check Your Phone',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDefaults.spacingMd),

              // Instruction Subtext
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.spacingMd,
                ),
                child: Text(
                  'We\'ve sent a payment request of ${widget.amount ?? 'KES 1,400'} to ${widget.phoneNumber ?? '+254 7XX XXX XXX'}. Enter your M-Pesa PIN to complete.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppDefaults.spacingXl),

              // Countdown Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.spacingLg,
                  vertical: AppDefaults.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Request expires in',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDefaults.spacingSm),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDefaults.spacingXl),

              const Spacer(flex: 1),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canResend ? _resendRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canResend
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDefaults.borderRadius,
                    ),
                    disabledBackgroundColor: Theme.of(context).disabledColor,
                  ),
                  child: Text(
                    _canResend ? 'Resend Request' : 'Waiting...',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDefaults.spacingMd),

              // Cancel Button
              GestureDetector(
                onTap: _cancel,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDefaults.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
