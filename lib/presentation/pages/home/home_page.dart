import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:knowme/core/test_registry.dart';
import 'package:knowme/core/result_store.dart';

import 'package:knowme/astrology/providers/astrology_provider.dart';
import 'package:knowme/astrology/models/astrology_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadAstrology();
  }

  Future<void> _loadAstrology() async {
    // ตรงนี้ใช้ logic เดิมมึงได้เลย
    // (Firestore load เดิม)
  }

  @override
  Widget build(BuildContext context) {
    final resultStore = context.watch<ResultStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("KnowMe"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =========================
            /// 🔮 ASTROLOGY (ความน่าเชื่อถือ)
            /// =========================
            Consumer<AstrologyProvider>(
              builder: (context, provider, _) {
                final result = provider.result;

                if (result == null) {
                  return const SizedBox();
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  elevation: 4,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🔮 Astrology Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text("Sun: ${result.sunSign}"),
                        Text(
                          "Moon: ${result.planets?['moon']?['sign'] ?? '-'}",
                        ),
                        Text("Ascendant: ${result.ascendant ?? '-'}"),
                        Text("Element: ${result.element}"),
                        Text("Chinese Zodiac: ${result.chineseZodiac}"),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// =========================
            /// 🧪 TEST SECTION
            /// =========================
            const Text(
              "🧪 เลือกแบบทดสอบ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: testRegistry.length,
                itemBuilder: (context, index) {
                  final test = testRegistry[index];

                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),

                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),

                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => test.builder()),
                          );

                          if (result != null && result is TestResult) {
                            resultStore.add(result);
                          }
                        },

                        child: Center(
                          child: Text(
                            test.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// =========================
            /// 📊 RESULT SUMMARY
            /// =========================
            const Text(
              "📊 ผลของคุณ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            resultStore.results.isEmpty
                ? const Text(
                    "ยังไม่มีผลลัพธ์",
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    children: resultStore.results.map((r) {
                      return Card(
                        child: ListTile(
                          title: Text(r.testId),
                          subtitle: Text(r.data.toString()),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
