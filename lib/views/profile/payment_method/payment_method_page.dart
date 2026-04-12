import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/retryable_error_view.dart';
import '../../../core/constants/app_defaults.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/mixins/refresh_on_return_mixin.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/services/firestore_service.dart';
import 'components/new_card_row.dart';
import 'components/default_card.dart';
import 'components/payment_option_tile.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage>
    with RefreshOnReturnMixin<PaymentMethodPage> {
  final _firestoreService = FirestoreService();

  @override
  Future<void> onRefreshRequested() async {
    final userId = ref.read(authProvider).value;
    if (userId != null && userId.isNotEmpty) {
      ref.invalidate(paymentMethodsProvider(userId));
    }
  }

  Future<void> _deleteMethod(String methodId) async {
    final userId = ref.read(authProvider).value;
    if (userId == null || userId.isEmpty) return;

    await _firestoreService.deletePaymentMethod(userId, methodId);
    ref.invalidate(paymentMethodsProvider(userId));
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value;
    final methodsAsync = userId == null || userId.isEmpty
        ? const AsyncValue<List<Map<String, dynamic>>>.data([])
        : ref.watch(paymentMethodsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment Option'),
      ),
      body: methodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RetryableErrorView(
          title: 'Unable to load payment methods',
          message:
              'Please check your connection and try again. ${error.toString()}',
          onRetry: () => onRefreshRequested(),
        ),
        data: (methods) => RefreshIndicator(
          onRefresh: onRefreshRequested,
          child: ListView(
            children: [
              const SizedBox(height: AppDefaults.padding),
              const AddNewCardRow(),
              if (methods.isNotEmpty) const PaymentDefaultCard(),
              Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Text(
                  'Saved Payment Methods',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (methods.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppDefaults.padding),
                  child: Text('No saved payment methods yet'),
                )
              else
                ...methods.map(
                  (method) => PaymentOptionTile(
                    icon: (method['brand'] as String?) == 'mastercard'
                        ? 'https://i.imgur.com/7pI5714.png'
                        : 'https://i.imgur.com/lLUcMC1.png',
                    label: (method['label'] as String?) ?? 'Card',
                    accountName: '•••• ${method['last4'] as String? ?? '0000'}',
                    onTap: () => _deleteMethod(method['id'] as String),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
