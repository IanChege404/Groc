import 'package:flutter/material.dart';
import '../constants/app_defaults.dart';
import '../models/referral_model.dart';

class ReferralCard extends StatelessWidget {
  final ReferralModel referral;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const ReferralCard({
    super.key,
    required this.referral,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = referral.status == ReferralStatus.pending;
    final isCompleted = referral.status == ReferralStatus.completed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referral.refereeEmail,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                _StatusBadge(status: referral.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Reward',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${referral.rewardAmount.toStringAsFixed(0)} KES',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Referee Reward',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${referral.refereeRewardAmount.toStringAsFixed(0)} KES',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Created: ${_formatDate(referral.createdAt)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (isCompleted && referral.completedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Completed: ${_formatDate(referral.completedAt!)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                    ),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onComplete != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onComplete,
                        child: const Text('Mark Complete'),
                      ),
                    ),
                  if (onCancel != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final ReferralStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ReferralStatus.pending:
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        label = 'Pending';
      case ReferralStatus.completed:
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        label = 'Completed';
      case ReferralStatus.cancelled:
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class ReferralStatsCard extends StatelessWidget {
  final int totalReferrals;
  final int completedReferrals;
  final double totalEarnings;

  const ReferralStatsCard({
    super.key,
    required this.totalReferrals,
    required this.completedReferrals,
    required this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Total Referrals',
              value: totalReferrals.toString(),
            ),
            _Divider(),
            _StatItem(
              label: 'Completed',
              value: completedReferrals.toString(),
            ),
            _Divider(),
            _StatItem(
              label: 'Earnings',
              value: '${totalEarnings.toStringAsFixed(0)} KES',
              valueColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: VerticalDivider(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
