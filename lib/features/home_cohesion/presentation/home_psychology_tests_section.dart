import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v2_copy.dart';

class HomePsychologyTestsSection extends StatelessWidget {
  const HomePsychologyTestsSection({
    super.key,
    required this.data,
    required this.onTestAction,
  });

  final HomePsychologyTestsSectionData data;
  final void Function(HomePsychologyTestItemData test) onTestAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          HomeV2Copy.psychologyTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          HomeV2Copy.psychologySubtitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (var i = 0; i < data.tests.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _PsychologyTestRow(
                  test: data.tests[i],
                  onPressed: () => onTestAction(data.tests[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PsychologyTestRow extends StatelessWidget {
  const _PsychologyTestRow({
    required this.test,
    required this.onPressed,
  });

  final HomePsychologyTestItemData test;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final actionLabel = switch (test.status) {
      HomePsychologyTestStatus.completed => HomeV2Copy.viewResult,
      HomePsychologyTestStatus.inProgress => HomeV2Copy.continueTest,
      HomePsychologyTestStatus.notStarted => HomeV2Copy.takeTest,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  test.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  HomeV2Copy.psychologyStatusLabel(test.status),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C4A6E),
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
