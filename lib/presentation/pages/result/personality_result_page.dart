import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/domain/models/personality_profile.dart';
import 'package:knowme/domain/models/personality_archetype.dart';

import 'package:knowme/services//personality_profile_service.dart';
import 'package:knowme/services//archetype_service.dart';
import 'package:knowme/services//insight_generator.dart';

import '../../widgets/radar_chart_widget.dart';
import '../../widgets/trait_bar.dart';

import 'package:knowme/core/i18n/app_text.dart';

class PersonalityResultPage extends StatefulWidget {
  const PersonalityResultPage({super.key});

  @override
  State<PersonalityResultPage> createState() => _PersonalityResultPageState();
}

class _PersonalityResultPageState extends State<PersonalityResultPage> {
  PersonalityProfile? profile;
  PersonalityArchetype? archetype;
  List<String> insights = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final results = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("results")
        .get();

    Map<String, dynamic> bigfive = {};
    Map<String, dynamic> eq = {};
    Map<String, dynamic> attachment = {};
    Map<String, dynamic> motivation = {};

    for (var doc in results.docs) {
      if (doc.id == "bigfive") bigfive = doc.data();
      if (doc.id == "eq") eq = doc.data();
      if (doc.id == "attachment") attachment = doc.data();
      if (doc.id == "motivation") motivation = doc.data();
    }

    final element = userDoc.data()?["astrology"]?["element"] ?? "unknown";

    final service = PersonalityProfileService();

    final builtProfile = service.buildProfile(
      bigfive: bigfive,
      eq: eq,
      attachment: attachment,
      motivation: motivation,
      element: element,
    );

    final detectedArchetype = ArchetypeService.detect(builtProfile);
    final generatedInsights = InsightGenerator.generate(builtProfile);

    setState(() {
      profile = builtProfile;
      archetype = detectedArchetype;
      insights = generatedInsights;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t("result_title")),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Radar Chart
            SizedBox(
              height: 280,
              child: RadarChartWidget(
                openness: profile!.traits["openness"] ?? 0,
                conscientiousness: profile!.traits["conscientiousness"] ?? 0,
                extraversion: profile!.traits["extraversion"] ?? 0,
                agreeableness: profile!.traits["agreeableness"] ?? 0,
                neuroticism: profile!.traits["neuroticism"] ?? 0,
              ),
            ),

            const SizedBox(height: 30),

            /// Archetype Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    Text(
                      AppText.t("your_type"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      archetype?.name[AppText.lang] ?? "-",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      archetype?.description[AppText.lang] ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Trait Bars
            Text(
              AppText.t("traits"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TraitBar(
              title: AppText.t("openness"),
              value: profile!.traits["openness"] ?? 0,
            ),

            TraitBar(
              title: AppText.t("conscientiousness"),
              value: profile!.traits["conscientiousness"] ?? 0,
            ),

            TraitBar(
              title: AppText.t("extraversion"),
              value: profile!.traits["extraversion"] ?? 0,
            ),

            TraitBar(
              title: AppText.t("agreeableness"),
              value: profile!.traits["agreeableness"] ?? 0,
            ),

            TraitBar(
              title: AppText.t("neuroticism"),
              value: profile!.traits["neuroticism"] ?? 0,
            ),

            const SizedBox(height: 30),

            /// Insight Section
            Text(
              AppText.t("insights"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ...insights.map(
              (e) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(e, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                AppText.t("improve_accuracy"),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
