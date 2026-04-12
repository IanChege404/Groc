import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// Notifier for managing user settings state
class UserSettingsNotifier
    extends StateNotifier<AsyncValue<UserSettingsModel?>> {
  final FirestoreService _service = FirestoreService();
  final Ref _ref;

  UserSettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<String?>>(authProvider, (_, next) {
      next.whenData((uid) {
        if (uid == null || uid.isEmpty) {
          state = const AsyncValue.data(null);
          return;
        }
        _loadSettings(uid);
      });
    });

    _ref.read(authProvider).whenData((uid) {
      if (uid != null && uid.isNotEmpty) {
        _loadSettings(uid);
      }
    });
  }

  /// Load settings from service
  Future<void> _loadSettings(String userId) async {
    try {
      state = const AsyncValue.loading();
      var settings = await _service.getUserSettings(userId);
      if (settings == null) {
        await _service.initializeUserSettings(userId);
        settings = await _service.getUserSettings(userId);
      }
      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update language preference
  Future<void> updateLanguage(String userId, String languageCode) async {
    try {
      await _service.updateLanguage(userId, languageCode);
      final current = state.whenData((settings) => settings);
      current.whenData((settings) {
        if (settings != null) {
          state = AsyncValue.data(
            settings.copyWith(languageCode: languageCode),
          );
        }
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
  }) async {
    try {
      await _service.updateNotificationSettings(
        userId,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        pushNotificationsEnabled: pushNotificationsEnabled,
      );

      final current = state.whenData((settings) => settings);
      current.whenData((settings) {
        if (settings != null) {
          state = AsyncValue.data(
            settings.copyWith(
              notificationsEnabled:
                  notificationsEnabled ?? settings.notificationsEnabled,
              emailNotificationsEnabled:
                  emailNotificationsEnabled ??
                  settings.emailNotificationsEnabled,
              pushNotificationsEnabled:
                  pushNotificationsEnabled ?? settings.pushNotificationsEnabled,
            ),
          );
        }
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update dark mode preference
  Future<void> updateDarkMode(String userId, bool enabled) async {
    try {
      await _service.updateUserSettings(userId, {'darkModeEnabled': enabled});
      final current = state.whenData((settings) => settings);
      current.whenData((settings) {
        if (settings != null) {
          state = AsyncValue.data(settings.copyWith(darkModeEnabled: enabled));
        }
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update location preference
  Future<void> updateLocationPreference(
    String userId,
    String? locationPreference,
  ) async {
    try {
      await _service.updateUserSettings(userId, {
        'locationPreference': locationPreference,
      });
      final current = state.whenData((settings) => settings);
      current.whenData((settings) {
        if (settings != null) {
          state = AsyncValue.data(
            settings.copyWith(locationPreference: locationPreference),
          );
        }
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh settings
  Future<void> refresh(String userId) async {
    await _loadSettings(userId);
  }
}

/// User settings provider using StateNotifierProvider
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, AsyncValue<UserSettingsModel?>>(
      (ref) {
        return UserSettingsNotifier(ref);
      },
    );

/// Real-time user settings stream provider
final userSettingsStreamProvider = StreamProvider.autoDispose
    .family<UserSettingsModel?, String>((ref, userId) {
      return FirestoreService().getUserSettingsStream(userId);
    });
