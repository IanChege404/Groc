import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/app_radio.dart';
import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/map_location.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../views/profile/address/components/map_preview_widget.dart';
import '../../../views/profile/address/map_location_picker.dart';

class NewAddressPage extends ConsumerStatefulWidget {
  const NewAddressPage({super.key});

  @override
  ConsumerState<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends ConsumerState<NewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isDefault = true;
  bool _isSaving = false;
  MapLocation? _selectedLocation;
  String _selectedLabel = 'Home';

  @override
  void dispose() {
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<MapLocation>(
      context,
      MaterialPageRoute(builder: (context) => const MapLocationPicker()),
    );
    if (result == null || !mounted) return;

    setState(() {
      _selectedLocation = result;
      if (result.street != null && result.street!.isNotEmpty) {
        _address1Controller.text = result.street!;
      }
      if (result.city != null && result.city!.isNotEmpty) {
        _cityController.text = result.city!;
      }
      if (result.state != null && result.state!.isNotEmpty) {
        _stateController.text = result.state!;
      }
      if (result.zipCode != null && result.zipCode!.isNotEmpty) {
        _zipController.text = result.zipCode!;
      }
    });
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) {
      return;
    }

    final userId = ref.read(authProvider).value ??
        FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.pleaseSignInAgainToSave),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _firestoreService.addUserAddress(userId, {
        'label': _selectedLabel,
        'phone': _phoneController.text.trim(),
        'line1': _address1Controller.text.trim(),
        'line2': _address2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipController.text.trim(),
        'isDefault': _isDefault,
        if (_selectedLocation != null) ...{
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save address: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.newAddress),
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.pickLocationOnMap),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),
                if (_selectedLocation != null)
                  Column(
                    children: [
                      MapPreviewWidget(
                        latitude: _selectedLocation!.latitude,
                        longitude: _selectedLocation!.longitude,
                        formattedAddress: _selectedLocation!.formattedAddress,
                        height: 120,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLocation!.formattedAddress,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                    ],
                  ),
                const Text('Address Label'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLabel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Home', child: Text('Home')),
                    DropdownMenuItem(value: 'Work', child: Text('Work')),
                    DropdownMenuItem(value: 'Office', child: Text('Office')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please select a label'
                      : null,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLabel = value);
                    }
                  },
                ),
                const SizedBox(height: AppDefaults.padding),
                const Text('Phone Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Enter your phone number',
                  ),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Enter street address',
                  ),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Apartment, suite, etc. (optional)',
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),
                const Text('City'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Enter city',
                  ),
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              hintText: 'State',
                            ),
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              hintText: 'Zip code',
                            ),
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
                    Text(l10n.makeDefaultShippingAddress),
                  ],
                ),
                const SizedBox(height: AppDefaults.padding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    child: Text(_isSaving ? l10n.saving : l10n.saveAddress),
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
