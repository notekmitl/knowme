import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:knowme/astrology/providers/astrology_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final birthPlaceController = TextEditingController();

  String? gender;
  DateTime? birthDate;
  TimeOfDay? birthTime;

  double? selectedLat;
  double? selectedLng;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  bool loading = false;

  /// =============================
  /// LOCATION
  /// =============================
  Future<Position?> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = doc.data();

    if (data == null) return;

    setState(() {
      nameController.text = data["name"] ?? "";
      birthPlaceController.text = data["birthPlace"] ?? "";

      gender = data["gender"];

      /// ⭐ เพิ่มตรงนี้
      selectedLat = data["latitude"];
      selectedLng = data["longitude"];

      if (data["birthDate"] != null) {
        birthDate = DateTime.parse(data["birthDate"]);
      }

      if (data["birthTime"] != null) {
        final parts = data["birthTime"].split(":");

        birthTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    });
  }

  Future<void> searchCity() async {
    final query = birthPlaceController.text.trim();

    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        double lat = loc.latitude;
        double lng = loc.longitude;

        setState(() {
  selectedLat = lat;
  selectedLng = lng;
});

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Using: $query ($lat , $lng)")));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// =============================
  /// SAVE PROFILE
  /// =============================
  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (birthDate == null || birthTime == null) return;

    setState(() => loading = true);

    /// รวมวัน + เวลาเกิด
    DateTime birthDateTime = DateTime(
      birthDate!.year,
      birthDate!.month,
      birthDate!.day,
      birthTime!.hour,
      birthTime!.minute,
    );

    /// ⭐ LOCATION
    print("USE SELECTED LOCATION");

double? lat = selectedLat;
double? lng = selectedLng;

print("LAT: $lat");
print("LNG: $lng");

    /// ⭐ โชว์บนหน้าจอ
    if (!mounted) return;

    if (lat != null && lng != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Using location: $lat , $lng")));
    }

    /// ⭐ ASTROLOGY
    final astrologyProvider = context.read<AstrologyProvider>();

    try {
  await astrologyProvider
    .calculate(
      birthDateTime: birthDateTime,
      lat: lat,
      lng: lng,
    )
    .timeout(const Duration(seconds: 5));
} catch (e) {
  debugPrint("Astrology error: $e");
}

    final result = astrologyProvider.result;

Map<String, dynamic>? astrologyData;

if (result != null) {
  astrologyData = result.toMap();
} else {
  debugPrint("Using fallback astrology");

  final zodiac = "Gemini";

  astrologyData = {
    "sunSign": zodiac,
    "element": "Air",
    "chineseZodiac": "Dog",
    "ascendant": "Cancer",
    "planets": {
      "sun": {"sign": zodiac},
      "moon": {"sign": "Libra"},
      "mercury": {"sign": "Gemini"},
      "venus": {"sign": "Taurus"},
      "mars": {"sign": "Libra"},
      "jupiter": {"sign": "Scorpio"},
      "saturn": {"sign": "Capricorn"},
    }
  };
}


  /// ⭐ FIRESTORE

Map<String, dynamic> updateData = {
  "name": nameController.text.trim(),
  "gender": gender ?? "",
  "birthDate": birthDate!.toIso8601String(),
  "birthTime": "${birthTime!.hour}:${birthTime!.minute}",
  "birthPlace": birthPlaceController.text.trim(),
  "latitude": lat,
  "longitude": lng,
};

/// เพิ่ม astrology เฉพาะตอนที่มีข้อมูล
if (astrologyData != null) {
  updateData["astrology"] = astrologyData;
}
print("ASTROLOGY DATA: $astrologyData");
await FirebaseFirestore.instance
    .collection("users")
    .doc(uid)
    .update(updateData);

    if (!mounted) return;

    setState(() => loading = false);

    Navigator.pop(context);
  }

  /// =============================
  /// UI
  /// =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: "male", child: Text("Male")),
                DropdownMenuItem(value: "female", child: Text("Female")),
              ],
              onChanged: (v) => setState(() => gender = v),
              decoration: const InputDecoration(labelText: "Gender"),
            ),

            const SizedBox(height: 12),

            ListTile(
              title: Text(
                birthDate == null ? "Select Birth Date" : birthDate.toString(),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => birthDate = date);
                }
              },
            ),

            ListTile(
              title: Text(
                birthTime == null
                    ? "Select Birth Time"
                    : birthTime!.format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => birthTime = time);
                }
              },
            ),

            TextField(
              controller: birthPlaceController,
              decoration: const InputDecoration(labelText: "Birth Place"),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: searchCity,
              child: const Text("Search Birth Location"),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : saveProfile,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
