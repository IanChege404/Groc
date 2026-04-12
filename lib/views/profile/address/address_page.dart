import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/components/retryable_error_view.dart';
import '../../../core/constants/constants.dart';
import '../../../core/mixins/refresh_on_return_mixin.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_data_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/routes/app_routes.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage>
    with RefreshOnReturnMixin<AddressPage> {
  final _firestoreService = FirestoreService();

  @override
  Future<void> onRefreshRequested() async {
    final userId = ref.read(authProvider).value;
    if (userId != null && userId.isNotEmpty) {
      ref.invalidate(userAddressesProvider(userId));
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final userId = ref.read(authProvider).value;
    if (userId == null || userId.isEmpty) return;

    await _firestoreService.deleteUserAddress(userId, addressId);
    ref.invalidate(userAddressesProvider(userId));
  }

  Future<void> _setDefault(String addressId) async {
    final userId = ref.read(authProvider).value;
    if (userId == null || userId.isEmpty) return;

    await _firestoreService.setDefaultAddress(userId, addressId);
    ref.invalidate(userAddressesProvider(userId));
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value;
    final addressesAsync = userId == null || userId.isEmpty
        ? const AsyncValue<List<Map<String, dynamic>>>.data([])
        : ref.watch(userAddressesProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Delivery Address'),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => RetryableErrorView(
          title: 'Unable to load addresses',
          message:
              'Please check your internet connection and try again. ${error.toString()}',
          onRetry: () => onRefreshRequested(),
        ),
        data: (addresses) => Container(
          margin: const EdgeInsets.all(AppDefaults.margin),
          padding: const EdgeInsets.all(AppDefaults.padding),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: onRefreshRequested,
                child: addresses.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 240),
                          Center(child: Text('No saved addresses yet')),
                        ],
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return AddressTile(
                            label: (address['label'] as String?) ?? 'Address',
                            address: (address['line1'] as String?) ?? '',
                            number: (address['phone'] as String?) ?? '',
                            isActive: address['isDefault'] == true,
                            onTap: () => _setDefault(address['id'] as String),
                            onDelete: () =>
                                _deleteAddress(address['id'] as String),
                          );
                        },
                        itemCount: addresses.length,
                        separatorBuilder: (context, index) =>
                            const Divider(thickness: 0.2),
                      ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.newAddress);
                  },
                  backgroundColor: AppColors.primary,
                  splashColor: AppColors.primary,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.address,
    required this.label,
    required this.number,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final String address;
  final String label;
  final String number;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AppRadio(isActive: isActive),
          ),
          const SizedBox(width: AppDefaults.padding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(address),
              const SizedBox(height: 4),
              Text(
                number,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              IconButton(
                onPressed: onTap,
                icon: SvgPicture.asset(AppIcons.edit),
                constraints: const BoxConstraints(),
                iconSize: 14,
              ),
              const SizedBox(height: AppDefaults.margin / 2),
              IconButton(
                onPressed: onDelete,
                icon: SvgPicture.asset(AppIcons.deleteOutline),
                constraints: const BoxConstraints(),
                iconSize: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
