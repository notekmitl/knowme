import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/services//personality_profile_service.dart';
import 'package:knowme/services//insight_generator.dart';
import 'package:knowme/services//archetype_service.dart';
import 'package:knowme/services//personality_ai_summary.dart'; // ← เพิ่ม

import 'package:knowme/domain/models/personality_profile.dart';
import 'package:knowme/domain/models/personality_archetype.dart';

import 'package:knowme/core/i18n/app_text.dart';
import '../../widgets/radar_chart_widget.dart';
import '../../widgets/trait_bar.dart';

class PersonalityProfilePage extends StatefulWidget {
  const PersonalityProfilePage({super.key});

  @override
  State<PersonalityProfilePage> createState() => _PersonalityProfilePageState();
}

class _PersonalityProfilePageState extends State<PersonalityProfilePage> {
  PersonalityProfile? profile;
  PersonalityArchetype? archetype;

  List<String> insights = [];

  /// AI Summary
  Map<String, String> aiSummary = {};

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
      if (doc.id == "bigfive") {
        bigfive = doc.data();
      }

      if (doc.id == "eq") {
        eq = doc.data();
      }

      if (doc.id == "attachment") {
        attachment = doc.data();
      }

      if (doc.id == "motivation") {
        motivation = doc.data();
      }
    }

    final element = userDoc.data()?["astrology"]?["element"] ?? "unknown";

    final profileService = PersonalityProfileService();

    final builtProfile = profileService.buildProfile(
      bigfive: bigfive,
      eq: eq,
      attachment: attachment,
      motivation: motivation,
      element: element,
    );

    /// AI Summary
    aiSummary = PersonalityAISummary.generate(builtProfile);

    final generatedInsights = InsightGenerator.generate(builtProfile);

    final detectedArchetype = ArchetypeService.detect(builtProfile);

    setState(() {
      profile = builtProfile;
      insights = generatedInsights;
      archetype = detectedArchetype;
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
        title: Text(AppText.t("profile_title")),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            /// Radar Chart
            SizedBox(
              height: 260,
              child: RadarChartWidget(
                openness: profile!.traits["openness"] ?? 0,
                conscientiousness: profile!.traits["conscientiousness"] ?? 0,
                extraversion: profile!.traits["extraversion"] ?? 0,
                agreeableness: profile!.traits["agreeableness"] ?? 0,
                neuroticism: profile!.traits["neuroticism"] ?? 0,
              ),
            ),

            const SizedBox(height: 30),

            /// Personality Analysis
            Text(
              AppText.t("personality_analysis"),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ...insights.map(
              (e) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(e, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// AI Personality Summary
            const Text(
              "AI Personality Summary",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Strength: ${aiSummary["strength"] ?? ""}"),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Weakness: ${aiSummary["weakness"] ?? ""}"),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Work Style: ${aiSummary["work_style"] ?? ""}"),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Relationship Style: ${aiSummary["relationship_style"] ?? ""}",
                ),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Growth Advice: ${aiSummary["growth_advice"] ?? ""}",
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Big Five
            Text(
              AppText.t("bigfive"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

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

            /// EQ
            Text(
              AppText.t("eq"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              "${AppText.t("awareness")}: ${profile!.traits["awareness"] ?? 0}",
            ),
            Text(
              "${AppText.t("regulation")}: ${profile!.traits["regulation"] ?? 0}",
            ),
            Text("${AppText.t("empathy")}: ${profile!.traits["empathy"] ?? 0}"),

            const SizedBox(height: 30),

            /// Attachment
            Text(
              AppText.t("attachment"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text("${AppText.t("secure")}: ${profile!.traits["secure"] ?? 0}"),
            Text("${AppText.t("anxious")}: ${profile!.traits["anxious"] ?? 0}"),
            Text(
              "${AppText.t("avoidant")}: ${profile!.traits["avoidant"] ?? 0}",
            ),

            const SizedBox(height: 30),

            /// Motivation
            Text(
              AppText.t("motivation"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text("${AppText.t("growth")}: ${profile!.traits["growth"] ?? 0}"),
            Text(
              "${AppText.t("achievement")}: ${profile!.traits["achievement"] ?? 0}",
            ),
            Text("${AppText.t("purpose")}: ${profile!.traits["purpose"] ?? 0}"),
          ],
        ),
      ),
    );
  }
}
