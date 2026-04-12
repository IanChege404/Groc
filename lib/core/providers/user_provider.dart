import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// Notifier for managing user profile state
class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final FirestoreService _firestoreService = FirestoreService();
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<String?>>(authProvider, (_, next) {
      next.whenData(_handleAuthUserId);
    });

    _ref.read(authProvider).whenData(_handleAuthUserId);
  }

  Future<void> _handleAuthUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      state = AsyncValue.data(
        UserModel(
          id: '',
          email: '',
          firstName: '',
          lastName: '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      return;
    }

    await _loadUserProfile(userId);
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      state = const AsyncValue.loading();

      final profileData = await _firestoreService.getUserProfile(userId);

      if (profileData == null) {
        state = AsyncValue.error(
          Exception('User profile not found'),
          StackTrace.current,
        );
        return;
      }

      // Convert raw data to UserModel
      final userModel = UserModel(
        id: profileData['id'] as String? ?? userId,
        email: profileData['email'] as String? ?? '',
        firstName: profileData['firstName'] as String? ?? '',
        lastName: profileData['lastName'] as String? ?? '',
        phone: profileData['phone'] as String?,
        photoUrl: profileData['photoUrl'] as String?,
        gender: profileData['gender'] as String?,
        birthday: profileData['birthday'] as String?,
        createdAt: profileData['createdAt'] as DateTime? ?? DateTime.now(),
        updatedAt: profileData['updatedAt'] as DateTime? ?? DateTime.now(),
      );

      state = AsyncValue.data(userModel);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh the user profile data
  Future<void> refresh() async {
    final userUid = _ref.read(authProvider).value;
    if (userUid != null && userUid.isNotEmpty) {
      await _loadUserProfile(userUid);
    }
  }
}

/// Provider for user profile with auto-refresh on auth state changes
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel>>((ref) {
      return UserProfileNotifier(ref);
    });

/// Selectors for specific user fields
final userFullNameProvider = FutureProvider<String>((ref) async {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.fullName,
    loading: () => 'Loading...',
    error: (_, __) => 'Unknown',
  );
});

final userEmailProvider = FutureProvider<String>((ref) async {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.email,
    loading: () => '',
    error: (_, __) => '',
  );
});

final userIdProvider = FutureProvider<String>((ref) async {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.id,
    loading: () => '',
    error: (_, __) => '',
  );
});
