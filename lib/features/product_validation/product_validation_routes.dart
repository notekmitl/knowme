import 'package:flutter/material.dart';

import 'ui/product_validation_dashboard.dart';

/// Phase A — routing for the **internal** product-validation dashboard.
///
/// Additive and intentionally **not linked** from any user surface. It is
/// reachable only by navigating to [dashboardRouteName] directly (e.g. the web
/// path `/internal/product-validation`). It plugs into the existing
/// `onGenerateRoute` chain without touching the production user flow.
abstract final class ProductValidationRoutes {
  static const String dashboardRouteName = '/internal/product-validation';

  static Route<void> dashboardRoute() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: dashboardRouteName),
        builder: (_) => const ProductValidationDashboard(),
      );

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final path = Uri.tryParse(name)?.path ?? name;
    if (path == dashboardRouteName) {
      return dashboardRoute();
    }
    return null;
  }
}
