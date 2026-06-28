import 'package:flutter/material.dart';

import 'features/astrology/thai/qa/harness/thai_qa_harness_profiles.dart';
import 'features/mirror_experience/mirror_experience_input.dart';
import 'features/mirror_experience/mirror_experience_runtime.dart';
import 'features/mirror_experience/ui/mirror_home.dart';
import 'features/mirror_experience/ui/mirror_theme.dart';

/// Standalone, unauthenticated preview entrypoint for the Global Mirror
/// Experience (P3). It boots straight into [MirrorHome] with a sample chart so
/// the full journey can be exercised and screenshotted without Firebase/auth.
///
/// Production still boots from `lib/main.dart` (AuthGate → ProfileGate →
/// HomePage); the experience is reachable there at `/mirror-experience`.
///
/// Usage:
///   flutter run -t lib/main_mirror_experience.dart
///   flutter build web -t lib/main_mirror_experience.dart --output build/web_mirror
void main() {
  runApp(const _MirrorPreviewApp());
}

class _MirrorPreviewApp extends StatelessWidget {
  const _MirrorPreviewApp();

  @override
  Widget build(BuildContext context) {
    final profile = ThaiQaHarnessProfiles.byId('A');
    final local = profile.birthData.localDateTime;
    final input = MirrorExperienceInput(
      birthDate: DateTime(local.year, local.month, local.day),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MirrorTheme.themeData(),
      home: MirrorHome(
        input: input,
        runtime: MirrorExperienceRuntime.fusion,
      ),
    );
  }
}
