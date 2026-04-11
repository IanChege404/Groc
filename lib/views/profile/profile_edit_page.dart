import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/services/firestore_service.dart';
import '../../core/constants/constants.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthdayController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final profile = await _firestoreService.getUserProfile(user.uid);
    final displayName = user.displayName?.trim() ?? '';
    final nameParts = displayName.isNotEmpty
        ? displayName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList()
        : <String>[];

    if (!mounted) return;
    _firstNameController.text =
        (profile?['firstName'] as String?) ??
        (nameParts.isNotEmpty ? nameParts.first : '');
    _lastNameController.text =
        (profile?['lastName'] as String?) ??
        (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    _phoneController.text =
        (profile?['phone'] as String?) ?? user.phoneNumber ?? '';
    _genderController.text = (profile?['gender'] as String?) ?? '';
    _birthdayController.text = (profile?['birthday'] as String?) ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to save profile')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    await _firestoreService.updateUserProfile(user.uid, {
      'firstName': firstName,
      'lastName': lastName,
      'phone': _phoneController.text.trim(),
      'gender': _genderController.text.trim(),
      'birthday': _birthdayController.text.trim(),
      'email': user.email,
      'displayName': '$firstName $lastName'.trim(),
    });

    await user.updateDisplayName('$firstName $lastName'.trim());

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      const Text('First Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'First name is required'
                            : null,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      const Text('Last Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Last name is required'
                            : null,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      const Text('Phone Number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Phone number is required'
                            : null,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      const Text('Gender'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _genderController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      const Text('Birthday'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _birthdayController,
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: Text(_isSaving ? 'Saving...' : 'Save'),
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
