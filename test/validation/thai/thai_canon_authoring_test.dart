import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/authoring/authoring.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/workspace.dart';

/// Canon Knowledge Authoring Studio V1 — the human editing layer before the
/// Workspace. Pure knowledge layer; no engine/runtime/matrix/mirror/fusion.

final _ontology = CanonOntologyData.standard();

const _source = ExtractionSource(
  bookId: 'mahabhut',
  edition: '1',
  chapter: '2',
  pageStart: 40,
  pageEnd: 41,
  reviewer: 'reviewer.a',
  extractionDate: '2026-06-29',
);

AuthoringStudio _studio() => AuthoringStudio(id: 'studio-1', source: _source);

void main() {
  group('Authoring + ontology assistance', () {
    test('drafts seed page provenance and resolve against the ontology', () {
      final s = _studio();
      s.addDraft(
        subject: 'planet.jupiter',
        object: 'domain.finance',
        edit: (d) {
          d.subjectKind = AtomicEntityKind.planet;
          d.objectKind = AtomicEntityKind.domain;
          d.relation = AtomicRelation.owns;
          d.confidence = KnowledgeConfidence.high;
        },
      );
      expect(s.drafts.single.evidence.bookId, 'mahabhut');
      expect(s.drafts.single.evidence.page, '40');
      expect(s.allResolved(_ontology), isTrue);
    });

    test('ontology assist distinguishes resolved / missing / unknown', () {
      final s = _studio();
      s.addDraft(subject: 'planet.jupiter', object: 'meaning.wisdom'); // missing
      s.addDraft(subject: 'Guru', object: 'nonsensetoken'); // alias / unknown
      final assists = s.assist(_ontology);
      expect(assists[0].subject.resolution, EntityResolution.resolved);
      expect(assists[0].object.resolution, EntityResolution.missingOntology);
      expect(assists[1].subject.resolution, EntityResolution.resolved); // Guru
      expect(assists[1].object.resolution, EntityResolution.unknown);
      expect(s.allResolved(_ontology), isFalse);
    });

    test('ontology resolution is deterministic', () {
      final a = _studio()..addDraft(subject: 'Jupiter', object: 'Wealth');
      final b = _studio()..addDraft(subject: 'Jupiter', object: 'Wealth');
      final ra = a.assist(_ontology).single;
      final rb = b.assist(_ontology).single;
      expect(ra.subject.entityId, rb.subject.entityId);
      expect(ra.object.entityId, rb.object.entityId);
      expect(ra.subject.entityId, 'planet.jupiter');
      expect(ra.object.entityId, 'domain.finance');
    });
  });

  group('Batch editing preserves atomicity', () {
    AuthoringStudio seeded() {
      final s = _studio();
      s.addDraft(
        subject: 'planet.jupiter',
        object: 'domain.finance',
        edit: (d) {
          d.objectKind = AtomicEntityKind.domain;
          d.relation = AtomicRelation.owns;
          d.confidence = KnowledgeConfidence.high;
        },
      );
      return s;
    }

    test('split produces one atomic draft per object', () {
      final s = seeded();
      final id = s.drafts.single.id;
      final r = s.split(id, ['domain.finance', 'domain.career', 'domain.health']);
      expect(r.ok, isTrue);
      expect(s.drafts.length, 3);
      expect(s.drafts.map((d) => d.object),
          ['domain.finance', 'domain.career', 'domain.health']);
      // Each remains atomic (one subject/relation/object).
      for (final u in s.toAtomicUnits()) {
        expect(AtomicExtractionRules.isAtomic(u), isTrue);
      }
    });

    test('duplicate inserts a copy with a fresh id right after', () {
      final s = seeded();
      final id = s.drafts.single.id;
      expect(s.duplicate(id).ok, isTrue);
      expect(s.drafts.length, 2);
      expect(s.drafts[0].id, isNot(s.drafts[1].id));
      expect(s.drafts[1].factKey, s.drafts[0].factKey);
    });

    test('merge collapses same-fact drafts and rejects different facts', () {
      final s = seeded();
      final id = s.drafts.single.id;
      s.duplicate(id);
      // Strengthen the copy then merge — keeps strongest confidence.
      s.drafts[1].confidence = KnowledgeConfidence.high;
      final ok = s.merge([s.drafts[0].id, s.drafts[1].id]);
      expect(ok.ok, isTrue);
      expect(s.drafts.length, 1);

      // Different facts cannot be merged.
      s.addDraft(subject: 'planet.sun', object: 'domain.career', edit: (d) {
        d.objectKind = AtomicEntityKind.domain;
        d.relation = AtomicRelation.owns;
      });
      final bad = s.merge([s.drafts[0].id, s.drafts[1].id]);
      expect(bad.ok, isFalse);
    });

    test('reorder and delete are bounds-checked', () {
      final s = seeded();
      s.addDraft(subject: 'planet.sun', object: 'domain.career');
      expect(s.reorder(0, 1).ok, isTrue);
      expect(s.reorder(0, 9).ok, isFalse);
      final firstId = s.drafts.first.id;
      expect(s.delete(firstId).ok, isTrue);
      expect(s.delete('missing').ok, isFalse);
    });
  });

  group('Validation preview matches the Workspace exactly', () {
    test('studio.validate equals WorkspaceValidator on the same session', () {
      final s = _studio();
      s.addDraft(subject: 'planet.jupiter', object: 'domain.finance', edit: (d) {
        d.objectKind = AtomicEntityKind.domain;
        d.relation = AtomicRelation.owns;
        d.confidence = KnowledgeConfidence.high;
      });
      s.addDraft(subject: 'nibiru', object: 'zorblax'); // unresolved

      final preview = s.validate(_ontology);
      final direct = WorkspaceValidator.validate(s.toSession(), _ontology);
      expect(preview.issues.map((i) => i.signature).toList(),
          direct.issues.map((i) => i.signature).toList());
      // The same failure classes the Workspace would catch.
      expect(preview.hasCode('ontology_unresolved_subject'), isTrue);
      expect(preview.hasCode('ontology_unresolved_object'), isTrue);
    });

    test('preview ReviewReport is deterministic', () {
      final s = _studio()
        ..addDraft(subject: 'planet.jupiter', object: 'domain.finance', edit: (d) {
          d.objectKind = AtomicEntityKind.domain;
          d.relation = AtomicRelation.owns;
          d.confidence = KnowledgeConfidence.high;
        });
      expect(s.preview(_ontology).render(), s.preview(_ontology).render());
    });
  });

  group('Export / import reproduces the identical draft', () {
    test('round-trip preserves ids, order, seq and all fields', () {
      final s = _studio();
      s.addDraft(subject: 'planet.jupiter', object: 'domain.finance', edit: (d) {
        d.objectKind = AtomicEntityKind.domain;
        d.relation = AtomicRelation.owns;
        d.confidence = KnowledgeConfidence.high;
        d.condition = 'jupiter_in_house_2';
      });
      s.addDraft(subject: 'planet.sun', object: 'domain.career');
      s.split(s.drafts.first.id, ['domain.finance', 'domain.learning']);

      final json = s.toJson();
      final back = AuthoringStudio.fromJson(json);
      expect(back.toJson(), json);
      expect(back.seq, s.seq);
      expect(back.drafts.map((d) => d.id).toList(),
          s.drafts.map((d) => d.id).toList());

      // Continuing to edit after import yields the same next id.
      final a = AuthoringStudio.fromJson(json)..addDraft(subject: 'planet.mars');
      final b = AuthoringStudio.fromJson(json)..addDraft(subject: 'planet.mars');
      expect(a.drafts.last.id, b.drafts.last.id);
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('authoring imports no engine/runtime/matrix/mirror/fusion/flutter', () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/authoring');
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
