import 'package:flutter/material.dart';

import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Recovery cohort banner — astrology complete, no personality tests.
class HomeRecoveryBanner extends StatelessWidget {
  const HomeRecoveryBanner({
    super.key,
    required this.onStartTest,
  });

  final VoidCallback onStartTest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeV35Design.purpleAccent.withValues(alpha: 0.12),
            HomeV35Design.purpleSoft,
          ],
        ),
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        border: Border.all(
          color: HomeV35Design.purpleAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeV3Copy.recoveryBannerTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HomeV35Design.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            HomeV3Copy.recoveryBannerBody,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: HomeV35Design.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStartTest,
              style: FilledButton.styleFrom(
                backgroundColor: HomeV35Design.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(HomeV3Copy.recoveryBannerCta),
            ),
          ),
        ],
      ),
    );
  }
}
