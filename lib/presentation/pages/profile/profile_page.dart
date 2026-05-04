import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final birthDateController = TextEditingController();
  final birthTimeController = TextEditingController();
  final birthPlaceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      nameController.text = data['name'] ?? '';
      birthDateController.text = data['birthDate'] ?? '';
      birthTimeController.text = data['birthTime'] ?? '';
      birthPlaceController.text = data['birthPlace'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': nameController.text.trim(),
      'birthDate': birthDateController.text.trim(),
      'birthTime': birthTimeController.text.trim(),
      'birthPlace': birthPlaceController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved ✅")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: birthDateController,
              decoration: const InputDecoration(
                labelText: "Birth Date (YYYY-MM-DD)",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: birthTimeController,
              decoration: const InputDecoration(
                labelText: "Birth Time (HH:MM)",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: birthPlaceController,
              decoration: const InputDecoration(labelText: "Birth Place"),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
