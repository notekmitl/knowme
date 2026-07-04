import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';

import 'thai_canon_evidence_review_page.dart';

/// Internal route for Canon evidence QA (`/internal/thai-canon-evidence`).
abstract final class ThaiCanonEvidenceRoutes {
  static const String routeName = '/internal/thai-canon-evidence';

  static Uri _routeUri(String name) {
    final normalized = name.startsWith('/') ? name : '/$name';
    return Uri.parse('https://local$normalized');
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final path = _routeUri(settings.name ?? '/').path;
    if (path == routeName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const ThaiResearchAdminGuard(
          adminBuilder: _buildReviewPage,
        ),
      );
    }
    return null;
  }

  static Widget _buildReviewPage(BuildContext context) =>
      const ThaiCanonEvidenceReviewPage();
}
