import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Opens the platform app store listing so the user can rate/review the app.
///
/// The store IDs below must be updated to the real published listing
/// (Play Store package name / App Store numeric app ID) once the app ships.
class StoreReviewLauncher {
  StoreReviewLauncher._();

  static const String _androidPackageName = 'com.example.new_proj';
  static const String _iosAppId = '0000000000';

  static Future<void> openStoreListing() async {
    final Uri uri;
    if (Platform.isIOS) {
      uri = Uri.parse(
        'https://apps.apple.com/app/id$_iosAppId?action=write-review',
      );
    } else {
      uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_androidPackageName',
      );
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
