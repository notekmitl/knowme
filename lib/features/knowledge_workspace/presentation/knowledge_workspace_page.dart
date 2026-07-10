import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/thai/knowledge/evidence/evidence_record.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';
import 'package:knowme/features/knowledge_workspace/application/knowledge_workspace_data.dart';

/// Read-only internal workspace for researchers (`/internal/knowledge`).
///
/// Browses the knowledge / research / evidence layers (V1–V4). No editing.
class KnowledgeWorkspacePage extends StatefulWidget {
  const KnowledgeWorkspacePage({super.key, this.dataFuture});

  /// Injectable for tests; defaults to loading from bundled assets.
  final Future<KnowledgeWorkspaceData>? dataFuture;

  @override
  State<KnowledgeWorkspacePage> createState() => _KnowledgeWorkspacePageState();
}

class _KnowledgeWorkspacePageState extends State<KnowledgeWorkspacePage> {
  late final Future<KnowledgeWorkspaceData> _future =
      widget.dataFuture ?? KnowledgeWorkspaceData.loadFromAssets();

  KnowledgeWorkspaceFilter _filter = const KnowledgeWorkspaceFilter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KnowledgeWorkspaceData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Knowledge Workspace')),
            body: Center(child: Text('Failed to load knowledge: ${snapshot.error}')),
          );
        }
        return _buildLoaded(context, snapshot.data!);
      },
    );
  }

  Widget _buildLoaded(BuildContext context, KnowledgeWorkspaceData data) {
    final relationships = data.filterRelationships(_filter);
    final evidence = data.filterEvidence(_filter);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Knowledge Workspace — Internal'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Relationships'),
              Tab(text: 'Research'),
              Tab(text: 'Evidence'),
            ],
          ),
        ),
        body: Column(
          children: [
            _CoverageBar(coverage: data.knowledgeCoverage),
            _FilterBar(
              data: data,
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _RelationshipsTab(relationships: relationships),
                  _ResearchTab(records: data.research),
                  _EvidenceTab(evidence: evidence),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageBar extends StatelessWidget {
  const _CoverageBar({required this.coverage});

  final PlanetRelationshipCoverageReport coverage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          _stat('Total', coverage.total),
          _stat('Unknown', coverage.unknown),
          _stat('Candidate', coverage.candidate),
          _stat('Verified', coverage.verified),
          _stat('Disputed', coverage.disputed),
          _stat('Friend', coverage.friend),
          _stat('Enemy', coverage.enemy),
          _stat('Neutral', coverage.neutral),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) => Text('$label: $value');
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.data,
    required this.filter,
    required this.onChanged,
  });

  final KnowledgeWorkspaceData data;
  final KnowledgeWorkspaceFilter filter;
  final ValueChanged<KnowledgeWorkspaceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _dropdown('Planet', data.planets, filter.planet,
              (v) => onChanged(filter.copyWith(planet: () => v))),
          _dropdown('Relation', const ['friend', 'neutral', 'enemy'],
              filter.relation,
              (v) => onChanged(filter.copyWith(relation: () => v))),
          _dropdown(
              'Status',
              const ['unknown', 'candidate', 'verified', 'disputed', 'deprecated'],
              filter.status,
              (v) => onChanged(filter.copyWith(status: () => v))),
          _dropdown('School', data.schools, filter.school,
              (v) => onChanged(filter.copyWith(school: () => v))),
          _dropdown('Author', data.authors, filter.author,
              (v) => onChanged(filter.copyWith(author: () => v))),
          _dropdown('Book', data.books, filter.book,
              (v) => onChanged(filter.copyWith(book: () => v))),
          if (!filter.isEmpty)
            TextButton.icon(
              onPressed: () => onChanged(const KnowledgeWorkspaceFilter()),
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Any')),
          for (final o in options)
            DropdownMenuItem<String?>(value: o, child: Text(o)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _RelationshipsTab extends StatelessWidget {
  const _RelationshipsTab({required this.relationships});

  final List<RelationshipView> relationships;

  @override
  Widget build(BuildContext context) {
    if (relationships.isEmpty) {
      return const Center(child: Text('No relationships match the filter.'));
    }
    return ListView.separated(
      itemCount: relationships.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final v = relationships[i];
        return ListTile(
          title: Text('${v.from} → ${v.to}'),
          subtitle: Text(
            'matrix: ${v.currentMatrix} · status: ${v.knowledgeStatus.name} · '
            'research: ${v.research.length} · evidence: ${v.evidence.length}',
          ),
          trailing: v.hasConflict
              ? const Icon(Icons.warning_amber, color: Colors.orange)
              : const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _RelationshipDetailPage(view: v),
            ),
          ),
        );
      },
    );
  }
}

class _RelationshipDetailPage extends StatelessWidget {
  const _RelationshipDetailPage({required this.view});

  final RelationshipView view;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${view.from} → ${view.to}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Current matrix', [Text(view.currentMatrix)]),
          _section('Knowledge status', [Text(view.knowledgeStatus.name)]),
          _section('Conflicts', [
            if (view.conflict == null)
              const Text('None')
            else
              Text(
                'Disagreement: ${view.conflict!.relations.join(', ')} '
                '(records: ${view.conflict!.recordIds.join(', ')})',
              ),
          ]),
          _section('Research records (${view.research.length})', [
            if (view.research.isEmpty)
              const Text('No research yet')
            else
              for (final r in view.research) _researchTile(r),
          ]),
          _section('Evidence (${view.evidence.length})', [
            if (view.evidence.isEmpty)
              const Text('No evidence yet')
            else
              for (final e in view.evidence) _evidenceTile(e),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      );

  Widget _researchTile(KnowledgeResearchRecord r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '• ${r.id} [${r.status.name}/${r.confidence.name}] — '
          '${r.interpretation}',
        ),
      );

  Widget _evidenceTile(EvidenceRecord e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '• ${e.id} [${e.reviewStatus.name}] — ${e.author}, ${e.sourceLabel} '
          '(${e.school})',
        ),
      );
}

class _ResearchTab extends StatelessWidget {
  const _ResearchTab({required this.records});

  final List<KnowledgeResearchRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('No research records yet.'));
    }
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final r = records[i];
        return ListTile(
          title: Text('${r.id} — ${r.entity}'),
          subtitle: Text(
            '${r.status.name} · ${r.relationship.length} relationship(s) · '
            'evidence: ${r.evidenceIds.length}',
          ),
        );
      },
    );
  }
}

class _EvidenceTab extends StatelessWidget {
  const _EvidenceTab({required this.evidence});

  final List<EvidenceRecord> evidence;

  @override
  Widget build(BuildContext context) {
    if (evidence.isEmpty) {
      return const Center(child: Text('No evidence records yet.'));
    }
    return ListView.separated(
      itemCount: evidence.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final e = evidence[i];
        return ListTile(
          title: Text('${e.id} — ${e.sourceLabel}'),
          subtitle: Text(
            '${e.author} · ${e.school} · ${e.reviewStatus.name}',
          ),
        );
      },
    );
  }
}

