import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';

import 'thai_canon_evidence_review_page.dart';
import 'thai_public_evidence_badge_preview_page.dart';

/// Internal routes for Canon evidence QA (`/internal/thai-canon-evidence`) and
/// public evidence badge preview (`/internal/thai-public-evidence-preview`).
abstract final class ThaiCanonEvidenceRoutes {
  static const String routeName = '/internal/thai-canon-evidence';
  static const String publicEvidencePreviewRouteName =
      '/internal/thai-public-evidence-preview';

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
    if (path == publicEvidencePreviewRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: publicEvidencePreviewRouteName),
        builder: (_) => const ThaiResearchAdminGuard(
          adminBuilder: _buildPublicEvidencePreviewPage,
        ),
      );
    }
    return null;
  }

  static Widget _buildReviewPage(BuildContext context) =>
      const ThaiCanonEvidenceReviewPage();

  static Widget _buildPublicEvidencePreviewPage(BuildContext context) =>
      const ThaiPublicEvidenceBadgePreviewPage();
}
