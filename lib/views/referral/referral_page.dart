import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/components/referral_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/providers/referral_provider.dart';
import 'package:go_router/go_router.dart';

class ReferralPage extends ConsumerWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(referralSummaryProvider);
    final referralsAsync = ref.watch(userReferralsProvider);
    final referralCodeAsync = ref.watch(userReferralCodeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Referral Program'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(referralSummaryProvider);
            ref.invalidate(userReferralsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    summaryAsync.when(
                      data: (summary) => ReferralStatsCard(
                        totalReferrals: summary.totalReferrals,
                        completedReferrals: summary.completedReferrals,
                        totalEarnings: summary.totalEarnings,
                      ),
                      loading: () => const _LoadingStats(),
                      error: (error, stack) => const SizedBox(),
                    ),
                    const SizedBox(height: 24),
                    _ReferralCodeSection(referralCodeAsync: referralCodeAsync),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/referralCodeEntry');
                        },
                        icon: const Icon(Icons.card_giftcard_rounded),
                        label: const Text('Enter Referral Code'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Referrals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ]),
                ),
              ),
              referralsAsync.when(
                data: (referrals) {
                  if (referrals.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Referrals Yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Share your code to start earning rewards!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDefaults.padding,
                      vertical: 8,
                    ),
                    sliver: SliverList.separated(
                      itemCount: referrals.length,
                      itemBuilder: (context, index) {
                        final referral = referrals[index];
                        return ReferralCard(
                          referral: referral,
                          onComplete: () {
                            _showCompleteDialog(context, ref, referral.id);
                          },
                          onCancel: () {
                            _showCancelDialog(context, ref, referral.id);
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                    ),
                  );
                },
                loading: () => SliverFillRemaining(
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error loading referrals: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, WidgetRef ref, String referralId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Referral Complete?'),
        content: const Text(
          'This will award rewards to both you and the referred user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(completeReferralProvider(referralId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral completed!')),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String referralId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Referral?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cancelReferralProvider(referralId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral cancelled')),
              );
            },
            child: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralCodeSection extends StatelessWidget {
  final AsyncValue<String?> referralCodeAsync;

  const _ReferralCodeSection({required this.referralCodeAsync});

  @override
  Widget build(BuildContext context) {
    return referralCodeAsync.when(
      data: (code) {
        if (code == null) {
          return const SizedBox();
        }

        return Container(
          padding: const EdgeInsets.all(AppDefaults.padding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Referral Code',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        code,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied!')),
                      );
                    },
                    icon: const Icon(Icons.content_copy_rounded),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox(),
    );
  }
}

class _LoadingStats extends StatelessWidget {
  const _LoadingStats();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            3,
            (index) => Shimmer(
              child: Container(
                width: 60,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Shimmer extends StatelessWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
