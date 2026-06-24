import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/presentation/pages/profile/edit_profile_page_v1.dart';

import '../../application/thai_mirror_entry_service.dart';
import '../../runtime/thai_mirror_pipeline_result.dart';
import '../thai_mirror_consumer_presenter.dart';
import '../ui/pages/thai_mirror_result_page.dart';

/// Production entry — loads profile birth data and renders [ThaiMirrorResultPage].
class ThaiMirrorEntryPage extends StatefulWidget {
  const ThaiMirrorEntryPage({super.key});

  @override
  State<ThaiMirrorEntryPage> createState() => _ThaiMirrorEntryPageState();
}

class _ThaiMirrorEntryPageState extends State<ThaiMirrorEntryPage> {
  final _entryService = ThaiMirrorEntryService();
  late Future<ThaiMirrorPipelineResult> _pipelineFuture;

  @override
  void initState() {
    super.initState();
    _pipelineFuture = _entryService.loadResult();
  }

  Future<void> _reload() async {
    setState(() {
      _pipelineFuture = _entryService.loadResult();
    });
    await _pipelineFuture;
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfilePageV1()),
    ).then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โหราศาสตร์ไทย'),
      ),
      body: FutureBuilder<ThaiMirrorPipelineResult>(
        future: _pipelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AstrologyGenerationBody(
              title: AstrologyFlowCopy.generationTitle('ดวงไทย'),
              body: AstrologyFlowCopy.generationBody('ดวงไทย'),
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return AstrologyFlowStateBody(
              state: AstrologyFlowState.incompleteProfile,
              onPrimaryAction: _openEditProfile,
              primaryActionLabel: AstrologyFlowCopy.completeProfileCta,
            );
          }

          if (result.isFailure) {
            final message = result.errorMessage ?? '';
            final incompleteProfile = message.contains('birth') ||
                message.contains('profile') ||
                message.contains('เกิด') ||
                message.contains('not available');

            if (incompleteProfile) {
              return AstrologyFlowStateBody(
                state: AstrologyFlowState.incompleteProfile,
                onPrimaryAction: _openEditProfile,
                primaryActionLabel: AstrologyFlowCopy.completeProfileCta,
              );
            }

            return AstrologyFlowStateBody(
              state: AstrologyFlowState.failed,
              onPrimaryAction: _reload,
              primaryActionLabel: AstrologyFlowCopy.retryCta,
            );
          }

          return ThaiMirrorResultPage(
            consumerState: ThaiMirrorConsumerPresenter.present(
              result.mirrorResult!,
            ),
          );
        },
      ),
    );
  }
}
