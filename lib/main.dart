import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'core/database/hive_service.dart';
import 'core/services/purchase_service.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Protects backend Cloud Functions (e.g. aiEvaluate) from being called by
  // anything other than this app. Requires Play Integrity to be enabled for
  // this app in the Firebase console — see functions/src/ai/evaluate.js.
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );
  await dotenv.load();
  await PurchaseService.instance.init();
  await HiveService.init();
  await initializeDateFormatting('tr');
  await initializeDateFormatting('en');
  unawaited(MobileAds.instance.initialize());
  // Warm the onboarding flow's custom fonts before first paint so the
  // initial screen (and the transitions right after it) don't stall on a
  // first-use network font fetch.
  GoogleFonts.greatVibes();
  GoogleFonts.baloo2();
  GoogleFonts.playfairDisplay();
  await GoogleFonts.pendingFonts();
  runApp(const TakiSandigimApp());
}

class TakiSandigimApp extends StatelessWidget {
  const TakiSandigimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance,
        builder: (context, themeMode, _) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: _resolveLocale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}

/// Picks the first device language the app supports; any other language
/// falls back to English. Also syncs [Intl.defaultLocale] so date/number
/// formatting outside the widget tree follows the same language.
Locale _resolveLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  final locale =
      deviceLocales
          ?.map(
            (device) => supported
                .where((s) => s.languageCode == device.languageCode)
                .firstOrNull,
          )
          .nonNulls
          .firstOrNull ??
      const Locale('en');
  Intl.defaultLocale = locale.languageCode;
  return locale;
}
