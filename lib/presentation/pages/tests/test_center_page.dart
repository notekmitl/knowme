import 'package:flutter/material.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/test_categories.dart';
import 'test_module_list_page.dart';

class TestCenterPage extends StatelessWidget {
  const TestCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.t("personality_tests"))),
      body: ListView.builder(
        itemCount: testCategories.length,
        itemBuilder: (context, index) {
          final category = testCategories[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                title: Text(
                  category.title[AppText.lang] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TestModuleListPage(category: category),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
