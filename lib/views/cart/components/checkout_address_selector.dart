import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../views/profile/address/components/map_preview_widget.dart';
import 'checkout_address_card.dart';

class AddressSelector extends ConsumerWidget {
  const AddressSelector({
    super.key,
    required this.selectedAddressId,
    required this.onAddressSelected,
  });

  final String? selectedAddressId;
  final void Function(
    String id,
    String label,
    String full, {
    double? latitude,
    double? longitude,
  }) onAddressSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userId = ref.watch(authProvider).value;

    if (userId == null || userId.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.pleaseSignInFirst),
      );
    }

    final addressesAsync = ref.watch(userAddressesProvider(userId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.selectDeliveryAddress,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await context.push('/newAddress');
                  ref.invalidate(userAddressesProvider(userId));
                },
                child: Text(l10n.addNewAddress),
              ),
            ],
          ),
        ),
        addressesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading addresses: $error'),
          ),
          data: (addresses) {
            if (addresses.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No saved addresses. Add one to continue.'),
              );
            }

            final defaultAddress = addresses.firstWhere(
              (addr) => addr['isDefault'] == true,
              orElse: () => addresses.first,
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (selectedAddressId == null && defaultAddress.isNotEmpty) {
                final id = defaultAddress['id'] as String? ?? '';
                final label = defaultAddress['label'] as String? ?? 'Address';
                final line1 = defaultAddress['line1'] as String? ?? '';
                final line2 = defaultAddress['line2'] as String? ?? '';
                final city = defaultAddress['city'] as String? ?? '';
                final full =
                    [line1, line2, city].where((e) => e.isNotEmpty).join(', ');
                final lat = (defaultAddress['latitude'] as num?)?.toDouble();
                final lng = (defaultAddress['longitude'] as num?)?.toDouble();
                onAddressSelected(
                  id,
                  label,
                  full,
                  latitude: lat,
                  longitude: lng,
                );
              }
            });

            return Column(
              children: addresses.map((addr) {
                final id = addr['id'] as String? ?? '';
                final label = addr['label'] as String? ?? 'Address';
                final line1 = addr['line1'] as String? ?? '';
                final line2 = addr['line2'] as String? ?? '';
                final city = addr['city'] as String? ?? '';
                final phone = addr['phone'] as String? ?? '';
                final full =
                    [line1, line2, city].where((e) => e.isNotEmpty).join(', ');
                final isDefault = addr['isDefault'] == true;
                final lat = (addr['latitude'] as num?)?.toDouble();
                final lng = (addr['longitude'] as num?)?.toDouble();

                return AddressCard(
                  label: isDefault ? '$label (Default)' : label,
                  phoneNumber: phone,
                  address: full,
                  isActive: selectedAddressId == id,
                  onTap: () => onAddressSelected(
                    id,
                    label,
                    full,
                    latitude: lat,
                    longitude: lng,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
