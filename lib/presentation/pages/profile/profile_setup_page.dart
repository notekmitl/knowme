import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../providers/astrology_provider.dart';
import '../../providers/bazi_provider.dart';
import '../../widgets/location_picker.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final nameController = TextEditingController();
  final birthPlaceController = TextEditingController();

  DateTime? birthDate;
  TimeOfDay? birthTime;

  String gender = "male";

  double? latitude;
  double? longitude;

  bool isLoading = false;

  Future<void> pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  Future<void> pickBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (picked != null) {
      setState(() {
        birthTime = picked;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return "Select Birth Date";
    }

    return "${date.day}/${date.month}/${date.year}";
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) {
      return "Select Birth Time";
    }

    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _apiBirthDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty ||
        birthDate == null ||
        birthTime == null ||
        birthPlaceController.text.isEmpty ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not found");
      }

      final astrologyProvider = context.read<AstrologyProvider>();
      final birthTimeStr = formatTime(birthTime);

      const timezone = 'Asia/Bangkok';

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("profile")
          .doc("main")
          .set({
            "name": nameController.text.trim(),
            "gender": gender,
            "birthDate": birthDate!.toIso8601String(),
            "birthTime": birthTimeStr,
            "birthPlace": birthPlaceController.text.trim(),
            "latitude": latitude,
            "longitude": longitude,
            "timezone": timezone,
          });

      final baziProvider = context.read<BaziProvider>();
      final apiBirthDate = _apiBirthDate(birthDate!);

      await Future.wait([
        astrologyProvider.generateChart(
          uid: user.uid,
          birthDate: apiBirthDate,
          birthTime: birthTimeStr,
          latitude: latitude!,
          longitude: longitude!,
        ),
        baziProvider.generateBazi(
          uid: user.uid,
          birthDate: apiBirthDate,
          birthTime: birthTimeStr,
          timezone: timezone,
          latitude: latitude,
          longitude: longitude,
        ),
      ]);

      // ProfileGate จะ detect profile/main แล้วเข้า HomePage เอง

      if (!mounted) return;

      final westernError = astrologyProvider.error;
      final baziError = baziProvider.error;

      if (westernError == null && baziError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );

      if (westernError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Western chart could not be generated: $westernError',
            ),
          ),
        );
      }

      if (baziError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chinese BaZi chart could not be generated: $baziError',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    birthPlaceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // NAME
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

            // GENDER
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
                if (value != null) {
                  setState(() {
                    gender = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // BIRTH DATE
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

            // BIRTH TIME
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

            // LOCATION
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

            // SAVE BUTTON
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
