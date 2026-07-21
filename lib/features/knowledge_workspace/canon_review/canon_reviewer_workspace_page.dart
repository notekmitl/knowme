import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_ingestion.dart';
import 'package:knowme/features/knowledge_workspace/canon_review/canon_reviewer_data.dart';

/// Internal Canon Reviewer Workspace (`/internal/knowledge/canon-review`).
///
/// Read-only review aid for turning "หลักมหาภูต" candidates into Canon-approved
/// knowledge. Shows source text, candidate units, citation, cross references and
/// validation errors together, plus coverage and consistency reports and a
/// pre-approval checklist. It never edits or creates knowledge — extraction and
/// approval happen through the ingestion toolchain / CLI.
class CanonReviewerWorkspacePage extends StatefulWidget {
  const CanonReviewerWorkspacePage({super.key, this.data});

  /// Injectable for tests; defaults to an empty batch (no candidates loaded).
  final CanonReviewerData? data;

  @override
  State<CanonReviewerWorkspacePage> createState() =>
      _CanonReviewerWorkspacePageState();
}

class _CanonReviewerWorkspacePageState
    extends State<CanonReviewerWorkspacePage> {
  late final CanonReviewerData _data = widget.data ?? CanonReviewerData.empty();
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Canon Reviewer — Internal')),
        body: const _EmptyState(),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Canon Reviewer — ${_data.store.bookId}'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Review'),
            Tab(text: 'Coverage'),
            Tab(text: 'Consistency'),
          ]),
        ),
        body: TabBarView(children: [
          _buildReviewTab(context),
          _CoverageTab(report: _data.coverage),
          _ConsistencyTab(report: _data.consistency),
        ]),
      ),
    );
  }

  Widget _buildReviewTab(BuildContext context) {
    final candidates = _data.store.candidates;
    final selected = _selectedId == null ? null : _data.store.byId(_selectedId!);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: ListView.separated(
            itemCount: candidates.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = candidates[i];
              final annotations = _data.review.forCandidate(c.id);
              final blocking = _data.review.hasBlocking(c.id);
              return ListTile(
                selected: c.id == _selectedId,
                dense: true,
                title: Text(c.id, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${c.status.name} · ${c.type?.name ?? 'untyped'} · '
                  '${annotations.length} hint(s)',
                ),
                trailing: blocking
                    ? const Icon(Icons.error, color: Colors.red, size: 18)
                    : annotations.isNotEmpty
                        ? const Icon(Icons.warning_amber,
                            color: Colors.orange, size: 18)
                        : const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                onTap: () => setState(() => _selectedId = c.id),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: selected == null
              ? const Center(child: Text('Select a candidate to review.'))
              : _CandidateDetail(
                  unit: selected,
                  annotations: _data.review.forCandidate(selected.id),
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('No candidate batch loaded',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                'This workspace reviews Candidate Knowledge Units produced by '
                'the ingestion toolchain. There is no canonical content yet '
                'because the source text of "หลักมหาภูต" has not been provided.',
              ),
              SizedBox(height: 12),
              Text('To produce candidates to review:'),
              SizedBox(height: 8),
              SelectableText(
                'dart run tool/canon_ingest.dart extract '
                '<chapter.txt> mahabhut --out mahabhut.candidates.json',
                style: TextStyle(fontFamily: 'monospace'),
              ),
              SizedBox(height: 12),
              Text(
                'Then load that JSON into this workspace to review citations, '
                'cross references and validation errors side by side.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandidateDetail extends StatelessWidget {
  const _CandidateDetail({required this.unit, required this.annotations});

  final CanonCandidateUnit unit;
  final List<CanonReviewAnnotation> annotations;

  @override
  Widget build(BuildContext context) {
    final checklist = CanonReviewChecklist.evaluate(unit);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _section('Source text (verbatim)', [SelectableText(unit.statement)]),
        _section('Knowledge unit', [
          Text('type: ${unit.type?.name ?? '(untyped)'}'),
          Text('topic: ${unit.topic.isEmpty ? '(none)' : unit.topic}'),
          Text('subject: ${unit.subject.isEmpty ? '(none)' : unit.subject}'),
          if (unit.value != null) Text('value: ${unit.value}'),
          Text('status: ${unit.status.name} · confidence: ${unit.confidence.name}'),
        ]),
        _section('Citation', [
          Text('page: ${unit.page ?? '(missing)'}'),
          SelectableText('quote: ${unit.evidenceQuote ?? '(missing)'}'),
          Text('location: ${unit.chapterId ?? '-'} / ${unit.sectionId ?? '-'}'),
        ]),
        _section('Cross references (${unit.crossRefs.length})', [
          if (unit.crossRefs.isEmpty)
            const Text('None')
          else
            for (final x in unit.crossRefs)
              Text('• ${x.type.name} → ${x.toId}${x.note == null ? '' : ' (${x.note})'}'),
        ]),
        _section('Validation hints (${annotations.length})', [
          if (annotations.isEmpty)
            const Text('No issues')
          else
            for (final a in annotations)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_iconFor(a.severity), size: 16, color: _colorFor(a.severity)),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${a.kind.name}: ${a.message}')),
                ],
              ),
        ]),
        _section('Pre-approval checklist', [
          for (final item in CanonReviewChecklist.standard)
            Row(
              children: [
                _checkIcon(checklist[item.id]!),
                const SizedBox(width: 6),
                Expanded(child: Text(item.label)),
                if (!item.auto)
                  const Text('manual',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
        ]),
        if (unit.extractionNotes.isNotEmpty)
          _section('Extraction notes', [
            for (final n in unit.extractionNotes) Text('• $n'),
          ]),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      );

  IconData _iconFor(CanonHighlightSeverity s) => switch (s) {
        CanonHighlightSeverity.error => Icons.error,
        CanonHighlightSeverity.warning => Icons.warning_amber,
        CanonHighlightSeverity.info => Icons.info_outline,
      };

  Color _colorFor(CanonHighlightSeverity s) => switch (s) {
        CanonHighlightSeverity.error => Colors.red,
        CanonHighlightSeverity.warning => Colors.orange,
        CanonHighlightSeverity.info => Colors.blue,
      };

  Widget _checkIcon(CanonChecklistState state) => switch (state) {
        CanonChecklistState.pass =>
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
        CanonChecklistState.fail =>
          const Icon(Icons.cancel, color: Colors.red, size: 16),
        CanonChecklistState.manual =>
          const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 16),
      };
}

class _CoverageTab extends StatelessWidget {
  const _CoverageTab({required this.report});

  final CanonCoverageReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(report.summary),
        const SizedBox(height: 16),
        _bar('Chapter coverage', report.chapterCoverage),
        _bar('Section coverage', report.sectionCoverage),
        _bar('Citation coverage', report.citationCoverage),
        _bar('Validation coverage', report.validationCoverage),
        const SizedBox(height: 8),
        Text('Knowledge density: '
            '${report.knowledgeDensity.toStringAsFixed(2)} units/page'),
        const Divider(height: 24),
        const Text('Per chapter', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final c in report.perChapter)
          ListTile(
            dense: true,
            title: Text(c.chapterId),
            subtitle: Text('${c.approved}/${c.units} approved'),
            trailing: Text('${(c.coverage * 100).toStringAsFixed(0)}%'),
          ),
      ],
    );
  }

  Widget _bar(String label, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label — ${(value * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: value.clamp(0, 1)),
          ],
        ),
      );
}

class _ConsistencyTab extends StatelessWidget {
  const _ConsistencyTab({required this.report});

  final CanonConsistencyReport report;

  @override
  Widget build(BuildContext context) {
    if (report.isClean) {
      return const Center(child: Text('No consistency issues.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in report.countsByCode.entries)
          Text('${entry.key}: ${entry.value}'),
        const Divider(height: 24),
        for (final i in report.issues)
          ListTile(
            dense: true,
            leading: const Icon(Icons.rule, size: 18),
            title: Text(i.message),
            subtitle: Text(i.candidateIds.join(', ')),
          ),
      ],
    );
  }
}
