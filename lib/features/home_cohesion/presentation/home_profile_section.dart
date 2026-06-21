import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v2_copy.dart';

class HomeProfileSection extends StatelessWidget {
  const HomeProfileSection({
    super.key,
    required this.data,
    required this.onEditProfile,
  });

  final HomeProfileSectionData data;
  final void Function() onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              HomeV2Copy.profileTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Text(
              data.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _ProfileRow(label: 'วันเกิด', value: data.birthDate),
            _ProfileRow(label: 'เวลาเกิด', value: data.birthTime),
            _ProfileRow(label: 'สถานที่เกิด', value: data.birthPlace),
            if (data.completenessLabel.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: data.completenessRatio,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE8DFF0),
                  color: const Color(0xFF7B5EA7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.completenessLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onEditProfile,
                child: Text(HomeV2Copy.editProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
