import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'core/database/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await HiveService.init();
  await initializeDateFormatting('tr_TR');
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
