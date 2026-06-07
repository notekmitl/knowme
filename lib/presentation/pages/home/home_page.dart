import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/tests/fusion/fusion_routes.dart';

import '../../providers/auth_provider.dart';
import '../astrology/astrology_result_page.dart';
import '../bazi/bazi_result_page.dart';
import '../tests/test_center_page.dart';

/// Neutral discovery hub (hotfix — no journey suggestion until Home redesign).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openTestCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TestCenterPage()),
    );
  }

  void _openAstrologyResultPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AstrologyResultPage()),
    );
  }

  void _openBaziResultPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BaziResultPage()),
    );
  }

  Future<void> _openFusionResultPage(BuildContext context) async {
    await FusionRoutes.openResult(context);
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome ${user?.email ?? ''}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildNeutralHeroCard(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _openTestCenter(context),
                child: Text(AppText.t('home_explore_all_tests')),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => _openAstrologyResultPage(context),
                  child: const Text('Open Astrology Result'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _openFusionResultPage(context),
                  child: const Text('Open Fusion (QA)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _openBaziResultPage(context),
                  child: const Text('Open BaZi Result (QA)'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeutralHeroCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppText.t('home_journey_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppText.t('home_hub_body'),
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
