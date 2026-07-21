import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../application/personality_mirror_entry_service.dart';
import 'personality_mirror_gate_page.dart';
import 'personality_mirror_result_page.dart';

/// Loads mirror data and routes to gate or result (read-only).
class PersonalityMirrorEntryPage extends StatefulWidget {
  const PersonalityMirrorEntryPage({super.key});

  @override
  State<PersonalityMirrorEntryPage> createState() =>
      _PersonalityMirrorEntryPageState();
}

class _PersonalityMirrorEntryPageState extends State<PersonalityMirrorEntryPage> {
  final _entryService = PersonalityMirrorEntryService();

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const PersonalityMirrorGatePage(),
        ),
      );
      return;
    }

    final entry = await _entryService.evaluate(uid);
    if (!entry.canOpen) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PersonalityMirrorGatePage(
            args: PersonalityMirrorGateArgs(coverage: entry.coverage),
          ),
        ),
      );
      return;
    }

    final experience = await _entryService.loadExperience(uid);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PersonalityMirrorResultPage(
          narrative: experience.narrative,
          showFullExperience: experience.canShowFullExperience,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.t('personality_mirror_title'))),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
