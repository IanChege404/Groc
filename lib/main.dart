import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import 'core/config/env_config.dart';
import 'core/l10n/locale_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/on_generate_route.dart';
import 'core/themes/app_theme_dark.dart';
import 'core/themes/app_themes.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  // Defaults to .env.development if no environment is specified
  // Change the parameter to use different environment files
  await EnvConfig.init();

  // Initialize Firebase
  try {
    await FirebaseService().initialize();
  } catch (e) {
    Logger.warning('Firebase init warning: $e', 'main');
    // Continue app even if Firebase fails
  }

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
        return MaterialApp(
          title: 'Afri-Commerce',
          theme: AppTheme.defaultTheme,
          darkTheme: AppThemeDark.darkTheme,
          themeMode: localeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          // Localization setup
          locale: localeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('sw')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          onGenerateRoute: RouteGenerator.onGenerate,
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}
