import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/location_picker.dart';
import '../home/home_page.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<ProfileSetupPage> {
  final nameController = TextEditingController();
  final birthPlaceController = TextEditingController();

  DateTime? birthDate;
  TimeOfDay? birthTime;

  String gender = "male";
  double? latitude;
  double? longitude;

  bool isLoading = false;

  Future<void> pickBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => birthDate = date);
    }
  }

  Future<void> pickBirthTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (time != null) {
      setState(() => birthTime = time);
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty ||
        birthDate == null ||
        birthTime == null ||
        birthPlaceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": nameController.text.trim(),
        "gender": gender,
        "birthDate": birthDate!.toIso8601String(),
        "birthTime": "${birthTime!.hour}:${birthTime!.minute}",
        "birthPlace": birthPlaceController.text.trim(),
        "latitude": latitude,
        "longitude": longitude,
        "timezone": "Asia/Bangkok",
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select Birth Date";
    return "${date.day}/${date.month}/${date.year}";
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return "Select Birth Time";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: gender,
              decoration: InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "male", child: Text("Male")),
                DropdownMenuItem(value: "female", child: Text("Female")),
              ],
              onChanged: (value) {
                setState(() => gender = value!);
              },
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickBirthDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(formatDate(birthDate)),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickBirthTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(formatTime(birthTime)),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () async {
                final result = await LocationPicker.pick(context);

                if (result != null) {
                  setState(() {
                    birthPlaceController.text = result["name"];
                    latitude = result["lat"];
                    longitude = result["lng"];
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  birthPlaceController.text.isEmpty
                      ? "Select Birth Place"
                      : birthPlaceController.text,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
