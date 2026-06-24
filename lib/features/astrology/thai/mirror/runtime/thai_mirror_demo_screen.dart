import 'package:flutter/material.dart';

import '../../foundation/models/thai_birth_data.dart';
import '../presentation/thai_mirror_consumer_presenter.dart';
import '../presentation/ui/pages/thai_mirror_result_page.dart';
import 'thai_mirror_pipeline.dart';
import 'thai_mirror_pipeline_result.dart';

/// Internal QA screen — runs the real pipeline and renders [ThaiMirrorResultPage].
class ThaiMirrorDemoScreen extends StatefulWidget {
  const ThaiMirrorDemoScreen({
    super.key,
    this.birthData,
  });

  final ThaiBirthData? birthData;

  @override
  State<ThaiMirrorDemoScreen> createState() => _ThaiMirrorDemoScreenState();
}

class _ThaiMirrorDemoScreenState extends State<ThaiMirrorDemoScreen> {
  late Future<ThaiMirrorPipelineResult> _pipelineFuture;

  @override
  void initState() {
    super.initState();
    _pipelineFuture = Future(
      () => ThaiMirrorPipeline.generate(
        widget.birthData ?? ThaiMirrorPipeline.sampleQaBirthData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai Mirror QA'),
      ),
      body: FutureBuilder<ThaiMirrorPipelineResult>(
        future: _pipelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          if (result == null) {
            return _ErrorBody(message: 'Pipeline returned no result.');
          }

          if (result.isFailure) {
            return _ErrorBody(message: result.errorMessage ?? 'Unknown error');
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

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
