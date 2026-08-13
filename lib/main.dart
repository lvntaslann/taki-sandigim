import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'core/database/hive_service.dart';
import 'core/services/purchase_service.dart';
import 'firebase_options.dart';

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
  await initializeDateFormatting('tr_TR');
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
          title: 'Takı Sandığım',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
