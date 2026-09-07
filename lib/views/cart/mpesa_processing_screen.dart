import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';

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
  late Animation<double> _pulseAnimation;

  static const int _countdownSeconds = 120;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _countdownSeconds;
    _startCountdown();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00A651),
                ),
                child: Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDefaults.spacingXl),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  Icons.phone,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppDefaults.spacingXl),
              Text(
                l10n.mpesaCheckYourPhone,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDefaults.spacingMd),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.spacingMd,
                ),
                child: Text(
                  '${l10n.mpesaWeVeSent(widget.phoneNumber ?? '')}\n\n${l10n.mpesaEnterPin}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDefaults.spacingXl),
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
                      l10n.mpesaTimeoutTitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDefaults.spacingSm),
                    Text(
                      _formatTime(_secondsRemaining),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDefaults.spacingXl),
              const Spacer(flex: 1),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canResend ? _resendRequest : null,
                  child: Text(
                    _canResend ? l10n.mpesaResend : l10n.waiting,
                  ),
                ),
              ),
              const SizedBox(height: AppDefaults.spacingMd),
              TextButton(
                onPressed: _cancel,
                child: Text(l10n.cancel),
              ),
              const SizedBox(height: AppDefaults.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
