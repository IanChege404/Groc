import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import 'core/config/env_config.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme_dark.dart';
import 'core/themes/app_themes.dart';
import 'core/services/fcm_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/hive_service.dart';
import 'core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  Logger.info('FCM background message: ${message.messageId}', 'main');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await EnvConfig.init();

  // Initialize Firebase
  try {
    await FirebaseService().initialize();
  } catch (e) {
    Logger.warning('Firebase init warning: $e', 'main');
  }

  // Initialize Hive local cache
  try {
    await HiveService().initialize();
  } catch (e) {
    Logger.warning('Hive init warning: $e', 'main');
  }

  // Initialize FCM
  try {
    final fcm = FcmService();
    await fcm.requestPermission();
    fcm.initialize(
      onForegroundMessage: (message) {
        Logger.info(
          'FCM foreground: ${message.notification?.title}',
          'main',
        );
      },
      onBackgroundMessageTap: (message) {
        Logger.info(
          'FCM tapped: ${message.data}',
          'main',
        );
      },
    );

    // Save token for authenticated user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fcm.saveTokenToFirestore(user.uid);
    }
  } catch (e) {
    Logger.warning('FCM init warning: $e', 'main');
  }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  runApp(
    ProviderScope(
      child: p.ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return p.Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp.router(
          title: 'Afri-Commerce',
          theme: AppTheme.defaultTheme,
          darkTheme: AppThemeDark.darkTheme,
          themeMode:
              localeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Localization setup
          locale: localeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('sw')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          routerConfig: appRouter,
        );
      },
    );
  }
}
