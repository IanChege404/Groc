import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/locale_provider.dart';

/// Wallet Screen - Afri Wallet Balance & Transaction History
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _filterType = 'all'; // all, credits, debits

  // Mock transactions
  final List<Transaction> transactions = [
    Transaction(
      id: 'TXN001',
      type: 'debit',
      description: 'Order #AFR-2024-00847',
      amount: -1450.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: 'purchase',
    ),
    Transaction(
      id: 'TXN002',
      type: 'credit',
      description: 'Cashback - Flash Sale',
      amount: 150.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: 'cashback',
    ),
    Transaction(
      id: 'TXN003',
      type: 'debit',
      description: 'Order #AFR-2024-00821',
      amount: -890.50,
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: 'purchase',
    ),
    Transaction(
      id: 'TXN004',
      type: 'credit',
      description: 'Referral Bonus',
      amount: 500.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      category: 'bonus',
    ),
    Transaction(
      id: 'TXN005',
      type: 'debit',
      description: 'Order #AFR-2024-00799',
      amount: -2300.00,
      date: DateTime.now().subtract(const Duration(days: 15)),
      category: 'purchase',
    ),
  ];

  List<Transaction> getFilteredTransactions() {
    return transactions.where((tx) {
      if (_filterType == 'credits') return tx.type == 'credit';
      if (_filterType == 'debits') return tx.type == 'debit';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = localeProvider.isDarkMode;
    final isEnglish = localeProvider.locale.languageCode == 'en';

    // Localized strings
    final afriWallet = isEnglish ? 'Afri Wallet' : 'Afri Wallet';
    final topUp = isEnglish ? 'Top Up' : 'Ongeza';
    final send = isEnglish ? 'Send' : 'Tuma';
    final withdraw = isEnglish ? 'Withdraw' : 'Takuza';
    final transactionHistory = isEnglish ? 'Transaction History' : 'Historia ya Miamala';
    final filterAll = isEnglish ? 'All' : 'Yote';
    final filterCredits = isEnglish ? 'Credits' : 'Mkopo';
    final filterDebits = isEnglish ? 'Debits' : 'Deni';
    final noTransactions = isEnglish
        ? 'No transactions yet'
        : 'Hakuna miamala bado';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          afriWallet,
          style: AppTextStyles.headline.copyWith(
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(AppDefaults.spacingMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppColors.primaryDark : AppColors.primary,
                    isDark
                        ? AppColors.primary.withValues(alpha: 0.7)
                        : AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: AppDefaults.borderRadiusLarge,
                boxShadow: AppDefaults.shadowLg,
              ),
              padding: const EdgeInsets.all(AppDefaults.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    afriWallet,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.spacingMdLg),

                  // Balance amount
                  Text(
                    'KES 3,450.00',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.spacing2xl),

                  // Quick action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickActionButton(
                        icon: Icons.add,
                        label: topUp,
                        onTap: () {},
                      ),
                      _QuickActionButton(
                        icon: Icons.send,
                        label: send,
                        onTap: () {},
                      ),
                      _QuickActionButton(
                        icon: Icons.money,
                        label: withdraw,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDefaults.spacingLg),

            // Transaction History Header + Filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionHistory,
                    style: AppTextStyles.headline.copyWith(
                      color: isDark
                          ? AppColors.onBackgroundDark
                          : AppColors.onBackgroundLight,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.spacingMd),

                  // Filter chips
                  Row(
                    children: [
                      _FilterChip(
                        label: filterAll,
                        isSelected: _filterType == 'all',
                        onTap: () {
                          setState(() {
                            _filterType = 'all';
                          });
                        },
                      ),
                      const SizedBox(width: AppDefaults.spacingMd),
                      _FilterChip(
                        label: filterCredits,
                        isSelected: _filterType == 'credits',
                        onTap: () {
                          setState(() {
                            _filterType = 'credits';
                          });
                        },
                      ),
                      const SizedBox(width: AppDefaults.spacingMd),
                      _FilterChip(
                        label: filterDebits,
                        isSelected: _filterType == 'debits',
                        onTap: () {
                          setState(() {
                            _filterType = 'debits';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDefaults.spacingMd),

            // Transaction List
            if (getFilteredTransactions().isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDefaults.spacingXl),
                  child: Text(
                    noTransactions,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.subtleDark : AppColors.subtleLight,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.spacingMd,
                ),
                itemCount: getFilteredTransactions().length,
                itemBuilder: (context, index) {
                  final tx = getFilteredTransactions()[index];
                  return _TransactionTile(
                    transaction: tx,
                    isDark: isDark,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: AppDefaults.spacingSm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = localeProvider.isDarkMode;

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
            color: isSelected ? Colors.white : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;

  const _TransactionTile({
    required this.transaction,
    required this.isDark,
  });

  IconData _getCategoryIcon() {
    switch (transaction.category) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'cashback':
        return Icons.local_offer;
      case 'bonus':
        return Icons.card_giftcard;
      default:
        return Icons.money;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.type == 'credit'
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: transaction.type == 'credit'
                  ? AppColors.success
                  : AppColors.error,
              size: 24,
            ),
          ),

          const SizedBox(width: AppDefaults.spacingMd),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.title.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDefaults.spacingXs),
                Text(
                  transaction.date.toString().split(' ')[0],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.subtleDark : AppColors.subtleLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDefaults.spacingMd),

          // Amount
          Text(
            '${transaction.type == 'credit' ? '+' : '-'}KES ${transaction.amount.abs().toStringAsFixed(2)}',
            style: AppTextStyles.label.copyWith(
              color: transaction.type == 'credit'
                  ? AppColors.success
                  : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String id;
  final String type; // credit, debit
  final String description;
  final double amount;
  final DateTime date;
  final String category; // purchase, cashback, bonus

  Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}
