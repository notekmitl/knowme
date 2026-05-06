import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("KnowMe Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<ProfileProvider>().clear();

              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: profileProvider.isLoading
            ? const CircularProgressIndicator()
            : Text(
                "Welcome ${profile?.name ?? ''}",
                style: const TextStyle(fontSize: 20),
              ),
      ),
    );
  }
}
