import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v2_copy.dart';

class HomeCombinedReflectionSection extends StatelessWidget {
  const HomeCombinedReflectionSection({
    super.key,
    required this.data,
    required this.onViewFullResult,
  });

  final HomeCombinedReflectionSectionData data;
  final void Function() onViewFullResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          HomeV2Copy.combinedReflectionTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (data.units.isEmpty)
          Card(
            elevation: 0,
            color: Colors.white.withValues(alpha: 0.75),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                data.emptyHint,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          )
        else
          ...data.units.map(
            (unit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        unit.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (data.canOpenFullResult)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onViewFullResult,
              child: Text(HomeV2Copy.viewCombinedReflection),
            ),
          ),
      ],
    );
  }
}
