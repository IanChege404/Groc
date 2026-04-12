import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/order_provider.dart';
import '../../core/routes/app_routes.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF4044AA);
      case 'processing':
        return const Color(0xFF41A954);
      case 'shipped':
      case 'delivery':
        return const Color(0xFFE19603);
      case 'completed':
        return const Color(0xFF41AA55);
      case 'cancelled':
        return const Color(0xFFFF1F1F);
      default:
        return AppColors.primary;
    }
  }

  String _headline(String status, bool isEnglish) {
    switch (status.toLowerCase()) {
      case 'pending':
        return isEnglish ? 'Order received' : 'Agizo limepokelewa';
      case 'processing':
        return isEnglish ? 'Order is being prepared' : 'Agizo linaandaliwa';
      case 'shipped':
      case 'delivery':
        return isEnglish ? 'Rider is on the way' : 'Mjumbe yuko njiani';
      case 'completed':
        return isEnglish ? 'Order delivered' : 'Agizo limewasilishwa';
      case 'cancelled':
        return isEnglish ? 'Order cancelled' : 'Agizo limeghairiwa';
      default:
        return isEnglish ? 'Order in progress' : 'Agizo linaendelea';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeProvider = p.Provider.of<LocaleProvider>(context);
    final isDark = localeProvider.isDarkMode;
    final isEnglish = localeProvider.locale.languageCode == 'en';
    final orderState = ref.watch(orderDetailProvider(orderId));

    return orderState.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: Center(child: Text('Failed to load order: $error')),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Tracking')),
            body: const Center(child: Text('Order not found')),
          );
        }
        return _OrderTrackingBody(
          order: order,
          isDark: isDark,
          isEnglish: isEnglish,
          headline: _headline(order.status, isEnglish),
          statusColor: _statusColor(order.status),
        );
      },
    );
  }
}

class _OrderTrackingBody extends StatelessWidget {
  const _OrderTrackingBody({
    required this.order,
    required this.isDark,
    required this.isEnglish,
    required this.headline,
    required this.statusColor,
  });

  final OrderModel order;
  final bool isDark;
  final bool isEnglish;
  final String headline;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 280,
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 64,
                          color: isDark
                              ? AppColors.subtleDark
                              : AppColors.subtleLight,
                        ),
                        const SizedBox(height: AppDefaults.spacingMd),
                        Text(
                          isEnglish
                              ? 'Real-time tracking enabled'
                              : 'Ufuatiliaji wa moja kwa moja umewezeshwa',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.subtleDark
                                : AppColors.subtleLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDefaults.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: AppDefaults.borderRadius,
                  boxShadow: AppDefaults.shadowSm,
                ),
                padding: const EdgeInsets.all(AppDefaults.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: AppTextStyles.title.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDefaults.spacingMd),
                    Text('Status: ${order.status}'),
                    const SizedBox(height: AppDefaults.spacingSm),
                    Text('Tracking #: ${order.trackingNumber ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Support ticket placeholder'),
                          ),
                        );
                      },
                      child: const Text('Contact Support'),
                    ),
                  ),
                  const SizedBox(width: AppDefaults.spacingMd),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.submitReview,
                          arguments: {'orderId': order.id},
                        );
                      },
                      child: const Text('Return/Refund'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
