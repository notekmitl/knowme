import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'package:knowme/features/tests/eq/eq_routes.dart';
import 'package:knowme/features/tests/mbti/mbti_routes.dart';
import 'package:knowme/features/tests/mbti_cognitive/mbti_cognitive_routes.dart';
import 'package:knowme/features/tests/mbti_summary/mbti_summary_routes.dart';

import 'presentation/pages/auth/auth_gate.dart';

import 'presentation/providers/auth_provider.dart';

import 'presentation/providers/profile_provider.dart';

import 'presentation/providers/astrology_provider.dart';

import 'presentation/providers/bazi_provider.dart';

import 'presentation/providers/locale_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(create: (_) => AstrologyProvider()),

        ChangeNotifierProvider(create: (_) => BaziProvider()),

        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],

      child: const KnowMeApp(),
    ),
  );
}

class KnowMeApp extends StatelessWidget {
  const KnowMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          locale: localeProvider.locale,

          supportedLocales: const [Locale('en'), Locale('th')],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,

            GlobalWidgetsLocalizations.delegate,

            GlobalCupertinoLocalizations.delegate,
          ],

          home: const AuthGate(),

          onGenerateRoute: (settings) {
            final eqRoute = EqRoutes.onGenerateRoute(settings);
            if (eqRoute != null) {
              return eqRoute;
            }
            final mbtiRoute = MbtiRoutes.onGenerateRoute(settings);
            if (mbtiRoute != null) {
              return mbtiRoute;
            }
            final cognitiveRoute =
                MbtiCognitiveRoutes.onGenerateRoute(settings);
            if (cognitiveRoute != null) {
              return cognitiveRoute;
            }
            final summaryRoute = MbtiSummaryRoutes.onGenerateRoute(settings);
            if (summaryRoute != null) {
              return summaryRoute;
            }

            return MaterialPageRoute<void>(
              settings: const RouteSettings(name: '/'),
              builder: (_) => const AuthGate(),
            );
          },
        );
      },
    );
  }
}
