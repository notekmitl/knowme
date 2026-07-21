import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, Clipboard, ClipboardData, rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart';
import 'package:knowme/features/knowledge_workspace/acquisition/knowledge_acquisition_engine.dart';
import 'package:knowme/features/knowledge_workspace/application/knowledge_workspace_data.dart';

/// Everything the dashboard needs at start: the read-only knowledge (matrix
/// mirror) and the initial research/evidence corpora to acquire into.
class KnowledgeAcquisitionBootstrap {
  const KnowledgeAcquisitionBootstrap({
    required this.knowledge,
    required this.initial,
  });

  final PlanetRelationshipKnowledge knowledge;
  final AcquisitionState initial;

  static Future<KnowledgeAcquisitionBootstrap> loadFromAssets({
    AssetBundle? bundle,
  }) async {
    final b = bundle ?? rootBundle;
    final knowledge =
        await PlanetRelationshipKnowledgeImporter.loadFromAsset(bundle: b);
    final evidenceEngine =
        await KnowledgeEvidenceEngine.loadFromAssets(bundle: b);
    return KnowledgeAcquisitionBootstrap(
      knowledge: knowledge.knowledge,
      initial: AcquisitionState(
        evidence: evidenceEngine.evidence,
        research: evidenceEngine.research,
      ),
    );
  }
}

/// Knowledge Acquisition Dashboard (V6) — `/internal/knowledge/acquire`.
///
/// Admin-only, read/preview/apply workbench for populating the Knowledge
/// Platform via JSON batches. Never modifies the matrix or the engine.
class KnowledgeAcquisitionDashboard extends StatefulWidget {
  const KnowledgeAcquisitionDashboard({super.key, this.bootstrap});

  /// Injectable for tests; defaults to loading from bundled assets.
  final Future<KnowledgeAcquisitionBootstrap>? bootstrap;

  @override
  State<KnowledgeAcquisitionDashboard> createState() =>
      _KnowledgeAcquisitionDashboardState();
}

class _KnowledgeAcquisitionDashboardState
    extends State<KnowledgeAcquisitionDashboard> {
  late final Future<KnowledgeAcquisitionBootstrap> _future =
      widget.bootstrap ?? KnowledgeAcquisitionBootstrap.loadFromAssets();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KnowledgeAcquisitionBootstrap>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Knowledge Acquisition')),
            body: Center(child: Text('Failed to load: ${snapshot.error}')),
          );
        }
        return _AcquisitionView(bootstrap: snapshot.data!);
      },
    );
  }
}

class _AcquisitionView extends StatefulWidget {
  const _AcquisitionView({required this.bootstrap});

  final KnowledgeAcquisitionBootstrap bootstrap;

  @override
  State<_AcquisitionView> createState() => _AcquisitionViewState();
}

class _AcquisitionViewState extends State<_AcquisitionView> {
  late final KnowledgeAcquisitionSession _session =
      KnowledgeAcquisitionSession(initial: widget.bootstrap.initial);
  final TextEditingController _input = TextEditingController();

  late KnowledgeWorkspaceData _data = _rebuildData();
  AcquisitionImportReport? _report;
  String? _reportKind; // 'preview' | 'applied' | 'rolled back'

  KnowledgeWorkspaceData _rebuildData() {
    final state = _session.state;
    final evidenceEngine = KnowledgeEvidenceEngine(
      evidence: state.evidence,
      research: state.research,
    );
    return KnowledgeWorkspaceData.build(
      knowledge: widget.bootstrap.knowledge,
      evidenceEngine: evidenceEngine,
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _report = _session.preview(_input.text);
      _reportKind = 'preview';
    });
  }

  void _apply() {
    final report = _session.apply(_input.text);
    setState(() {
      _report = report;
      _reportKind = report.hasFatalError || report.isNoOp ? 'preview' : 'applied';
      _data = _rebuildData();
    });
  }

  void _rollback() {
    final undone = _session.rollback();
    setState(() {
      _report = undone;
      _reportKind = 'rolled back';
      _data = _rebuildData();
    });
  }

  Future<void> _exportCorpus() async {
    final docs = _session.state.toAssetJson();
    final combined = docs.entries
        .map((e) => '// ${e.key}\n${e.value}')
        .join('\n\n');
    await Clipboard.setData(ClipboardData(text: combined));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merged corpus JSON copied to clipboard'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Acquisition — Internal'),
        actions: [
          IconButton(
            tooltip: 'Copy merged corpus JSON',
            onPressed: _exportCorpus,
            icon: const Icon(Icons.copy_all),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final overview = _OverviewPanel(data: _data);
          final importer = _ImportPanel(
            controller: _input,
            report: _report,
            reportKind: _reportKind,
            canRollback: _session.canRollback,
            onValidate: _validate,
            onApply: _apply,
            onRollback: _rollback,
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SingleChildScrollView(child: overview)),
                const VerticalDivider(width: 1),
                Expanded(child: SingleChildScrollView(child: importer)),
              ],
            );
          }
          return ListView(children: [importer, const Divider(), overview]);
        },
      ),
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.data});

  final KnowledgeWorkspaceData data;

  @override
  Widget build(BuildContext context) {
    final c = data.knowledgeCoverage;
    final supported =
        data.relationships.where((v) => v.research.isNotEmpty).length;
    final coverage =
        c.total == 0 ? 0.0 : supported / c.total * 100;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relationships', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 16, runSpacing: 8, children: [
          _stat('Total', c.total),
          _stat('Verified', c.verified),
          _stat('Candidate', c.candidate),
          _stat('Unknown', c.unknown),
          _stat('Disputed', c.disputed),
        ]),
        const SizedBox(height: 8),
        Text('Coverage (with research): ${coverage.toStringAsFixed(1)}% '
            '($supported / ${c.total})'),
        const Divider(height: 32),
        Text('Detail', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...data.relationships.map((v) => ListTile(
              dense: true,
              title: Text('${v.from} → ${v.to}'),
              subtitle: Text(
                'matrix: ${v.currentMatrix} · status: ${v.knowledgeStatus.name} '
                '· research: ${v.research.length} · evidence: ${v.evidence.length}',
              ),
              trailing: v.hasConflict
                  ? const Icon(Icons.warning_amber, color: Colors.orange)
                  : null,
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => _RelationshipDialog(view: v),
              ),
            )),
      ],
      ),
    );
  }

  Widget _stat(String label, int value) => Chip(label: Text('$label: $value'));
}

class _RelationshipDialog extends StatelessWidget {
  const _RelationshipDialog({required this.view});

  final RelationshipView view;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${view.from} → ${view.to}'),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            _line('Current matrix', view.currentMatrix),
            _line('Knowledge status', view.knowledgeStatus.name),
            _line(
              'Conflicts',
              view.conflict == null
                  ? 'None'
                  : '${view.conflict!.relations.join(', ')} '
                      '(${view.conflict!.recordIds.join(', ')})',
            ),
            const SizedBox(height: 8),
            Text('Research (${view.research.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (view.research.isEmpty) const Text('—'),
            for (final r in view.research)
              Text('• ${r.id} [${r.status.name}] ${r.interpretation}'),
            const SizedBox(height: 8),
            Text('Evidence (${view.evidence.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (view.evidence.isEmpty) const Text('—'),
            for (final e in view.evidence)
              Text('• ${e.id} [${e.reviewStatus.name}] ${e.author}, '
                  '${e.sourceLabel}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('$label: $value'),
      );
}

class _ImportPanel extends StatelessWidget {
  const _ImportPanel({
    required this.controller,
    required this.report,
    required this.reportKind,
    required this.canRollback,
    required this.onValidate,
    required this.onApply,
    required this.onRollback,
  });

  final TextEditingController controller;
  final AcquisitionImportReport? report;
  final String? reportKind;
  final bool canRollback;
  final VoidCallback onValidate;
  final VoidCallback onApply;
  final VoidCallback onRollback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Bulk JSON import',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 10,
            minLines: 6,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste an acquisition batch '
                  '(domain "knowledge_acquisition" with evidence[] / research[])',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            FilledButton.tonalIcon(
              onPressed: onValidate,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Validate / Preview'),
            ),
            FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.save_alt),
              label: const Text('Apply'),
            ),
            OutlinedButton.icon(
              onPressed: canRollback ? onRollback : null,
              icon: const Icon(Icons.undo),
              label: const Text('Rollback'),
            ),
          ]),
          const SizedBox(height: 16),
          if (report != null) _ReportView(report: report!, kind: reportKind),
        ],
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report, required this.kind});

  final AcquisitionImportReport report;
  final String? kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final errored =
        report.outcomes.where((o) => o.outcome == AcquisitionOutcome.error);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Report${kind != null ? ' — $kind' : ''}'
            '${report.batchId != null ? ' [${report.batchId}]' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 12, runSpacing: 4, children: [
            Text('Imported: ${report.imported}'),
            Text('Updated: ${report.updated}'),
            Text('Skipped: ${report.skipped}'),
            Text('Conflicts: ${report.conflictCount}'),
            Text('Errors: ${report.errors + report.fatalErrors.length}'),
          ]),
          if (report.hasFatalError) ...[
            const SizedBox(height: 8),
            for (final e in report.fatalErrors)
              Text('! $e', style: TextStyle(color: scheme.error)),
          ],
          if (errored.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Errors:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (final o in errored)
              Text('• ${o.kind} ${o.id}: ${o.detail}',
                  style: TextStyle(color: scheme.error)),
          ],
          if (report.conflicts.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Conflicts:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (final c in report.conflicts)
              Text('• ${c.pairKey}: ${c.relations.join(' vs ')} '
                  '(${c.recordIds.join(', ')})'),
          ],
        ],
      ),
    );
  }
}
