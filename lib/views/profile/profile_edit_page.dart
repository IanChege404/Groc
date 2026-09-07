import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/mixins/refresh_on_return_mixin.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_data_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/user_provider.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage>
    with RefreshOnReturnMixin<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthdayController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadingError;

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
    final uid = ref.read(authProvider).value;
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = 'Please sign in again to edit your profile.';
      });
      return;
    }

    try {
      final profile = await ref.read(userDataProvider(uid).future);
      final user = FirebaseAuth.instance.currentUser;
      final displayName = user?.displayName?.trim() ?? '';
      final nameParts = displayName.isNotEmpty
          ? displayName
              .split(RegExp(r'\s+'))
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];

      if (!mounted) return;
      _firstNameController.text = (profile?['firstName'] as String?) ??
          (nameParts.isNotEmpty ? nameParts.first : '');
      _lastNameController.text = (profile?['lastName'] as String?) ??
          (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
      _phoneController.text =
          (profile?['phone'] as String?) ?? user?.phoneNumber ?? '';
      _genderController.text = (profile?['gender'] as String?) ?? '';
      _birthdayController.text = (profile?['birthday'] as String?) ?? '';
      setState(() {
        _isLoading = false;
        _loadingError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError =
            'Could not load your profile details. Pull to refresh or retry.';
      });
    }
  }

  @override
  Future<void> onRefreshRequested() async {
    final uid = ref.read(authProvider).value;
    if (uid != null && uid.isNotEmpty) {
      ref.invalidate(userDataProvider(uid));
    }
    await _loadProfile();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) {
      return;
    }

    final uid = ref.read(authProvider).value;
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to save profile')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    setState(() => _isSaving = true);
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      await _firestoreService.updateUserProfile(uid, {
        'firstName': firstName,
        'lastName': lastName,
        'phone': _phoneController.text.trim(),
        'gender': _genderController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'email': user?.email,
        'displayName': '$firstName $lastName'.trim(),
      });

      await user?.updateDisplayName('$firstName $lastName'.trim());

      if (!mounted) return;
      setState(() => _isSaving = false);

      /// Refresh the user profile provider to sync header and other UI elements
      /// Await the refresh to ensure new data is available before showing success
      await ref.read(userProfileProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );

      /// Pop back to profile view
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.profile),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
              ? RetryableErrorView(
                  title: l10n.unableToLoadProfile,
                  message: _loadingError!,
                  onRetry: _loadProfile,
                )
              : RefreshIndicator(
                  onRefresh: onRefreshRequested,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                            Text(l10n.firstName),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _firstNameController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.firstName,
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? l10n.requiredField(l10n.firstName)
                                      : null,
                            ),
                            const SizedBox(height: AppDefaults.padding),
                            Text(l10n.lastName),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _lastNameController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.lastName,
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? l10n.requiredField(l10n.lastName)
                                      : null,
                            ),
                            const SizedBox(height: AppDefaults.padding),
                            Text(l10n.phoneNumber),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.phoneNumber,
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? l10n.requiredField(l10n.phoneNumber)
                                      : null,
                            ),
                            const SizedBox(height: AppDefaults.padding),
                            Text(l10n.gender),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _genderController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.gender,
                              ),
                            ),
                            const SizedBox(height: AppDefaults.padding),
                            Text(l10n.birthday),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _birthdayController,
                              keyboardType: TextInputType.datetime,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: l10n.birthday,
                              ),
                            ),
                            const SizedBox(height: AppDefaults.padding),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                child:
                                    Text(_isSaving ? l10n.saving : l10n.save),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
