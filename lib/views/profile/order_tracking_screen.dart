import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/locale_provider.dart';

/// Order Tracking Screen
/// Shows live rider location, route, and order status
/// Note: Uses static mock implementation for maps (ready for google_maps_flutter integration)
class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late RiderLocation _riderLocation;

  @override
  void initState() {
    super.initState();
    _riderLocation = RiderLocation(
      name: 'James Mwamidi',
      phone: '+254 712 345 678',
      vehicle: 'Boda Boda - KBK 234J',
      rating: 4.8,
      distance: 1.4, // km
      eta: 8, // minutes
      latitude: -1.2890,
      longitude: 36.8241,
    );

    // Simulate movement
    _simulateRiderMovement();
  }

  void _simulateRiderMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _riderLocation = RiderLocation(
            name: _riderLocation.name,
            phone: _riderLocation.phone,
            vehicle: _riderLocation.vehicle,
            rating: _riderLocation.rating,
            distance: (_riderLocation.distance - 0.2).clamp(0, 100),
            eta: (_riderLocation.eta - 1).clamp(0, 60),
            latitude: _riderLocation.latitude + 0.001,
            longitude: _riderLocation.longitude + 0.001,
          );
        });
        if (_riderLocation.distance > 0) {
          _simulateRiderMovement();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = localeProvider.isDarkMode;
    final isEnglish = localeProvider.locale.languageCode == 'en';

    // Localized strings
    final orderTracking = isEnglish ? 'Order Tracking' : 'Ufuataji wa Agizo';
    final isOnTheWay =
        isEnglish ? 'is on the way!' : 'yuko njiani!';
    final awayFromYou = isEnglish ? 'away from you' : 'mbali na wewe';
    final arrivalIn =
        isEnglish ? 'Arrival in' : 'Kuwasili katika';
    final riderDetails = isEnglish ? 'Rider Details' : 'Maelezo ya Mjumbe';
    final rating = isEnglish ? 'Rating' : 'Tathmini';
    final contactRider = isEnglish ? 'Contact Rider' : 'Wasiliana na Mjumbe';
    final shareLocation = isEnglish ? 'Share Location' : 'Sambaza Mahali';
    final orderSummary = isEnglish ? 'Order Summary' : 'Muhtasari wa Agizo';
    final items = isEnglish ? 'Items' : 'Vitu';
    final total = isEnglish ? 'Total' : 'Jumla';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          orderTracking,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color:
                  isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
            ),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mock Map (placeholder for google_maps_flutter)
            Container(
              width: double.infinity,
              height: 280,
              color: isDark ? AppColors.surfaceVariantDark : Colors.grey[200],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map background (placeholder)
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

                  // Rider marker
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

                  // Destination marker
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

            // Rider Status Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: AppDefaults.borderRadius,
                  boxShadow: AppDefaults.shadowSm,
                ),
                padding: const EdgeInsets.all(AppDefaults.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status text
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _riderLocation.name,
                            style: AppTextStyles.title.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' $isOnTheWay',
                            style: AppTextStyles.title.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDefaults.spacingMd),

                    // Distance and ETA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_riderLocation.distance.toStringAsFixed(1)} km',
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
                              '${_riderLocation.eta} min',
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

            // Rider Details Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                                _riderLocation.name,
                                style: AppTextStyles.title.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceDark
                                      : AppColors.onSurfaceLight,
                                ),
                              ),
                              Text(
                                _riderLocation.vehicle,
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
                                    '${_riderLocation.rating} $rating',
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

            // Order Summary (Collapsible)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.spacingMd,
              ),
              child: ExpansionTile(
                title: Text(
                  orderSummary,
                  style: AppTextStyles.title.copyWith(
                    color:
                        isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
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
                              '$items (3)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                              ),
                            ),
                            Text(
                              'KES 3,450.00',
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
                              'KES 150.00',
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
                              'KES 3,600.00',
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
}

class RiderLocation {
  final String name;
  final String phone;
  final String vehicle;
  final double rating;
  double distance; // km
  int eta; // minutes
  double latitude;
  double longitude;

  RiderLocation({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.rating,
    required this.distance,
    required this.eta,
    required this.latitude,
    required this.longitude,
  });
}
