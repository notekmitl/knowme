import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/presentation/pages/auth/login_page.dart';

import '../../application/thai_research_admin_access.dart';
import 'thai_beta_admin_page.dart';

/// Gates the internal research admin surface (`/internal/thai-beta`).
///
/// Public users can never reach the dashboard, detail, or statistics: they are
/// shown the existing login screen, and signed-in non-admins get an explicit
/// access-denied screen. Admin status is checked against the same allow-list
/// enforced by `firestore.rules`.
class ThaiResearchAdminGuard extends StatefulWidget {
  const ThaiResearchAdminGuard({
    super.key,
    this.access,
    this.signedOutBuilder,
    this.deniedBuilder,
    this.adminBuilder,
  });

  /// Injectable for tests; defaults to the Firebase-backed resolver.
  final ThaiResearchAdminAccess? access;

  /// Optional overrides (used in tests to avoid building Firebase-backed pages).
  final WidgetBuilder? signedOutBuilder;
  final WidgetBuilder? deniedBuilder;
  final WidgetBuilder? adminBuilder;

  @override
  State<ThaiResearchAdminGuard> createState() => _ThaiResearchAdminGuardState();
}

class _ThaiResearchAdminGuardState extends State<ThaiResearchAdminGuard> {
  late final ThaiResearchAdminAccess _access =
      widget.access ?? FirebaseThaiResearchAdminAccess();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThaiResearchAccess>(
      stream: _access.watch(),
      builder: (context, snapshot) {
        final access = snapshot.data ?? ThaiResearchAccess.unknown;
        switch (access) {
          case ThaiResearchAccess.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case ThaiResearchAccess.signedOut:
            return widget.signedOutBuilder?.call(context) ?? const LoginPage();
          case ThaiResearchAccess.notAdmin:
            return widget.deniedBuilder?.call(context) ?? const _AccessDenied();
          case ThaiResearchAccess.admin:
            return widget.adminBuilder?.call(context) ??
                const ThaiBetaAdminPage();
        }
      },
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Thai Astrology Research — Internal')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: scheme.error),
              const SizedBox(height: 16),
              const Text(
                'บัญชีนี้ไม่มีสิทธิ์เข้าถึงหน้าวิเคราะห์ภายใน',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This account is not authorized to view internal research data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('ออกจากระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
