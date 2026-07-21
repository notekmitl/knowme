import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/qa/harness/thai_qa_harness_page.dart';
import 'package:knowme/features/astrology/thai/qa/harness/thai_qa_harness_spec.dart';

/// Consumer report preview / QA Harness entry.
///
/// This page is intentionally thin: it builds a [ThaiQaHarnessSpec] and delegates
/// to [ThaiQaHarnessPage], which renders the **production** report through the
/// real pipeline. Routing supplies a full [spec] (profile/age/viewport/theme/
/// locale/scenario); the legacy `profileId` / `hasBirthTime` constructor is kept
/// for existing widget tests and simple deep links.
class ThaiMirrorConsumerPreviewPage extends StatelessWidget {
  const ThaiMirrorConsumerPreviewPage({
    super.key,
    this.profileId = 'A',
    this.hasBirthTime = true,
    this.spec,
  });

  final String profileId;
  final bool hasBirthTime;

  /// Full harness spec parsed from query params. When provided it takes
  /// precedence over [profileId] / [hasBirthTime].
  final ThaiQaHarnessSpec? spec;

  static const routeName = '/thai-mirror/consumer-preview';

  @override
  Widget build(BuildContext context) {
    final resolved = spec ??
        ThaiQaHarnessSpec(
          profileId: profileId,
          forceNoBirthTime: !hasBirthTime,
        );
    return ThaiQaHarnessPage(spec: resolved);
  }
}
