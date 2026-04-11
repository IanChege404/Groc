import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/routes/app_routes.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _firestoreService = FirestoreService();
  bool _loading = true;
  List<Map<String, dynamic>> _addresses = const [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _addresses = const [];
      });
      return;
    }

    final addresses = await _firestoreService.getUserAddresses(user.uid);
    if (!mounted) return;
    setState(() {
      _addresses = addresses;
      _loading = false;
    });
  }

  Future<void> _deleteAddress(String addressId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.deleteUserAddress(user.uid, addressId);
    if (!mounted) return;
    await _loadAddresses();
  }

  Future<void> _setDefault(String addressId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.setDefaultAddress(user.uid, addressId);
    if (!mounted) return;
    await _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Delivery Address'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.all(AppDefaults.margin),
              padding: const EdgeInsets.all(AppDefaults.padding),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: AppDefaults.borderRadius,
              ),
              child: Stack(
                children: [
                  if (_addresses.isEmpty)
                    const Center(child: Text('No saved addresses yet'))
                  else
                    ListView.separated(
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
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
                      itemCount: _addresses.length,
                      separatorBuilder: (context, index) =>
                          const Divider(thickness: 0.2),
                    ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.newAddress,
                        ).then((_) => _loadAddresses());
                      },
                      backgroundColor: AppColors.primary,
                      splashColor: AppColors.primary,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(address),
              const SizedBox(height: 4),
              Text(
                number,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
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
