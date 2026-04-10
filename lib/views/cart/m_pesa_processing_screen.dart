import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/locale_provider.dart';
import 'package:provider/provider.dart';

/// M-Pesa STK Push Processing Screen
/// Shown while waiting for M-Pesa STK push confirmation on user's phone
class MpesaProcessingScreen extends StatefulWidget {
  final double amount;
  final String phoneNumber;
  final String orderId;

  const MpesaProcessingScreen({
    super.key,
    required this.amount,
    required this.phoneNumber,
    required this.orderId,
  });

  @override
  State<MpesaProcessingScreen> createState() => _MpesaProcessingScreenState();
}

class _MpesaProcessingScreenState extends State<MpesaProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _secondsRemaining = 120; // 2 minute timeout
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();

    // Pulsing animation for phone icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Countdown timer
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 0) {
            _isResendEnabled = true;
          } else {
            _startCountdown();
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = localeProvider.isDarkMode;
    final isEnglish = localeProvider.locale.languageCode == 'en';

    final checkYourPhone = isEnglish ? 'Check Your Phone' : 'Angalia Simu Yako';
    final weVeSent = isEnglish
        ? 'We sent a payment request of KES ${widget.amount.toStringAsFixed(0)} to ${widget.phoneNumber}. Enter your M-Pesa PIN to complete.'
        : 'Tumetuma ombi la malipo la KES ${widget.amount.toStringAsFixed(0)} kwa ${widget.phoneNumber}. Ingiza nambari ya siri ya M-Pesa kumalizia.';
    final requestExpires = isEnglish
        ? 'Request expires in'
        : 'Ombi lilihitimisha katika';
    const cancel = 'Cancel';
    final tuma = isEnglish ? 'Resend' : 'Tuma';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // M-Pesa Logo / Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00AD48), // M-Pesa green
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDefaults.spacingXl),

                // Pulsing Phone Icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Icon(
                    Icons.phone_android,
                    size: 80,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppDefaults.spacingXl),

                // Main heading
                Text(
                  checkYourPhone,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: isDark
                        ? AppColors.onBackgroundDark
                        : AppColors.onBackgroundLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDefaults.spacingMdLg),

                // Description
                Text(
                  weVeSent,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDefaults.spacingXl),

                // Countdown
                Column(
                  children: [
                    Text(
                      requestExpires,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.subtleDark
                            : AppColors.subtleLight,
                      ),
                    ),
                    const SizedBox(height: AppDefaults.spacingSm),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: AppTextStyles.displayLarge.copyWith(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDefaults.spacing2xl),

                // Resend button (enabled after countdown)
                if (_isResendEnabled)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _secondsRemaining = 120;
                        _isResendEnabled = false;
                        _startCountdown();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDefaults.spacingLg,
                        vertical: AppDefaults.spacingMd,
                      ),
                    ),
                    child: Text(
                      tuma,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                    ),
                  ),

                const SizedBox(height: AppDefaults.spacingMdLg),

                // Cancel link
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    cancel,
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.subtleDark
                          : AppColors.subtleLight,
                    ),
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
