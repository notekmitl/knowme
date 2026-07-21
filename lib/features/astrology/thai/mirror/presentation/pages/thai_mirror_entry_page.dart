import 'dart:async';

import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/presentation/pages/profile/edit_profile_page_v1.dart';

import '../../application/thai_mirror_entry_service.dart';
import '../../runtime/thai_mirror_pipeline_result.dart';
import '../thai_mirror_consumer_presenter.dart';
import '../ui/pages/thai_mirror_result_page.dart';
import '../ui/widgets/thai_mirror_loading_view.dart';

/// Production entry — loads profile birth data and renders [ThaiMirrorResultPage].
class ThaiMirrorEntryPage extends StatefulWidget {
  const ThaiMirrorEntryPage({super.key});

  @override
  State<ThaiMirrorEntryPage> createState() => _ThaiMirrorEntryPageState();
}

class _ThaiMirrorEntryPageState extends State<ThaiMirrorEntryPage> {
  final _entryService = ThaiMirrorEntryService();
  late Future<ThaiMirrorPipelineResult> _pipelineFuture;

  /// Flips to true after the load runs long enough that we should reassure the
  /// user that deeper analysis is still in progress (instead of looking frozen).
  bool _deepAnalysis = false;
  Timer? _deepAnalysisTimer;

  @override
  void initState() {
    super.initState();
    _startLoad();
  }

  @override
  void dispose() {
    _deepAnalysisTimer?.cancel();
    super.dispose();
  }

  void _startLoad() {
    _deepAnalysis = false;
    _deepAnalysisTimer?.cancel();
    _deepAnalysisTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _deepAnalysis = true);
    });
    _pipelineFuture = _entryService.loadResult();
  }

  Future<void> _reload() async {
    setState(_startLoad);
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
          // Each branch is keyed so AnimatedSwitcher fades/scales between the
          // loading skeleton and the final result without a blank flash.
          final child = _bodyFor(snapshot);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (widget, animation) {
              final scale = Tween<double>(begin: 0.98, end: 1).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: scale, child: widget),
              );
            },
            child: child,
          );
        },
      ),
    );
  }

  Widget _bodyFor(AsyncSnapshot<ThaiMirrorPipelineResult> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return KeyedSubtree(
        key: const ValueKey('thai_loading'),
        child: ThaiMirrorLoadingView(deepAnalysis: _deepAnalysis),
      );
    }

    final result = snapshot.data;
    if (result == null) {
      return _incompleteProfileState();
    }

    if (result.isFailure) {
      final message = result.errorMessage ?? '';
      final incompleteProfile = message.contains('birth') ||
          message.contains('profile') ||
          message.contains('เกิด') ||
          message.contains('not available');

      if (incompleteProfile) {
        return _incompleteProfileState();
      }

      return KeyedSubtree(
        key: const ValueKey('thai_error'),
        child: AstrologyFlowStateBody(
          state: AstrologyFlowState.failed,
          onPrimaryAction: _reload,
          primaryActionLabel: AstrologyFlowCopy.retryCta,
        ),
      );
    }

    return KeyedSubtree(
      key: const ValueKey('thai_result'),
      child: ThaiMirrorResultPage(
        consumerState: ThaiMirrorConsumerPresenter.present(
          result.mirrorResult!,
          lifePeriods: result.lifePeriods,
        ),
      ),
    );
  }

  Widget _incompleteProfileState() {
    return KeyedSubtree(
      key: const ValueKey('thai_empty'),
      child: AstrologyFlowStateBody(
        state: AstrologyFlowState.incompleteProfile,
        onPrimaryAction: _openEditProfile,
        primaryActionLabel: AstrologyFlowCopy.completeProfileCta,
      ),
    );
  }
}
