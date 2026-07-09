import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/mirror/presentation/pages/thai_mirror_consumer_preview_page.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_routes.dart';
import 'package:knowme/features/astrology/thai/qa/harness/thai_qa_harness_spec.dart';
import 'package:knowme/features/knowledge_workspace/acquisition/knowledge_acquisition_dashboard.dart';
import 'package:knowme/features/knowledge_workspace/knowledge_workspace_routes.dart';
import 'package:knowme/features/knowledge_workspace/presentation/knowledge_workspace_page.dart';
import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_capture_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_routes.dart';
import 'package:knowme/presentation/pages/auth/auth_gate.dart';

import 'web_launch_route.dart';

/// Picks the app entry widget from the browser URL on web (public consumer
/// preview deep links) or falls back to [AuthGate] for the normal signed-in flow.
class WebLaunchRouter extends StatelessWidget {
  const WebLaunchRouter({super.key, this.launchRouteName});

  /// Route captured in [main] before Flutter can rewrite the browser URL.
  final String? launchRouteName;

  @override
  Widget build(BuildContext context) {
    return resolveLaunchWidget(launchRouteName) ?? const AuthGate();
  }

  /// Resolves the entry widget for a captured browser launch route (testable).
  @visibleForTesting
  static Widget? resolveLaunchWidget(String? launchRouteName) {
    final routeName = launchRouteName ?? webLaunchRouteName();
    if (routeName == null) return null;

    final uri = _routeUri(routeName);
    if (ThaiBetaRoutes.isCapturePath(uri.path)) {
      return const ThaiBetaCapturePage();
    }
    if (ThaiBetaRoutes.isBetaPath(uri.path)) {
      return const ThaiBetaLandingPage();
    }
    if (uri.path == ThaiBetaRoutes.adminRouteName) {
      return const ThaiResearchAdminGuard();
    }
    if (uri.path == KnowledgeWorkspaceRoutes.acquireRouteName) {
      return ThaiResearchAdminGuard(
        adminBuilder: (_) => const KnowledgeAcquisitionDashboard(),
      );
    }
    if (uri.path == KnowledgeWorkspaceRoutes.routeName) {
      return ThaiResearchAdminGuard(
        adminBuilder: (_) => const KnowledgeWorkspacePage(),
      );
    }
    if (uri.path == ThaiMirrorRoutes.consumerPreviewRouteName) {
      return ThaiMirrorConsumerPreviewPage(
        spec: ThaiQaHarnessSpec.fromQueryParameters(uri.queryParameters),
      );
    }
    if (uri.path == ThaiMirrorRoutes.consumerPreviewNoTimeRouteName) {
      return const ThaiMirrorConsumerPreviewPage(
        profileId: 'A',
        hasBirthTime: false,
      );
    }
    return null;
  }

  static Uri _routeUri(String name) {
    final normalized = name.startsWith('/') ? name : '/$name';
    return Uri.parse('https://local$normalized');
  }
}
