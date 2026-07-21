import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../domain/mbti_summary_models.dart';

class MbtiSummaryGateArgs {
  const MbtiSummaryGateArgs({this.availability});

  final MbtiSummaryAvailability? availability;
}

/// Shown when fusion is not yet available (missing results or guest).
class MbtiSummaryGatePage extends StatelessWidget {
  const MbtiSummaryGatePage({super.key, this.args});

  final MbtiSummaryGateArgs? args;

  String _lockedMessage(MbtiSummaryAvailability? availability) {
    if (availability == null) {
      return AppText.t('mbti_sum_locked_guest');
    }
    if (availability.missingMbti && availability.missingCognitive) {
      return AppText.t('mbti_sum_locked_both');
    }
    if (availability.missingMbti) {
      return AppText.t('mbti_sum_locked_mbti');
    }
    return AppText.t('mbti_sum_locked_cognitive');
  }

  @override
  Widget build(BuildContext context) {
    final availability = args?.availability;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('mbti_summary_title')),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                AppText.t('mbti_sum_locked_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _lockedMessage(availability),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppText.t('mbti_sum_locked_back')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
