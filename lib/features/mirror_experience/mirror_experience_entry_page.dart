import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/presentation/pages/profile/edit_profile_page_v1.dart';

import 'mirror_experience_entry_service.dart';
import 'mirror_experience_input.dart';
import 'mirror_experience_runtime.dart';
import 'ui/mirror_home.dart';

/// P3 — the production entry for the Global Mirror Experience.
///
/// Loads the profile's birth date, then hands the [MirrorHome] surface the chart
/// input and the Fusion Runtime. Reasoning happens only through the Fusion
/// Runtime; this page just resolves "who is this" and renders the experience.
class MirrorExperienceEntryPage extends StatefulWidget {
  const MirrorExperienceEntryPage({super.key});

  @override
  State<MirrorExperienceEntryPage> createState() =>
      _MirrorExperienceEntryPageState();
}

class _MirrorExperienceEntryPageState extends State<MirrorExperienceEntryPage> {
  final _entryService = MirrorExperienceEntryService();
  late Future<MirrorExperienceInput?> _inputFuture;

  @override
  void initState() {
    super.initState();
    _inputFuture = _entryService.loadInput();
  }

  void _reload() {
    setState(() => _inputFuture = _entryService.loadInput());
  }

  void _openEditProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
          builder: (_) => const EditProfilePageV1(),
        ))
        .then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MirrorExperienceInput?>(
      future: _inputFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final input = snapshot.data;
        if (input == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AstrologyFlowStateBody(
              state: AstrologyFlowState.incompleteProfile,
              onPrimaryAction: _openEditProfile,
              primaryActionLabel: AstrologyFlowCopy.completeProfileCta,
            ),
          );
        }

        return MirrorHome(
          input: input,
          runtime: MirrorExperienceRuntime.fusion,
        );
      },
    );
  }
}
