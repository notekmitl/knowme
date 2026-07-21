import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:knowme/core/profile/canonical_profile_resolver.dart';
import '../../providers/profile_provider.dart';

import '../home/home_page.dart';
import 'profile_setup_page.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  final _profileResolver = CanonicalProfileResolver();
  bool _migrating = true;

  @override
  void initState() {
    super.initState();
    _migrateLegacyProfile();
  }

  Future<void> _migrateLegacyProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _profileResolver.ensureMigrated(user.uid);
    }
    if (mounted) {
      setState(() => _migrating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    if (_migrating) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('main')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ProfileSetupPage();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ProfileProvider>().loadProfile();
        });

        return const HomePage();
      },
    );
  }
}
