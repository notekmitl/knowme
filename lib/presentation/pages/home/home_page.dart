import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import '../../providers/astrology_provider.dart';

import '../astrology/astrology_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGenerating = false;

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

      final provider = context.read<AstrologyProvider>();

      await provider.generateChart(
        uid: user.uid,

        birthDate: profile['birthDate'].toString().split('T').first,

        birthTime: profile['birthTime'],

        latitude: profile['latitude'],

        longitude: profile['longitude'],
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AstrologyResultPage()),
      );
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                onPressed: _isGenerating ? null : _generateChart,

                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Generate Astrology Chart'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AstrologyResultPage(),
                    ),
                  );
                },

                child: const Text('Open Astrology Result'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
