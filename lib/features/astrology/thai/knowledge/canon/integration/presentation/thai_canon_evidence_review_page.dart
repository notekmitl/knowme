import 'package:flutter/material.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import '../integration.dart';
import 'thai_canon_evidence_review_summary.dart';

/// Internal QA panel — inspect Canon evidence attached to a Thai Mirror report.
///
/// Route: `/internal/thai-canon-evidence` (admin-guarded). Never linked from
/// consumer surfaces.
class ThaiCanonEvidenceReviewPage extends StatefulWidget {
  const ThaiCanonEvidenceReviewPage({
    super.key,
    this.pipelineResult,
    this.initialBundle,
    this.repository,
  });

  /// When null, runs [ThaiMirrorPipeline.sampleQaBirthData] on load.
  final ThaiMirrorPipelineResult? pipelineResult;

  /// Optional pre-built bundle (tests).
  final ThaiMirrorCanonEvidenceBundle? initialBundle;

  final ThaiCanonEvidenceRepository? repository;

  @override
  State<ThaiCanonEvidenceReviewPage> createState() =>
      _ThaiCanonEvidenceReviewPageState();
}

class _ThaiCanonEvidenceReviewPageState extends State<ThaiCanonEvidenceReviewPage> {
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
        title: const Text('Thai Canon Evidence Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: 'Reload evidence',
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
      return const Center(child: Text('Pipeline failed — no evidence to show'));
    }

    final summary = ThaiCanonEvidenceReviewSummary.fromBundle(bundle);
    final rows = flattenEvidenceRows(bundle);
    final profile = bundle.pipelineResult.profile!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Internal QA — Canon evidence metadata only. Not user-facing.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 12),
        _HeaderCard(
          lagnaKey: profile.lagnaKey ?? '—',
          lagnaLordKey: profile.lagnaLordKey ?? '—',
          mahabhutaKeys: profile.mahabhutaPositionKeys.join(', '),
          summary: summary,
        ),
        const SizedBox(height: 16),
        _CoverageCards(summary: summary),
        const SizedBox(height: 16),
        Text('Evidence table (${rows.length} refs)',
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        const _EvidenceTableHeader(),
        ...rows.map((row) => _EvidenceTableRow(row: row)),
        const SizedBox(height: 24),
        _TracePanel(trace: bundle.trace),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.lagnaKey,
    required this.lagnaLordKey,
    required this.mahabhutaKeys,
    required this.summary,
  });

  final String lagnaKey;
  final String lagnaLordKey;
  final String mahabhutaKeys;
  final ThaiCanonEvidenceReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sample profile summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Lagna: $lagnaKey · Lord: $lagnaLordKey'),
            Text('Mahabhuta keys: $mahabhutaKeys'),
            const SizedBox(height: 12),
            Text(
              'Attachments: ${summary.totalAttachments} · '
              'Refs: ${summary.totalEvidenceRefs}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageCards extends StatelessWidget {
  const _CoverageCards({required this.summary});

  final ThaiCanonEvidenceReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _CoverageChip(
          label: 'Mahabhut',
          value: '${summary.byType[ThaiCanonEvidenceType.mahabhutPosition] ?? 0}',
        ),
        _CoverageChip(
          label: 'Planet/domain',
          value: '${summary.byType[ThaiCanonEvidenceType.planetSignification] ?? 0}',
        ),
        _CoverageChip(
          label: 'Life Period',
          value: '${summary.lifePeriodAttachmentCount}',
        ),
        _CoverageChip(
          label: 'Prediction rules',
          value: '${summary.predictionRuleAttachmentCount}',
        ),
        _CoverageChip(
          label: 'Remedy skipped',
          value: '${summary.remedySkippedCount}',
          highlight: true,
        ),
        _CoverageChip(
          label: 'Taksa skipped',
          value: '${summary.taksaSkippedCount}',
        ),
        _CoverageChip(
          label: 'Unmapped candidates',
          value: '${summary.unmappedCandidateCount}',
        ),
        _CoverageChip(
          label: 'Signals w/o evidence',
          value: '${summary.signalsWithoutEvidenceCount}',
        ),
      ],
    );
  }
}

class _CoverageChip extends StatelessWidget {
  const _CoverageChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: highlight
          ? Icon(Icons.lock_outline, size: 16, color: scheme.error)
          : null,
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EvidenceTableHeader extends StatelessWidget {
  const _EvidenceTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _Cell(flex: 2, text: 'Section', style: style),
          _Cell(flex: 3, text: 'Signal', style: style),
          _Cell(flex: 2, text: 'Type', style: style),
          _Cell(flex: 2, text: 'Subject', style: style),
          _Cell(flex: 2, text: 'Relation', style: style),
          _Cell(flex: 2, text: 'Object', style: style),
          _Cell(flex: 2, text: 'Context', style: style),
          _Cell(flex: 1, text: 'Page', style: style),
          _Cell(flex: 1, text: 'UF', style: style),
        ],
      ),
    );
  }
}

class _EvidenceTableRow extends StatelessWidget {
  const _EvidenceTableRow({required this.row});

  final ThaiCanonEvidenceReviewRow row;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Cell(flex: 2, text: row.sectionId, style: style),
          _Cell(flex: 3, text: row.signalId, style: style),
          _Cell(flex: 2, text: row.evidenceType.name, style: style),
          _Cell(flex: 2, text: row.subject, style: style),
          _Cell(flex: 2, text: row.relation, style: style),
          _Cell(flex: 2, text: row.object, style: style),
          _Cell(flex: 2, text: row.contextLabel, style: style),
          _Cell(flex: 1, text: row.sourcePage, style: style),
          _Cell(
            flex: 1,
            text: row.userFacingAllowed ? 'yes' : 'no',
            style: style,
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.flex, required this.text, this.style});

  final int flex;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );
  }
}

class _TracePanel extends StatelessWidget {
  const _TracePanel({required this.trace});

  final ThaiCanonEvidenceTrace trace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trace / skipped evidence', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Remedy evidence skipped (internal count only — not advice): '
              '${trace.skippedRemedyEvidenceCount}',
            ),
            Text('Taksa evidence skipped (count): '
                '${trace.skippedTaksaEvidenceCount}'),
            const SizedBox(height: 8),
            Text('periodStatus notes:', style: theme.textTheme.labelLarge),
            for (final note in trace.skippedPeriodStatusNotes)
              Text('• $note', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              'In-scope unmapped signals '
              '(${trace.inCanonScopeUnmappedSignals.length}):',
              style: theme.textTheme.labelLarge,
            ),
            for (final s in trace.inCanonScopeUnmappedSignals.take(20))
              Text('• $s', style: theme.textTheme.bodySmall),
            if (trace.inCanonScopeUnmappedSignals.length > 20)
              Text(
                '… +${trace.inCanonScopeUnmappedSignals.length - 20} more',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Text(
              'Out of Canon scope '
              '(${trace.outOfCanonScopeSignals.length}):',
              style: theme.textTheme.labelLarge,
            ),
            for (final s in trace.outOfCanonScopeSignals.take(15))
              Text('• $s', style: theme.textTheme.bodySmall),
            if (trace.outOfCanonScopeSignals.length > 15)
              Text(
                '… +${trace.outOfCanonScopeSignals.length - 15} more',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Text(
              'Trace-only candidates '
              '(${trace.traceOnlyEvidenceCandidates.length}):',
              style: theme.textTheme.labelLarge,
            ),
            for (final s in trace.traceOnlyEvidenceCandidates)
              Text('• $s', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              'Signals without Canon evidence (legacy alias) '
              '(${trace.signalsWithoutCanonEvidence.length}):',
              style: theme.textTheme.labelLarge,
            ),
            for (final s in trace.signalsWithoutCanonEvidence.take(10))
              Text('• $s', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              'Unmapped Canon candidates '
              '(${trace.unmappedCanonEvidenceCandidates.length}):',
              style: theme.textTheme.labelLarge,
            ),
            for (final id in trace.unmappedCanonEvidenceCandidates.take(15))
              Text('• $id', style: theme.textTheme.bodySmall),
            if (trace.unmappedCanonEvidenceCandidates.length > 15)
              Text(
                '… +${trace.unmappedCanonEvidenceCandidates.length - 15} more',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
