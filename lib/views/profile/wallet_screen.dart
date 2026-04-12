import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as p;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/transaction_model.dart';
import '../../core/models/wallet_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final localeProvider = p.Provider.of<LocaleProvider>(context);
    final isDark = localeProvider.isDarkMode;
    final isEnglish = localeProvider.locale.languageCode == 'en';

    final userUid = ref.watch(authProvider);
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Afri Wallet',
          style: AppTextStyles.headline.copyWith(
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: userUid.when(
        data: (uid) {
          if (uid == null || uid.isEmpty) {
            return const Center(child: Text('Please sign in to access wallet'));
          }

          final transactionsAsync = ref.watch(transactionsStreamProvider(uid));

          return walletAsync.when(
            data: (wallet) => SingleChildScrollView(
              child: Column(
                children: [
                  _WalletBalanceCard(
                    wallet: wallet,
                    isDark: isDark,
                    topUpLabel: isEnglish ? 'Top Up' : 'Ongeza',
                    sendLabel: isEnglish ? 'Send' : 'Tuma',
                    withdrawLabel: isEnglish ? 'Withdraw' : 'Toa',
                    onTopUp: () => _showTopUpModal(context, uid, wallet),
                    onSend: () => _showTransferModal(context, uid),
                    onWithdraw: () => _showWithdrawModal(context, uid, wallet),
                  ),
                  const SizedBox(height: AppDefaults.spacingLg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDefaults.spacingMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish
                              ? 'Transaction History'
                              : 'Historia ya Miamala',
                          style: AppTextStyles.headline.copyWith(
                            color: isDark
                                ? AppColors.onBackgroundDark
                                : AppColors.onBackgroundLight,
                          ),
                        ),
                        const SizedBox(height: AppDefaults.spacingMd),
                        Row(
                          children: [
                            _FilterChip(
                              label: isEnglish ? 'All' : 'Yote',
                              isSelected: _filterType == 'all',
                              isDark: isDark,
                              onTap: () => setState(() => _filterType = 'all'),
                            ),
                            const SizedBox(width: AppDefaults.spacingMd),
                            _FilterChip(
                              label: isEnglish ? 'Credits' : 'Mkopo',
                              isSelected: _filterType == 'credits',
                              isDark: isDark,
                              onTap: () =>
                                  setState(() => _filterType = 'credits'),
                            ),
                            const SizedBox(width: AppDefaults.spacingMd),
                            _FilterChip(
                              label: isEnglish ? 'Debits' : 'Deni',
                              isSelected: _filterType == 'debits',
                              isDark: isDark,
                              onTap: () =>
                                  setState(() => _filterType = 'debits'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDefaults.spacingMd),
                  transactionsAsync.when(
                    data: (transactions) {
                      final filtered = _applyFilter(transactions);
                      if (filtered.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppDefaults.spacingXl),
                          child: Text(
                            isEnglish
                                ? 'No transactions yet'
                                : 'Hakuna miamala bado',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.subtleDark
                                  : AppColors.subtleLight,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDefaults.spacingMd,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, index) => _TransactionTile(
                          transaction: filtered[index],
                          isDark: isDark,
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppDefaults.spacingLg),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(AppDefaults.spacingLg),
                      child: Text('Error loading transactions: $error'),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Error loading wallet: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Authentication error: $error')),
      ),
    );
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> transactions) {
    return transactions.where((tx) {
      if (_filterType == 'credits') return tx.type == 'credit';
      if (_filterType == 'debits') return tx.type == 'debit';
      return true;
    }).toList();
  }

  Future<void> _showTopUpModal(
    BuildContext context,
    String userId,
    WalletModel? wallet,
  ) async {
    final amountController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Top Up Wallet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDefaults.spacingMd),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (KES)'),
              ),
              const SizedBox(height: AppDefaults.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    if (amount == null || amount <= 0) return;

                    final success = await ref
                        .read(walletProvider.notifier)
                        .topUp(userId, amount, method: 'manual');

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Top up successful' : 'Top up failed',
                        ),
                      ),
                    );
                  },
                  child: const Text('Top Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showWithdrawModal(
    BuildContext context,
    String userId,
    WalletModel? wallet,
  ) async {
    final amountController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Withdraw from Wallet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDefaults.spacingMd),
              Text(
                'Available: ${(wallet?.balance ?? 0).toStringAsFixed(2)} KES',
              ),
              const SizedBox(height: AppDefaults.spacingMd),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (KES)'),
              ),
              const SizedBox(height: AppDefaults.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    if (amount == null || amount <= 0) return;

                    final success = await ref
                        .read(walletProvider.notifier)
                        .withdraw(
                          userId,
                          amount,
                          description: 'User withdrawal',
                        );

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Withdrawal successful'
                              : 'Withdrawal failed (insufficient balance)',
                        ),
                      ),
                    );
                  },
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTransferModal(
    BuildContext context,
    String fromUserId,
  ) async {
    final amountController = TextEditingController();
    final userIdController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send Money', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDefaults.spacingMd),
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'Recipient User ID',
                ),
              ),
              const SizedBox(height: AppDefaults.spacingMd),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (KES)'),
              ),
              const SizedBox(height: AppDefaults.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    final toUserId = userIdController.text.trim();
                    if (amount == null || amount <= 0 || toUserId.isEmpty)
                      return;

                    final real = await ref
                        .read(walletProvider.notifier)
                        .transfer(fromUserId, toUserId, amount);

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          real ? 'Transfer successful' : 'Transfer failed',
                        ),
                      ),
                    );
                  },
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.wallet,
    required this.isDark,
    required this.topUpLabel,
    required this.sendLabel,
    required this.withdrawLabel,
    required this.onTopUp,
    required this.onSend,
    required this.onWithdraw,
  });

  final WalletModel? wallet;
  final bool isDark;
  final String topUpLabel;
  final String sendLabel;
  final String withdrawLabel;
  final VoidCallback onTopUp;
  final VoidCallback onSend;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.primaryDark : AppColors.primary,
            (isDark ? AppColors.primaryDark : AppColors.primary).withValues(
              alpha: 0.75,
            ),
          ],
        ),
        borderRadius: AppDefaults.borderRadiusLarge,
        boxShadow: AppDefaults.shadowLg,
      ),
      padding: const EdgeInsets.all(AppDefaults.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Afri Wallet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppDefaults.spacingMdLg),
          Text(
            '${wallet?.currency ?? 'KES'} ${(wallet?.balance ?? 0).toStringAsFixed(2)}',
            style: AppTextStyles.displayLarge.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: AppDefaults.spacing2xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionButton(
                icon: Icons.add,
                label: topUpLabel,
                onTap: onTopUp,
              ),
              _QuickActionButton(
                icon: Icons.send,
                label: sendLabel,
                onTap: onSend,
              ),
              _QuickActionButton(
                icon: Icons.money,
                label: withdrawLabel,
                onTap: onWithdraw,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: AppDefaults.spacingSm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.spacingMd,
          vertical: AppDefaults.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryDark : AppColors.primary)
              : (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.isDark});

  final TransactionModel transaction;
  final bool isDark;

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'cashback':
      case 'bonus':
        return Icons.local_offer;
      case 'topup':
        return Icons.add_circle;
      case 'withdrawal':
        return Icons.account_balance_wallet;
      case 'transfer':
        return Icons.send;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'credit';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDefaults.spacingMd),
      padding: const EdgeInsets.all(AppDefaults.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppDefaults.borderRadius,
        border: Border.all(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.dividerLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForCategory(transaction.category),
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: AppDefaults.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                ),
                const SizedBox(height: AppDefaults.spacingXs),
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.timestamp),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.subtleDark
                        : AppColors.subtleLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}KES ${transaction.amount.abs().toStringAsFixed(2)}',
            style: AppTextStyles.label.copyWith(
              color: isCredit ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
