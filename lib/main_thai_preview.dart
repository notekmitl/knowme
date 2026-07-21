import 'package:flutter/material.dart';

import 'features/astrology/thai/mirror/presentation/pages/thai_mirror_consumer_preview_page.dart';
import 'features/astrology/thai/qa/harness/thai_qa_harness_spec.dart';

/// Standalone, unauthenticated preview entrypoint for visual QA of the Thai
/// consumer report. NOT a production entrypoint — it bypasses AuthGate so the
/// full QA Harness (`?profile=A..H&age=&viewport=&theme=&locale=&scenario=`) can
/// be screenshotted locally. Production still boots from `lib/main.dart`
/// (AuthGate → ProfileGate → HomePage) unchanged.
///
/// Usage:
///   flutter build web -t lib/main_thai_preview.dart --output build/web_preview
void main() {
  runApp(const _ThaiPreviewApp());
}

class _ThaiPreviewApp extends StatelessWidget {
  const _ThaiPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final query = Uri.tryParse(name)?.queryParameters ?? const {};
        final spec = ThaiQaHarnessSpec.fromQueryParameters(query);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ThaiMirrorConsumerPreviewPage(spec: spec),
        );
      },
    );
  }
}
