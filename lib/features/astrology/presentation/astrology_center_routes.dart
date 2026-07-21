import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'astrology_center_page.dart';

abstract final class AstrologyCenterRoutes {
  static const String routeName = '/astrology-center';

  static Route<void> route() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => AstrologyCenterPage(uid: uid),
    );
  }

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(route());
  }

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    if (settings.name != routeName) return null;
    return route();
  }
}
