import 'package:flutter/material.dart';
import 'package:knowme/services/compatibility_service.dart';
import 'package:knowme/domain/models/personality_core_result.dart';
import 'package:knowme/astrology/models/astrology_result.dart';

class CompatibilityPage extends StatefulWidget {
  const CompatibilityPage({super.key});

  @override
  State<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends State<CompatibilityPage> {
  double partnerExtraversion = 50;
  double partnerAgreeable = 50;
  double partnerNeurotic = 50;

  String resultText = "";

  void calculate() {
    final you = PersonalityCoreResult(
      openness: 60,
      conscientiousness: 60,
      extraversion: 70,
      agreeableness: 80,
      neuroticism: 40,
    );

    final partner = PersonalityCoreResult(
      openness: 50,
      conscientiousness: 50,
      extraversion: partnerExtraversion,
      agreeableness: partnerAgreeable,
      neuroticism: partnerNeurotic,
    );

    final yourAstro = AstrologyResult(
      sunSign: "Leo",
      element: "Fire",
      chineseZodiac: "Dog",
      ascendant: "Cancer",
      planets: {},
    );

    final partnerAstro = AstrologyResult(
      sunSign: "Aries",
      element: "Fire",
      chineseZodiac: "Dragon",
      ascendant: "Leo",
      planets: {},
    );

    final result = CompatibilityService.calculate(
      you: you,
      partner: partner,
      yourAstro: yourAstro,
      partnerAstro: partnerAstro,
    );

    setState(() {
      resultText =
          "คะแนนความเข้ากันได้: ${result.score.toStringAsFixed(0)}%\n\n"
          "${result.reasons.join("\n")}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ความเข้ากันได้"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "บุคลิกของอีกฝ่าย",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// Extraversion
              Text(
                "การเข้าสังคม ${partnerExtraversion.toInt()}",
                textAlign: TextAlign.center,
              ),

              Slider(
                value: partnerExtraversion,
                min: 0,
                max: 100,
                onChanged: (v) {
                  setState(() {
                    partnerExtraversion = v;
                  });
                },
              ),

              const SizedBox(height: 10),

              /// Agreeableness
              Text(
                "ความเห็นอกเห็นใจ ${partnerAgreeable.toInt()}",
                textAlign: TextAlign.center,
              ),

              Slider(
                value: partnerAgreeable,
                min: 0,
                max: 100,
                onChanged: (v) {
                  setState(() {
                    partnerAgreeable = v;
                  });
                },
              ),

              const SizedBox(height: 10),

              /// Neuroticism
              Text(
                "ความอ่อนไหวทางอารมณ์ ${partnerNeurotic.toInt()}",
                textAlign: TextAlign.center,
              ),

              Slider(
                value: partnerNeurotic,
                min: 0,
                max: 100,
                onChanged: (v) {
                  setState(() {
                    partnerNeurotic = v;
                  });
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: calculate,
                child: const Text("คำนวณความเข้ากันได้"),
              ),

              const SizedBox(height: 30),

              /// Result
              if (resultText.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Text(
                      resultText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
