import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/order_provider.dart';

/// Order Tracking Screen
/// Shows order progress and delivery context from live order data.
class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  String _statusHeadline(String status, bool isEnglish) {
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

  int _estimateEtaMinutes(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 45;
      case 'processing':
        return 25;
      case 'shipped':
      case 'delivery':
        return 10;
      case 'completed':
        return 0;
      case 'cancelled':
        return 0;
      default:
        return 30;
    }
  }

  double _estimateDistanceKm(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 8.0;
      case 'processing':
        return 4.5;
      case 'shipped':
      case 'delivery':
        return 1.4;
      case 'completed':
        return 0.0;
      case 'cancelled':
        return 0.0;
      default:
        return 5.0;
    }
  }

  String _formatAmount(double value) => value.toStringAsFixed(2);

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    bool isEnglish,
    OrderModel order,
  ) {
    final orderTracking = isEnglish ? 'Order Tracking' : 'Ufuataji wa Agizo';
    final awayFromYou = isEnglish ? 'away from you' : 'mbali na wewe';
    final arrivalIn = isEnglish ? 'Arrival in' : 'Kuwasili katika';
    final riderDetails = isEnglish ? 'Rider Details' : 'Maelezo ya Mjumbe';
    final rating = isEnglish ? 'Rating' : 'Tathmini';
    final contactRider = isEnglish ? 'Contact Rider' : 'Wasiliana na Mjumbe';
    final shareLocation = isEnglish ? 'Share Location' : 'Sambaza Mahali';
    final orderSummary = isEnglish ? 'Order Summary' : 'Muhtasari wa Agizo';
    final items = isEnglish ? 'Items' : 'Vitu';
    final total = isEnglish ? 'Total' : 'Jumla';

    final statusHeadline = _statusHeadline(order.status, isEnglish);
    final statusColor = _statusColor(order.status);
    final eta = _estimateEtaMinutes(order.status);
    final distance = _estimateDistanceKm(order.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          orderTracking,
          style: AppTextStyles.headline.copyWith(
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 280,
              color: isDark ? AppColors.surfaceVariantDark : Colors.grey[200],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 64,
                          color: isDark
                              ? AppColors.subtleDark
                              : AppColors.subtleLight,
                        ),
                        const SizedBox(height: AppDefaults.spacingMd),
                        Text(
                          isEnglish
                              ? 'Live Map (Integration Ready)'
                              : 'Ramani Halisi (Tayari kwa Muunganisho)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.subtleDark
                                : AppColors.subtleLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: AppDefaults.shadowMd,
                      ),
                      child: const Icon(
                        Icons.two_wheeler,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: AppDefaults.shadowMd,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
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
                      statusHeadline,
                      style: AppTextStyles.title.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDefaults.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            Text(
                              awayFromYou,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.subtleDark
                                    : AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$eta min',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              arrivalIn,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.subtleDark
                                    : AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
                      riderDetails,
                      style: AppTextStyles.title.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: AppDefaults.spacingMd),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariantLight,
                          child: Icon(
                            Icons.person,
                            color: isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurfaceLight,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppDefaults.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned Rider',
                                style: AppTextStyles.title.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceDark
                                      : AppColors.onSurfaceLight,
                                ),
                              ),
                              Text(
                                'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.subtleDark
                                      : AppColors.subtleLight,
                                ),
                              ),
                              const SizedBox(height: AppDefaults.spacingSm),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.secondary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppDefaults.spacingXs),
                                  Text(
                                    '4.8 $rating',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.onSurfaceDark
                                          : AppColors.onSurfaceLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDefaults.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone),
                                const SizedBox(width: AppDefaults.spacingSm),
                                Text(contactRider),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDefaults.spacingMd),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: AppDefaults.spacingSm),
                                Text(shareLocation),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDefaults.spacingLg),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: ExpansionTile(
                title: Text(
                  orderSummary,
                  style: AppTextStyles.title.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDefaults.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$items (${order.items.length})',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                              ),
                            ),
                            Text(
                              'KES ${_formatAmount(order.totalAmount)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDefaults.spacingSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnglish ? 'Delivery' : 'Kuletwa',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.subtleDark
                                    : AppColors.subtleLight,
                              ),
                            ),
                            Text(
                              'KES 0.00',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.subtleDark
                                    : AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDefaults.spacingMd),
                        Divider(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                        const SizedBox(height: AppDefaults.spacingSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              total,
                              style: AppTextStyles.title.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                              ),
                            ),
                            Text(
                              'KES ${_formatAmount(order.totalAmount)}',
                              style: AppTextStyles.title.copyWith(
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDefaults.spacingXl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeProvider = context.watch<LocaleProvider>();
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
        return _buildContent(context, isDark, isEnglish, order);
      },
    );
  }
}
