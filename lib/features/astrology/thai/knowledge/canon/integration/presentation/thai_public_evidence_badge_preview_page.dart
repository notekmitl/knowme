import 'package:flutter/material.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import '../integration.dart';
import 'thai_public_evidence_badge_preview.dart';
import 'thai_public_evidence_badge_preview_mapper.dart';

/// Internal beta preview of LEVEL 1 public evidence summary badges.
///
/// Route: `/internal/thai-public-evidence-preview` (admin-guarded).
/// Never linked from consumer surfaces.
class ThaiPublicEvidenceBadgePreviewPage extends StatefulWidget {
  const ThaiPublicEvidenceBadgePreviewPage({
    super.key,
    this.pipelineResult,
    this.initialBundle,
    this.repository,
  });

  final ThaiMirrorPipelineResult? pipelineResult;
  final ThaiMirrorCanonEvidenceBundle? initialBundle;
  final ThaiCanonEvidenceRepository? repository;

  @override
  State<ThaiPublicEvidenceBadgePreviewPage> createState() =>
      _ThaiPublicEvidenceBadgePreviewPageState();
}

class _ThaiPublicEvidenceBadgePreviewPageState
    extends State<ThaiPublicEvidenceBadgePreviewPage> {
  ThaiMirrorCanonEvidenceBundle? _bundle;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialBundle != null) {
      _bundle = widget.initialBundle;
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pipeline = widget.pipelineResult ??
          ThaiMirrorPipeline.generate(ThaiMirrorPipeline.sampleQaBirthData());
      final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: widget.repository,
      );
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Evidence Badge Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: 'Reload preview',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    final bundle = _bundle!;
    if (!bundle.pipelineResult.isSuccess) {
      return const Center(child: Text('Pipeline failed — no preview available'));
    }

    final previews = ThaiPublicEvidenceBadgePreviewMapper.fromBundle(bundle);
    final hidden =
        ThaiPublicEvidenceBadgePreviewMapper.hiddenSummaryFromBundle(bundle);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          ThaiPublicEvidenceBadgeCopy.previewHeader,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ThaiPublicEvidenceBadgeCopy.previewPolicyWarning,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _HiddenSummaryCard(hidden: hidden),
        const SizedBox(height: 16),
        Text(
          'Eligible badges (${previews.length})',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (previews.isEmpty)
          const Text('No LEVEL 1 eligible sections for this fixture.')
        else
          ...previews.map((preview) => _EligibleBadgeCard(preview: preview)),
      ],
    );
  }
}

class _HiddenSummaryCard extends StatelessWidget {
  const _HiddenSummaryCard({required this.hidden});

  final ThaiPublicEvidenceBadgeHiddenSummary hidden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blocked / hidden summary (counts only)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _countRow('Hidden remedies', hidden.hiddenRemedies),
            _countRow('Hidden Taksa', hidden.hiddenTaksa),
            _countRow('Hidden Khumsap', hidden.hiddenKhumsap),
            _countRow('Hidden rise/fall', hidden.hiddenRiseFall),
            _countRow('Blocked ambiguous', hidden.blockedAmbiguous),
            _countRow('Blocked source conflict', hidden.blockedSourceConflict),
            _countRow('Out of Canon scope', hidden.outOfCanonScope),
          ],
        ),
      ),
    );
  }

  Widget _countRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: $count'),
    );
  }
}

class _EligibleBadgeCard extends StatelessWidget {
  const _EligibleBadgeCard({required this.preview});

  final ThaiPublicEvidenceBadgePreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Section: ${preview.sectionId}',
                style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Chip(
              label: Text(preview.badgeLabel),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              preview.explanationText,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Source level: LEVEL_1',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
