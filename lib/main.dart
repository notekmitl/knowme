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
import 'package:knowme/features/mirror_experience/mirror_experience_routes.dart';
import 'package:knowme/features/knowledge_workspace/knowledge_workspace_routes.dart';
import 'package:knowme/features/product_validation/product_validation_routes.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_demo_routes.dart';
import 'package:knowme/features/astrology/presentation/astrology_center_routes.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_routes.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_demo_routes.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_qa_routes.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_routes.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_routes.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_screenshot_mode.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_routes.dart';

import 'package:knowme/core/web/web_launch_route.dart';
import 'package:knowme/core/web/web_launch_router.dart';
import 'package:knowme/core/web/web_intended_route.dart';
import 'package:knowme/core/web/web_path_url_strategy.dart';
import 'presentation/pages/auth/auth_gate.dart';

import 'presentation/providers/auth_provider.dart';

import 'presentation/providers/profile_provider.dart';

import 'presentation/providers/astrology_provider.dart';

import 'presentation/providers/bazi_provider.dart';

import 'presentation/providers/locale_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Path strategy first so HashUrlStrategy cannot wipe `/beta/thai` during binding.
  configureKnowMePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Re-read after binding so dart:html can see index.html early-capture
  // (data-attribute / sessionStorage) and the live pathname.
  final launchRouteName = webLaunchRouteName();
  WebIntendedRoute.configure(launchRouteName);
  final effectiveLaunchRoute = WebLaunchRouter.effectiveLaunchRoute(launchRouteName);
  ThaiBetaScreenshotMode.configureFromLaunchRoute(effectiveLaunchRoute);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();

  // Public Beta must never touch AuthGate. A dedicated app shell guarantees
  // anonymous `/beta/thai` shows ThaiBetaLandingPage even if Navigator/URL
  // sync later misfires on the full KnowMeApp route table.
  if (ThaiBetaRoutes.isAnonymousPublicLandingRoute(effectiveLaunchRoute)) {
    runApp(const PublicThaiBetaApp());
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(create: (_) => AstrologyProvider()),

        ChangeNotifierProvider(create: (_) => BaziProvider()),

        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],

      child: KnowMeApp(launchRouteName: launchRouteName),
    ),
  );
}

/// Anonymous-only shell for Public Beta landing — no AuthGate in the tree.
class PublicThaiBetaApp extends StatelessWidget {
  const PublicThaiBetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('th'),
      supportedLocales: [Locale('en'), Locale('th')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ThaiBetaLandingPage(),
    );
  }
}

class KnowMeApp extends StatelessWidget {
  const KnowMeApp({super.key, this.launchRouteName});

  /// Hash/path route captured in [main] before the engine boots (web only).
  final String? launchRouteName;

  @override
  Widget build(BuildContext context) {
    final initialRoute =
        WebLaunchRouter.effectiveLaunchRoute(launchRouteName) ?? '/';

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

          // Path URL strategy syncs the browser URL into Navigator. Do not use
          // `home:` here — it pins `/` and races with `/beta/thai`, which sent
          // anonymous Public Beta users to AuthGate/Login in production.
          initialRoute: initialRoute,
          onGenerateInitialRoutes: (newInitialRoute) {
            final routeName = (newInitialRoute.isEmpty || newInitialRoute == '/')
                ? WebLaunchRouter.effectiveLaunchRoute(launchRouteName)
                : newInitialRoute;
            final page = WebLaunchRouter.resolveLaunchWidget(routeName) ??
                const AuthGate();
            return [
              MaterialPageRoute<void>(
                settings: RouteSettings(name: routeName ?? '/'),
                builder: (_) => page,
              ),
            ];
          },

          builder: (context, child) {
            return ThaiBetaScreenshotScope(
              active: ThaiBetaScreenshotMode.isActive,
              child: child ?? const SizedBox.shrink(),
            );
          },

          onGenerateRoute: (settings) {
            // Public + guarded deep links resolved the same way as cold start.
            final launchWidget =
                WebLaunchRouter.resolveLaunchWidget(settings.name);
            if (launchWidget != null) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => launchWidget,
              );
            }
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
            final mirrorExperienceRoute =
                MirrorExperienceRoutes.onGenerateRoute(settings);
            if (mirrorExperienceRoute != null) {
              return mirrorExperienceRoute;
            }
            final productValidationRoute =
                ProductValidationRoutes.onGenerateRoute(settings);
            if (productValidationRoute != null) {
              return productValidationRoute;
            }
            final thaiBetaRoute = ThaiBetaRoutes.onGenerateRoute(settings);
            if (thaiBetaRoute != null) {
              return thaiBetaRoute;
            }
            final knowledgeWorkspaceRoute =
                KnowledgeWorkspaceRoutes.onGenerateRoute(settings);
            if (knowledgeWorkspaceRoute != null) {
              return knowledgeWorkspaceRoute;
            }
            final thaiCanonEvidenceRoute =
                ThaiCanonEvidenceRoutes.onGenerateRoute(settings);
            if (thaiCanonEvidenceRoute != null) {
              return thaiCanonEvidenceRoute;
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
            final astrologyCenterRoute =
                AstrologyCenterRoutes.onGenerateRoute(settings);
            if (astrologyCenterRoute != null) {
              return astrologyCenterRoute;
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
