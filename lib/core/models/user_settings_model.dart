import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsModel {
  final String userId;
  final String languageCode; // en, sw
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final String? locationPreference;
  final bool darkModeEnabled;
  final DateTime lastUpdated;

  UserSettingsModel({
    required this.userId,
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.locationPreference,
    this.darkModeEnabled = false,
    required this.lastUpdated,
  });

  /// Factory constructor from Firestore document
  factory UserSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSettingsModel(
      userId: data['userId'] as String? ?? '',
      languageCode: data['languageCode'] as String? ?? 'en',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          data['emailNotificationsEnabled'] as bool? ?? true,
      pushNotificationsEnabled:
          data['pushNotificationsEnabled'] as bool? ?? true,
      locationPreference: data['locationPreference'] as String?,
      darkModeEnabled: data['darkModeEnabled'] as bool? ?? false,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'languageCode': languageCode,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'locationPreference': locationPreference,
      'darkModeEnabled': darkModeEnabled,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Create a copy with modifications
  UserSettingsModel copyWith({
    String? userId,
    String? languageCode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    String? locationPreference,
    bool? darkModeEnabled,
    DateTime? lastUpdated,
  }) {
    return UserSettingsModel(
      userId: userId ?? this.userId,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      locationPreference: locationPreference ?? this.locationPreference,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
