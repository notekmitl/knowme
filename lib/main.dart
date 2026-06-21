import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'package:knowme/features/tests/big_five/big_five_routes.dart';
import 'package:knowme/features/tests/eq/eq_routes.dart';
import 'package:knowme/features/tests/mbti/mbti_routes.dart';
import 'package:knowme/features/tests/mbti_cognitive/mbti_cognitive_routes.dart';
import 'package:knowme/features/tests/mbti_summary/mbti_summary_routes.dart';
import 'package:knowme/features/personality_mirror/personality_mirror_routes.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_demo_routes.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_routes.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_demo_routes.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_qa_routes.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_routes.dart';

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
            final bigFiveRoute = BigFiveRoutes.onGenerateRoute(settings);
            if (bigFiveRoute != null) {
              return bigFiveRoute;
            }
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
            final personalityMirrorRoute =
                PersonalityMirrorRoutes.onGenerateRoute(settings);
            if (personalityMirrorRoute != null) {
              return personalityMirrorRoute;
            }
            final thaiMirrorRoute = ThaiMirrorRoutes.onGenerateRoute(settings);
            if (thaiMirrorRoute != null) {
              return thaiMirrorRoute;
            }
            final thaiMirrorDemoRoute =
                ThaiMirrorDemoRoutes.onGenerateRoute(settings);
            if (thaiMirrorDemoRoute != null) {
              return thaiMirrorDemoRoute;
            }
            final astrologyFusionRoute =
                AstrologyFusionRoutes.onGenerateRoute(settings);
            if (astrologyFusionRoute != null) {
              return astrologyFusionRoute;
            }
            final astrologyFusionDemoRoute =
                AstrologyFusionDemoRoutes.onGenerateRoute(settings);
            if (astrologyFusionDemoRoute != null) {
              return astrologyFusionDemoRoute;
            }
            final thaiMirrorQaRoute = ThaiMirrorQaRoutes.onGenerateRoute(settings);
            if (thaiMirrorQaRoute != null) {
              return thaiMirrorQaRoute;
            }
            final thaiMirrorPopulationQaRoute =
                ThaiMirrorPopulationQaRoutes.onGenerateRoute(settings);
            if (thaiMirrorPopulationQaRoute != null) {
              return thaiMirrorPopulationQaRoute;
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
