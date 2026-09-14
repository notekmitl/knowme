import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:knowme/presentation/pages/auth/login_page.dart';
import 'package:knowme/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Reuses KnowMe authentication while returning the verified uid to the
/// anonymous birth-form flow after login or registration succeeds.
class ThaiBetaAstrologySignInPage extends StatefulWidget {
  const ThaiBetaAstrologySignInPage({super.key});

  @override
  State<ThaiBetaAstrologySignInPage> createState() =>
      _ThaiBetaAstrologySignInPageState();
}

class _ThaiBetaAstrologySignInPageState
    extends State<ThaiBetaAstrologySignInPage> {
  StreamSubscription<User?>? _subscription;
  bool _returning = false;

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseAuth.instance.authStateChanges().listen(_onUser);
  }

  void _onUser(User? user) {
    if (user == null || _returning) return;
    _returning = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ownRoute = ModalRoute.of(context);
      if (ownRoute == null) return;
      final navigator = Navigator.of(context);
      // Registration is pushed above LoginPage. Close it first, then return the
      // authenticated uid from this handoff route.
      navigator.popUntil((route) => identical(route, ownRoute));
      navigator.pop(user.uid);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: Stack(
        children: [
          Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => Stack(
                children: [
                  const LoginPage(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'กลับไปเลือกศาสตร์',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                'เข้าสู่ระบบเพื่อบันทึกและสร้างดวง',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
