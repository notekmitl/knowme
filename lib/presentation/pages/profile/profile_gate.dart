import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

import '../home/home_page.dart';
import 'profile_setup_page.dart';

class ProfileGate extends StatelessWidget {
  const ProfileGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // safety
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('main')
          .snapshots(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // no profile
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ProfileSetupPage();
        }

        // load profile → provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ProfileProvider>().loadProfile();
        });

        // profile exists
        return const HomePage();
      },
    );
  }
}
