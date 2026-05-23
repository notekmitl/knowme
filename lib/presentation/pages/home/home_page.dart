import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/services/astrology_firestore_service.dart';

import '../../providers/astrology_provider.dart';

import '../astrology/astrology_result_page.dart';
import '../tests/test_center_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGenerating = false;
  bool _checkingChart = true;
  bool _hasChart = false;

  final _chartReader = AstrologyFirestoreService();

  @override
  void initState() {
    super.initState();
    _checkChartExists();
  }

  /// Read-only: does not generate a chart.
  Future<void> _checkChartExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _checkingChart = false;
          _hasChart = false;
        });
      }
      return;
    }

    try {
      final chart = await _chartReader.getWesternNatalChart(user.uid);
      if (!mounted) return;
      setState(() {
        _hasChart = chart != null;
        _checkingChart = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasChart = false;
        _checkingChart = false;
      });
    }
  }

  Future<void> _openResultPage() async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AstrologyResultPage()),
    );
    if (!mounted) return;
    await _checkChartExists();
  }

  Future<void> _generateChart() async {
    try {
      setState(() {
        _isGenerating = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('main')
          .get();

      final profile = profileDoc.data();

      if (profile == null) {
        throw Exception('Profile not found');
      }

      final lat = profile['latitude'];
      final lng = profile['longitude'];
      if (lat == null || lng == null || lat is! num || lng is! num) {
        throw Exception('Birth location is required');
      }

      final provider = context.read<AstrologyProvider>();

      await provider.generateChart(
        uid: user.uid,
        birthDate: profile['birthDate'].toString().split('T').first,
        birthTime: profile['birthTime'],
        latitude: (lat as num).toDouble(),
        longitude: (lng as num).toDouble(),
      );

      if (!mounted) return;

      setState(() {
        _hasChart = true;
      });

      await _openResultPage();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _onPrimaryTap() async {
    if (_hasChart) {
      await _openResultPage();
    } else {
      await _generateChart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final primaryBusy = _checkingChart || _isGenerating;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome ${user?.email ?? ''}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: primaryBusy ? null : _onPrimaryTap,
                child: primaryBusy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : Text(AppText.t('astro_home_primary')),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _openResultPage,
                  child: const Text('Open Astrology Result'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TestCenterPage(),
                      ),
                    );
                  },
                  child: const Text('Open Tests (temporary QA)'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
