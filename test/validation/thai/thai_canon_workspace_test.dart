import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/workspace.dart';

/// Canon Knowledge Extraction Workspace V4. The workspace is the only supported
/// path to add Canon knowledge. Pure knowledge layer — no engine/runtime/matrix/
/// mirror/fusion dependency.

AtomicKnowledgeUnit _unit(
  String id,
  String subject,
  AtomicRelation rel,
  String object, {
  AtomicEntityKind subjectKind = AtomicEntityKind.planet,
  AtomicEntityKind objectKind = AtomicEntityKind.domain,
  KnowledgeDomain domain = KnowledgeDomain.planetLibrary,
  KnowledgeConfidence confidence = KnowledgeConfidence.high,
  AtomicStrength strength = AtomicStrength.high,
  AtomicEvidenceRef? evidence,
}) =>
    AtomicKnowledgeUnit(
      id: id,
      subject: subject,
      subjectKind: subjectKind,
      relation: rel,
      object: object,
      objectKind: objectKind,
      domain: domain,
      confidence: confidence,
      strength: strength,
      evidence: evidence ??
          const AtomicEvidenceRef(bookId: 'mahabhut', chapter: '1', page: '12'),
    );

const _source = ExtractionSource(
  bookId: 'mahabhut',
  edition: '1',
  chapter: '1',
  pageStart: 10,
  pageEnd: 14,
  reviewer: 'reviewer.a',
  extractionDate: '2026-06-29',
  pagesPlanned: 5,
  pagesDone: 5,
);

KnowledgeExtractionSession _session(List<AtomicKnowledgeUnit> units) =>
    KnowledgeExtractionSession(id: 'sess-1', source: _source, units: units);

final _ontology = CanonOntologyData.standard();

void main() {
  group('Session lifecycle', () {
    test('happy path is deterministic and complete', () {
      final s = _session([_unit('u1', 'jupiter', AtomicRelation.owns, 'wealth')]);
      const path = [
        SessionState.extracting,
        SessionState.validated,
        SessionState.reviewed,
        SessionState.approved,
        SessionState.imported,
        SessionState.archived,
      ];
      for (final target in path) {
        final t = s.transitionTo(target);
        expect(t.ok, isTrue, reason: 't ${t.from}→${t.to}: ${t.reason}');
        expect(s.state, target);
      }
    });

    test('illegal transitions are rejected deterministically', () {
      final s = _session([]);
      final t = s.transitionTo(SessionState.imported);
      expect(t.ok, isFalse);
      expect(s.state, SessionState.draft);
      // Same attempt always rejected the same way.
      final t2 = _session([]).transitionTo(SessionState.imported);
      expect(t2.ok, t.ok);
      expect(t2.reason, t.reason);
    });

    test('archive is reachable from non-terminal states', () {
      final s = _session([]);
      expect(s.transitionTo(SessionState.archived).ok, isTrue);
      expect(s.transitionTo(SessionState.draft).ok, isFalse);
    });
  });

  group('Workspace validator catches every failure class', () {
    test('clean session validates', () {
      final report = WorkspaceValidator.validate(
          _session([_unit('u1', 'jupiter', AtomicRelation.owns, 'wealth')]),
          _ontology);
      expect(report.isValid, isTrue, reason: report.issues.join('\n'));
    });

    test('each failure class is detected', () {
      final units = [
        // non-atomic object → atomicity
        _unit('bad1', 'jupiter', AtomicRelation.produces,
            'usually brings financial success'),
        // unknown subject + object → ontology unresolved
        _unit('bad2', 'nibiru', AtomicRelation.owns, 'zorblax',
            objectKind: AtomicEntityKind.other),
        // missing evidence reference
        _unit('bad3', 'mars', AtomicRelation.owns, 'health',
            evidence: const AtomicEvidenceRef(bookId: 'mahabhut')),
        // duplicate knowledge (same fact, different ids)
        _unit('dup1', 'sun', AtomicRelation.owns, 'health'),
        _unit('dup2', 'sun', AtomicRelation.owns, 'health'),
        // graph contradiction supports/opposes mars↔venus
        _unit('c1', 'mars', AtomicRelation.supports, 'venus',
            objectKind: AtomicEntityKind.planet),
        _unit('c2', 'mars', AtomicRelation.opposes, 'venus',
            objectKind: AtomicEntityKind.planet),
      ];
      final report = WorkspaceValidator.validate(_session(units), _ontology);
      expect(report.hasCode('atomicity_non_atomic_object'), isTrue);
      expect(report.hasCode('ontology_unresolved_subject'), isTrue);
      expect(report.hasCode('ontology_unresolved_object'), isTrue);
      expect(report.hasCode('missing_evidence_reference'), isTrue);
      expect(report.hasCode('duplicate_knowledge'), isTrue);
      expect(report.hasCode('graph_contradiction'), isTrue);
      expect(report.isValid, isFalse);
    });

    test('relationship registration is enforced via ontology', () {
      // Every relation the graph can express must be registered already.
      expect(_ontology.unregisteredRelationships(
              AtomicRelation.values.map((r) => r.wire)),
          isEmpty);
    });

    test('baseline conflict (opposes vs canon supports) is flagged', () {
      final baseline = [
        _unit('b1', 'mars', AtomicRelation.supports, 'venus',
            objectKind: AtomicEntityKind.planet),
      ];
      final report = WorkspaceValidator.validate(
        _session([
          _unit('s1', 'mars', AtomicRelation.opposes, 'venus',
              objectKind: AtomicEntityKind.planet),
        ]),
        _ontology,
        baseline: baseline,
      );
      expect(report.hasCode('graph_baseline_conflict'), isTrue);
    });

    test('validation report is deterministic', () {
      final units = [_unit('u1', 'jupiter', AtomicRelation.owns, 'wealth')];
      final a = WorkspaceValidator.validate(_session(units), _ontology);
      final b = WorkspaceValidator.validate(_session(units), _ontology);
      expect(a.issues.map((i) => i.signature).toList(),
          b.issues.map((i) => i.signature).toList());
    });
  });

  group('Knowledge diff', () {
    final baseline = [
      _unit('keep', 'jupiter', AtomicRelation.owns, 'wealth'),
      _unit('change', 'sun', AtomicRelation.owns, 'authority',
          confidence: KnowledgeConfidence.medium),
      _unit('flip', 'mars', AtomicRelation.supports, 'venus',
          objectKind: AtomicEntityKind.planet),
      _unit('gone', 'saturn', AtomicRelation.owns, 'discipline'),
    ];

    test('classifies NEW/UPDATED/UNCHANGED/CONFLICT/DEPRECATED', () {
      final incoming = [
        _unit('keep', 'jupiter', AtomicRelation.owns, 'wealth'), // UNCHANGED
        _unit('change', 'sun', AtomicRelation.owns, 'authority',
            confidence: KnowledgeConfidence.high), // UPDATED (qualifier)
        _unit('flip', 'mars', AtomicRelation.opposes, 'venus',
            objectKind: AtomicEntityKind.planet), // CONFLICT (fact changed)
        _unit('new1', 'moon', AtomicRelation.owns, 'family',
            domain: KnowledgeDomain.houseLibrary), // NEW
        // 'gone' absent → DEPRECATED
      ];
      final diff =
          KnowledgeDiff.compute(baseline: baseline, incoming: incoming);
      expect(diff.count(DiffKind.unchanged), 1);
      expect(diff.count(DiffKind.updated), 1);
      expect(diff.count(DiffKind.conflict), 1);
      expect(diff.count(DiffKind.added), 1);
      expect(diff.count(DiffKind.deprecated), 1);
      expect(diff.hasConflict, isTrue);
    });

    test('is deterministic', () {
      final incoming = [_unit('new1', 'moon', AtomicRelation.owns, 'family')];
      final a = KnowledgeDiff.compute(baseline: baseline, incoming: incoming);
      final b = KnowledgeDiff.compute(baseline: baseline, incoming: incoming);
      expect(a.entries.map((e) => e.signature).toList(),
          b.entries.map((e) => e.signature).toList());
    });
  });

  group('Completeness delta', () {
    test('is deterministic and reflects new verified knowledge', () {
      final baseline = [_unit('b1', 'jupiter', AtomicRelation.owns, 'wealth')];
      final incoming = [
        _unit('b1', 'jupiter', AtomicRelation.owns, 'wealth'),
        _unit('r1', 'jupiter', AtomicRelation.supports, 'sun',
            objectKind: AtomicEntityKind.planet,
            domain: KnowledgeDomain.planetRelationships),
      ];
      final diff =
          KnowledgeDiff.compute(baseline: baseline, incoming: incoming);
      final d1 = CompletenessDelta.forImport(
          baseline: baseline, incoming: incoming, diff: diff);
      final d2 = CompletenessDelta.forImport(
          baseline: baseline, incoming: incoming, diff: diff);
      expect(d1.summary, d2.summary);
      expect(d1.totalUnitsDelta, 1);
      expect(d1.verifiedRelationshipsDelta, 1);
      expect(d1.unknownRelationshipsDelta, -1);
      expect(d1.coverageIncreased, isTrue);
    });

    test('conflicts are not applied to coverage', () {
      final baseline = [
        _unit('flip', 'mars', AtomicRelation.supports, 'venus',
            objectKind: AtomicEntityKind.planet,
            domain: KnowledgeDomain.planetRelationships),
      ];
      final incoming = [
        _unit('flip', 'mars', AtomicRelation.opposes, 'venus',
            objectKind: AtomicEntityKind.planet,
            domain: KnowledgeDomain.planetRelationships),
      ];
      final diff =
          KnowledgeDiff.compute(baseline: baseline, incoming: incoming);
      final delta = CompletenessDelta.forImport(
          baseline: baseline, incoming: incoming, diff: diff);
      expect(diff.hasConflict, isTrue);
      expect(delta.totalUnitsDelta, 0); // conflict not applied
    });
  });

  group('Review report', () {
    test('is deterministic and gates import on validation + conflicts', () {
      final session =
          _session([_unit('u1', 'jupiter', AtomicRelation.owns, 'wealth')]);
      final r1 = ReviewReport.build(session, _ontology);
      final r2 = ReviewReport.build(session, _ontology);
      expect(r1.render(), r2.render());
      expect(r1.readyForImport, isTrue);

      final conflicting = _session([
        _unit('bad', 'nibiru', AtomicRelation.owns, 'zorblax',
            objectKind: AtomicEntityKind.other),
      ]);
      final r3 = ReviewReport.build(conflicting, _ontology);
      expect(r3.readyForImport, isFalse);
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('workspace imports no engine/runtime/matrix/mirror/fusion/flutter', () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/workspace');
      for (final f in dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final imports = f
            .readAsLinesSync()
            .where((l) => l.trimLeft().startsWith('import '))
            .join('\n');
        for (final forbidden in const [
          'package:flutter/',
          'planet_relationship_matrix',
          'core/life_period',
          '/runtime/',
          '/mirror/',
          '/fusion/',
          '/narrative',
        ]) {
          expect(imports.contains(forbidden), isFalse,
              reason: '${f.path} must not import $forbidden');
        }
      }
    });
  });
}
