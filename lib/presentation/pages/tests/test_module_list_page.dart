import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/test_modules.dart';
import 'package:knowme/domain/models/test_category.dart';
import 'package:knowme/domain/models/test_module.dart';
import 'universal_test_page.dart';

class TestModuleListPage extends StatelessWidget {
  final TestCategory category;

  const TestModuleListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;

    final modules = testModules
        .where((m) => category.modules.contains(m.id))
        .toList();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title[lang] ?? category.title["en"] ?? ""),
      ),

      body: ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("tests")
                .doc(module.id)
                .snapshots(),
            builder: (context, snapshot) {
              int answered = 0;
              int total = module.questionCount;
              bool completed = false;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;

                answered = data["answered"] ?? 0;
                total = data["total"] ?? module.questionCount;
                completed = data["completed"] ?? false;
              }

              double percent = total == 0 ? 0 : (answered / total);

              /// STATUS TEXT (2 LANGUAGE)

              String status;
              Color statusColor;

              if (completed) {
                status = lang == "th" ? "✓ ทำเสร็จแล้ว" : "✓ Completed";
                statusColor = Colors.green;
              } else if (answered > 0) {
                status = lang == "th" ? "▶ ทำต่อ" : "▶ Continue";
                statusColor = Colors.orange;
              } else {
                status = lang == "th" ? "○ ยังไม่เริ่ม" : "○ Not started";
                statusColor = Colors.grey;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UniversalTestPage(module: module),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE
                          Text(
                            module.title[lang] ?? module.title["en"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// PROGRESS BAR
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// INFO ROW
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$answered / $total ${lang == "th" ? "ข้อ" : "questions"}",
                                style: const TextStyle(fontSize: 13),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
