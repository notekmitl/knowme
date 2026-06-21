import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../domain/personality_coverage.dart';

class PersonalityMirrorGateArgs {
  const PersonalityMirrorGateArgs({this.coverage});

  final PersonalityCoverage? coverage;
}

/// Shown when fewer than two primary personality lenses are available.
class PersonalityMirrorGatePage extends StatelessWidget {
  const PersonalityMirrorGatePage({super.key, this.args});

  final PersonalityMirrorGateArgs? args;

  String _lockedMessage(PersonalityCoverage? coverage) {
    if (coverage == null) {
      return AppText.t('personality_mirror_gate_guest');
    }

    final missing = <String>[];
    if (!coverage.hasMbti) {
      missing.add(AppText.t('personality_mirror_lens_mbti'));
    }
    if (!coverage.hasBigFive) {
      missing.add(AppText.t('personality_mirror_lens_big_five'));
    }
    if (!coverage.hasAnyEq) {
      missing.add(AppText.t('personality_mirror_lens_eq'));
    }

    if (missing.isEmpty) {
      return AppText.t('personality_mirror_gate_body');
    }

    final joiner = AppText.lang == 'th' ? ' และ ' : ' and ';
    return AppText.t('personality_mirror_gate_missing')
        .replaceAll('{missing}', missing.join(joiner));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('personality_mirror_title')),
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
                AppText.t('personality_mirror_gate_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppText.t('personality_mirror_gate_body'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _lockedMessage(args?.coverage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppText.t('personality_mirror_gate_back')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
