import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:taki_sandigim/app/routes/app_routes.dart';
import 'package:taki_sandigim/core/database/box_names.dart';
import 'package:taki_sandigim/features/onboarding/presentation/screens/email_entry_screen.dart';
import 'package:taki_sandigim/l10n/app_localizations.dart';

/// Guards the App Store review path: on an English device the reviewer must
/// be able to see and tap the skip link, even with the keyboard open.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // In-memory box: nothing touches disk, so there is nothing to clean up.
    await Hive.openBox(BoxNames.settings, bytes: Uint8List(0));
  });

  Widget buildApp(Locale locale) {
    final router = GoRouter(
      initialLocation: AppRoutes.emailEntry,
      routes: [
        GoRoute(
          path: AppRoutes.emailEntry,
          builder: (_, _) => const EmailEntryScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (_, _) => const Text('dashboard'),
        ),
      ],
    );
    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  // iPhone SE (smallest supported screen) and a modern iPhone, each with a
  // keyboard taking up roughly 40% of the height.
  const screens = {
    'iPhone SE': (Size(375, 667), 260.0),
    'iPhone 15': (Size(393, 852), 336.0),
  };

  for (final MapEntry(key: name, value: (size, keyboard)) in screens.entries) {
    for (final (locale, label) in [
      (const Locale('en'), 'SKIP'),
      (const Locale('tr'), 'ATLA'),
    ]) {
      testWidgets('$label visible and tappable above keyboard on $name',
          (tester) async {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        tester.view.viewInsets =
            FakeViewPadding(bottom: keyboard * 3);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildApp(locale));
        await tester.pumpAndSettle();

        final skip = find.text(label);
        expect(skip, findsOneWidget);
        final rect = tester.getRect(skip);
        expect(rect.bottom, lessThanOrEqualTo(size.height - keyboard));
        expect(rect.top, greaterThanOrEqualTo(0));

        await tester.tap(skip);
        await tester.pumpAndSettle();
        expect(find.text('dashboard'), findsOneWidget);
      });
    }
  }
}
