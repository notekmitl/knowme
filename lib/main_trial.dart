import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/core/web/web_path_url_strategy.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';

/// Calculation-only web entrypoint. Build with tool/build_trial_web.py.
void main() {
  if (!ApiConfig.isOverallPreview) {
    throw StateError('The isolated trial requires KNOWME_OVERALL_PREVIEW');
  }
  // Validate the isolated endpoint before showing the form.
  ApiConfig.overallCalculationBaseUrl;
  configureKnowMePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  ThaiEvidenceBadgeFeatureFlag.applyConfiguredState();
  runApp(const TrialApp());
}

class TrialApp extends StatelessWidget {
  const TrialApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Locale('th'),
    supportedLocales: [Locale('en'), Locale('th')],
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: ThaiBetaLandingPage(anonymousTrial: true),
  );
}
