import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';
import 'package:knowme/features/knowledge_workspace/acquisition/knowledge_acquisition_dashboard.dart';
import 'package:knowme/features/knowledge_workspace/canon_review/canon_reviewer_workspace_page.dart';
import 'package:knowme/features/knowledge_workspace/presentation/knowledge_workspace_page.dart';

/// Routing for the **internal** Knowledge Workspace (V5) and the Knowledge
/// Acquisition Dashboard (V6).
///
/// Admin-only and intentionally not linked from any user surface — reachable
/// only by navigating to the route paths directly. Both reuse the existing
/// [ThaiResearchAdminGuard] (same allow-list as `firestore.rules`) and plug into
/// the app's `onGenerateRoute` chain without touching the production user flow.
abstract final class KnowledgeWorkspaceRoutes {
  static const String routeName = '/internal/knowledge';
  static const String acquireRouteName = '/internal/knowledge/acquire';
  static const String canonReviewRouteName = '/internal/knowledge/canon-review';

  static Uri _routeUri(String name) {
    final normalized = name.startsWith('/') ? name : '/$name';
    return Uri.parse('https://local$normalized');
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final path = _routeUri(settings.name ?? '/').path;
    if (path == canonReviewRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: canonReviewRouteName),
        builder: (_) => const ThaiResearchAdminGuard(
          adminBuilder: _buildCanonReview,
        ),
      );
    }
    if (path == acquireRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: acquireRouteName),
        builder: (_) => const ThaiResearchAdminGuard(
          adminBuilder: _buildAcquisition,
        ),
      );
    }
    if (path == routeName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const ThaiResearchAdminGuard(
          adminBuilder: _buildWorkspace,
        ),
      );
    }
    return null;
  }

  static Widget _buildWorkspace(BuildContext context) =>
      const KnowledgeWorkspacePage();

  static Widget _buildAcquisition(BuildContext context) =>
      const KnowledgeAcquisitionDashboard();

  static Widget _buildCanonReview(BuildContext context) =>
      const CanonReviewerWorkspacePage();
}
