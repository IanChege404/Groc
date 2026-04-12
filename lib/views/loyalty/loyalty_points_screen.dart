import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/loyalty_model.dart';
import '../../core/providers/loyalty_provider.dart';

class LoyaltyPointsScreen extends ConsumerWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Loyalty Points'),
      ),
      body: loyaltyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (loyalty) {
          if (loyalty == null) {
            return const Center(child: Text('Please sign in to view points'));
          }
          return _LoyaltyContent(loyalty: loyalty);
        },
      ),
    );
  }
}

class _LoyaltyContent extends ConsumerWidget {
  final LoyaltyModel loyalty;

  const _LoyaltyContent({required this.loyalty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PointsCard(loyalty: loyalty),
          const SizedBox(height: 20),
          _TierProgress(loyalty: loyalty),
          const SizedBox(height: 20),
          _RedeemSection(loyalty: loyalty),
          const SizedBox(height: 20),
          _TransactionHistory(transactions: loyalty.transactions),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final LoyaltyModel loyalty;

  const _PointsCard({required this.loyalty});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE05030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDefaults.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                loyalty.tierName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${loyalty.availablePoints}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'Available Points',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Worth KES ${loyalty.cashValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierProgress extends StatelessWidget {
  final LoyaltyModel loyalty;

  const _TierProgress({required this.loyalty});

  @override
  Widget build(BuildContext context) {
    final tiers = ['Bronze', 'Silver', 'Gold', 'Platinum'];
    final thresholds = [0, 500, 2000, 5000];
    final currentTierIdx = loyalty.tier - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Journey',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tiers.asMap().entries.map((e) {
                final reached = e.key <= currentTierIdx;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          reached ? AppColors.primary : Colors.grey.shade200,
                      child: Icon(
                        Icons.star,
                        color: reached ? Colors.white : Colors.grey,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: reached
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: reached ? AppColors.primary : Colors.grey,
                      ),
                    ),
                    Text(
                      '${thresholds[e.key]}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                );
              }).toList(),
            ),
            if (loyalty.tier < 4) ...[
              const SizedBox(height: 12),
              Text(
                '${loyalty.pointsToNextTier} more points to ${tiers[loyalty.tier]}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RedeemSection extends ConsumerWidget {
  final LoyaltyModel loyalty;

  const _RedeemSection({required this.loyalty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRedeem = loyalty.availablePoints >= 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Redeem Points',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '100 points = KES 1.00\n'
              'Minimum redemption: 100 points',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: canRedeem
                  ? () => _showRedeemDialog(context, ref, loyalty)
                  : null,
              icon: const Icon(Icons.redeem),
              label: const Text('Redeem at Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemDialog(
    BuildContext context,
    WidgetRef ref,
    LoyaltyModel loyalty,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redeem Points'),
        content: Text(
          'You have ${loyalty.availablePoints} points worth '
          'KES ${loyalty.cashValue.toStringAsFixed(2)}.\n\n'
          'Points will be applied at checkout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Points will be applied at checkout!'),
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  final List<LoyaltyTransaction> transactions;

  const _TransactionHistory({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = [...transactions]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...sorted.take(20).map(
              (txn) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: txn.isEarning
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Icon(
                    txn.isEarning ? Icons.add : Icons.remove,
                    color:
                        txn.isEarning ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ),
                title: Text(txn.description),
                subtitle: Text(
                  '${txn.timestamp.day}/${txn.timestamp.month}/${txn.timestamp.year}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '${txn.isEarning ? '+' : ''}${txn.points} pts',
                  style: TextStyle(
                    color: txn.isEarning ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
