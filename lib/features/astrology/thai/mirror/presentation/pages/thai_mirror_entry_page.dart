import 'package:flutter/material.dart';

import '../../application/thai_mirror_entry_service.dart';
import '../../runtime/thai_mirror_pipeline_result.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai'),
      ),
      body: FutureBuilder<ThaiMirrorPipelineResult>(
        future: _pipelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          if (result == null) {
            return _ErrorBody(
              message: 'Thai Astrology could not be loaded.',
              onRetry: _reload,
            );
          }

          if (result.isFailure) {
            return _ErrorBody(
              message: result.errorMessage ?? 'Unknown error',
              onRetry: _reload,
            );
          }

          return ThaiMirrorResultPage(viewState: result.viewState!);
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}
