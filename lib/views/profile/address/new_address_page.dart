import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/user_provider.dart';

class NewAddressPage extends ConsumerStatefulWidget {
  const NewAddressPage({super.key});

  @override
  ConsumerState<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends ConsumerState<NewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isDefault = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) {
      return;
    }

    /// Get user ID from the provider instead of FirebaseAuth
    final userProfile = ref.read(userProfileProvider);

    String? userId;
    userProfile.whenData((user) {
      userId = user.id;
    });

    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to save address')),
      );
      return;
    }

    setState(() => _isSaving = true);
    await _firestoreService.addUserAddress(userId!, {
      'label': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'line1': _address1Controller.text.trim(),
      'line2': _address2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipController.text.trim(),
      'isDefault': _isDefault,
    });

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('New Address'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: AppDefaults.padding),
                const Text('Phone Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: AppDefaults.padding),
                const Text('Address Line 1'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _address1Controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Address line 1 is required'
                      : null,
                ),
                const SizedBox(height: AppDefaults.padding),
                const Text('Address Line 2'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _address2Controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDefaults.padding),
                const Text('City'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'City is required'
                      : null,
                ),
                const SizedBox(height: AppDefaults.padding),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('State'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stateController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'State is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDefaults.padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Zip Code'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _zipController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Zip code is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDefaults.padding),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isDefault = !_isDefault),
                      child: AppRadio(isActive: _isDefault),
                    ),
                    const SizedBox(width: AppDefaults.padding),
                    const Text('Make Default Shipping Address'),
                  ],
                ),
                const SizedBox(height: AppDefaults.padding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    child: Text(_isSaving ? 'Saving...' : 'Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
