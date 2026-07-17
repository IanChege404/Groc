import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/providers/referral_provider.dart';
import '../../core/utils/logger.dart';

class ReferralCodeEntryScreen extends ConsumerStatefulWidget {
  const ReferralCodeEntryScreen({super.key});

  @override
  ConsumerState<ReferralCodeEntryScreen> createState() =>
      _ReferralCodeEntryScreenState();
}

class _ReferralCodeEntryScreenState
    extends ConsumerState<ReferralCodeEntryScreen> {
  late TextEditingController _codeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Referral Code'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter a referral code to get rewards',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: 'Enter code (e.g., ABC12345)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.card_giftcard_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _codeController.text.isEmpty
                        ? null
                        : () => _validateAndApplyCode(),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Apply Code'),
                  ),
                ),
                const SizedBox(height: 24),
                _InfoCard(
                  title: 'How it works',
                  items: [
                    'Enter the 8-character referral code',
                    'Complete your first purchase',
                    'Both you and the referrer get rewards!',
                  ],
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Rewards',
                  items: [
                    'You receive: 200 KES',
                    'Referrer receives: 500 KES',
                    'No limit on how many times you refer!',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _validateAndApplyCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError('Please enter a code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final referral = await ref
          .read(getReferralByCodeProvider(code).future)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => null,
          );

      if (!mounted) return;

      if (referral == null) {
        _showError('Invalid referral code');
        setState(() => _isLoading = false);
        return;
      }

      _showSuccess(
        'Code validated!',
        'You will receive 200 KES after your first purchase.',
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context, code);
      });
    } catch (e, stack) {
      Logger.error(
        'Error validating referral code: $e\nStack: $stack',
        '_ReferralCodeEntryScreenState._validateAndApplyCode',
      );
      _showError('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
