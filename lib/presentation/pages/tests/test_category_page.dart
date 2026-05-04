import 'package:flutter/material.dart';

import 'package:knowme/data/test_categories.dart';
import 'package:knowme/core/i18n/app_text.dart';

import 'test_module_list_page.dart';

class TestCategoryPage extends StatelessWidget {
  const TestCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;

    return Scaffold(
      appBar: AppBar(title: Text(AppText.t("personality_tests"))),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: testCategories.length,

        itemBuilder: (context, index) {
          final category = testCategories[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

              child: ListTile(
                /// ICON
                leading: Icon(
                  category.icon,
                  size: 28,
                  color: Colors.deepPurple,
                ),

                /// TITLE
                title: Text(
                  category.title[lang] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                /// DESCRIPTION
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    category.description[lang] ?? "",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),

                /// ARROW
                trailing: const Icon(Icons.arrow_forward_ios),

                /// NAVIGATION
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
