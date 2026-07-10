import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart';
import 'package:knowme/features/knowledge_workspace/acquisition/knowledge_acquisition_dashboard.dart';
import 'package:knowme/features/knowledge_workspace/acquisition/knowledge_acquisition_engine.dart';
import 'package:knowme/features/knowledge_workspace/knowledge_workspace_routes.dart';

/// Thai Astrology Knowledge Acquisition V6.
///
/// Validate → preview → apply → rollback of JSON batches, with Import Reports
/// (imported / updated / skipped / conflicts / errors). Never touches the
/// matrix.

AcquisitionState _base() {
  final engine = KnowledgeEvidenceEngine.load(
    evidenceJson: '''
    { "domain": "knowledge_evidence", "records": [
      { "id": "EV-0001", "sourceType": "book", "school": "thaiTraditional",
        "author": "A", "book": "B", "language": "th", "reviewStatus": "verified" }
    ]}''',
    researchJson: '''
    { "domain": "knowledge_research", "records": [
      { "id": "RR-0001", "topic": "t", "entity": "Saturn-Venus",
        "interpretation": "friends",
        "relationship": [{ "from": "saturn", "to": "venus", "relation": "friend" }],
        "evidenceIds": ["EV-0001"], "confidence": "high", "status": "verified" }
    ]}''',
  );
  return AcquisitionState(
    evidence: engine.evidence,
    research: engine.research,
  );
}

void main() {
  group('KnowledgeAcquisitionEngine — classification', () {
    test('imported / updated / skipped', () {
      const batch = '''
      {
        "domain": "knowledge_acquisition",
        "batchId": "BATCH-1",
        "evidence": [
          { "id": "EV-0002", "sourceType": "book", "school": "vedic",
            "author": "C", "book": "D", "language": "en", "reviewStatus": "draft" },
          { "id": "EV-0001", "sourceType": "book", "school": "thaiTraditional",
            "author": "A", "book": "B", "language": "th", "reviewStatus": "verified" }
        ],
        "research": [
          { "id": "RR-0001", "topic": "t", "entity": "Saturn-Venus",
            "interpretation": "CHANGED",
            "relationship": [{ "from": "saturn", "to": "venus", "relation": "friend" }],
            "evidenceIds": ["EV-0001"], "confidence": "high", "status": "verified" }
        ]
      }''';
      final r = KnowledgeAcquisitionEngine.preview(_base(), batch);
      expect(r.batchId, 'BATCH-1');
      expect(r.imported, 1); // EV-0002
      expect(r.skipped, 1); // EV-0001 identical
      expect(r.updated, 1); // RR-0001 interpretation changed
      expect(r.errors, 0);
      expect(r.hasFatalError, isFalse);
      // Result state has the new evidence + updated research.
      expect(r.resultState.evidence.length, 2);
      expect(
        r.resultState.research.firstWhere((x) => x.id == 'RR-0001').interpretation,
        'CHANGED',
      );
    });

    test('errors: validation_failed, duplicate_in_batch, invalid_relation, broken_link', () {
      const batch = '''
      {
        "domain": "knowledge_acquisition",
        "evidence": [
          { "id": "EV-BAD", "sourceType": "book", "school": "vedic",
            "book": "no author", "language": "en", "reviewStatus": "draft" },
          { "id": "EV-0002", "sourceType": "book", "school": "vedic",
            "author": "C", "book": "D", "language": "en", "reviewStatus": "draft" },
          { "id": "EV-0002", "sourceType": "book", "school": "vedic",
            "author": "C", "book": "D", "language": "en", "reviewStatus": "draft" }
        ],
        "research": [
          { "id": "RR-REL", "topic": "t", "entity": "x", "interpretation": "i",
            "relationship": [{ "from": "saturn", "to": "venus", "relation": "lover" }],
            "evidenceIds": ["EV-0002"], "confidence": "low", "status": "draft" },
          { "id": "RR-LINK", "topic": "t", "entity": "x", "interpretation": "i",
            "relationship": [{ "from": "sun", "to": "moon", "relation": "friend" }],
            "evidenceIds": ["EV-NOPE"], "confidence": "low", "status": "draft" }
        ]
      }''';
      final r = KnowledgeAcquisitionEngine.preview(_base(), batch);
      final details = r.outcomes
          .where((o) => o.outcome == AcquisitionOutcome.error)
          .map((o) => o.detail!)
          .toList();
      expect(details.any((d) => d == 'validation_failed'), isTrue); // EV-BAD
      expect(details.any((d) => d == 'duplicate_in_batch'), isTrue); // EV-0002 x2
      expect(details.any((d) => d.startsWith('invalid_relation')), isTrue);
      expect(details.any((d) => d.startsWith('broken_link')), isTrue);
      // Only the first EV-0002 imports; the rest error out.
      expect(r.imported, 1);
    });

    test('conflicts are detected for touched pairs', () {
      const batch = '''
      {
        "domain": "knowledge_acquisition",
        "research": [
          { "id": "RR-0002", "topic": "t", "entity": "Saturn-Venus",
            "interpretation": "enemies",
            "relationship": [{ "from": "saturn", "to": "venus", "relation": "enemy" }],
            "evidenceIds": ["EV-0001"], "confidence": "low", "status": "candidate" }
        ]
      }''';
      final r = KnowledgeAcquisitionEngine.preview(_base(), batch);
      expect(r.imported, 1);
      expect(r.conflictCount, 1);
      final c = r.conflicts.single;
      expect(c.pairKey, 'saturn->venus');
      expect(c.relations, containsAll(<String>{'friend', 'enemy'}));
      // The imported record is flagged as conflicting.
      expect(
        r.outcomes.firstWhere((o) => o.id == 'RR-0002').conflict,
        isTrue,
      );
    });

    test('malformed JSON / wrong shape is a fatal error (nothing imported)', () {
      final bad = KnowledgeAcquisitionEngine.preview(_base(), 'not json');
      expect(bad.hasFatalError, isTrue);
      expect(bad.imported, 0);
      expect(bad.resultState.evidence.length, 1); // unchanged

      final wrong = KnowledgeAcquisitionEngine.preview(_base(), '[]');
      expect(wrong.hasFatalError, isTrue);
    });
  });

  group('KnowledgeAcquisitionSession — apply / rollback', () {
    test('apply advances state; rollback restores it', () {
      final session = KnowledgeAcquisitionSession(initial: _base());
      expect(session.state.evidence.length, 1);
      expect(session.canRollback, isFalse);

      const batch = '''
      { "domain": "knowledge_acquisition", "evidence": [
        { "id": "EV-0002", "sourceType": "book", "school": "vedic",
          "author": "C", "book": "D", "language": "en", "reviewStatus": "draft" }
      ]}''';
      final report = session.apply(batch);
      expect(report.imported, 1);
      expect(session.state.evidence.length, 2);
      expect(session.history, hasLength(1));
      expect(session.canRollback, isTrue);

      session.rollback();
      expect(session.state.evidence.length, 1);
      expect(session.canRollback, isFalse);
    });

    test('no-op / fatal batches do not push undo state', () {
      final session = KnowledgeAcquisitionSession(initial: _base());
      session.apply('not json');
      expect(session.canRollback, isFalse);
      // identical evidence → skipped only → no-op → not applied
      session.apply(
        '{ "domain": "knowledge_acquisition", "evidence": ['
        '{ "id": "EV-0001", "sourceType": "book", "school": "thaiTraditional",'
        '"author": "A", "book": "B", "language": "th", "reviewStatus": "verified" }]}',
      );
      expect(session.canRollback, isFalse);
    });
  });

  group('AcquisitionState — JSON export round-trips', () {
    test('toAssetJson reloads to the same corpus via the V4 engines', () {
      final session = KnowledgeAcquisitionSession(initial: _base());
      session.apply('''
      { "domain": "knowledge_acquisition",
        "evidence": [{ "id": "EV-0002", "sourceType": "book", "school": "vedic",
          "author": "C", "book": "D", "language": "en", "reviewStatus": "draft" }],
        "research": [{ "id": "RR-0002", "topic": "t", "entity": "x",
          "interpretation": "i",
          "relationship": [{ "from": "mars", "to": "venus", "relation": "neutral" }],
          "evidenceIds": ["EV-0002"], "confidence": "low", "status": "draft" }]
      }''');
      final docs = session.state.toAssetJson();
      final reloaded = KnowledgeEvidenceEngine.load(
        evidenceJson: docs['evidence.knowme.json']!,
        researchJson: docs['research.knowme.json']!,
      );
      expect(reloaded.evidence.length, 2);
      expect(reloaded.research.length, 2);
      expect(reloaded.validate().errors, isEmpty);
    });
  });

  group('Acquisition Dashboard — route + render', () {
    test('acquire route resolves; matches exact path', () {
      expect(KnowledgeWorkspaceRoutes.acquireRouteName,
          '/internal/knowledge/acquire');
      expect(
        KnowledgeWorkspaceRoutes.onGenerateRoute(
            const RouteSettings(name: '/internal/knowledge/acquire')),
        isNotNull,
      );
      expect(
        KnowledgeWorkspaceRoutes.onGenerateRoute(
            const RouteSettings(name: '/internal/knowledge')),
        isNotNull,
      );
    });

    testWidgets('renders dashboard with injected bootstrap', (tester) async {
      final knowledge = PlanetRelationshipKnowledgeImporter.importJson(
        File('knowledge/planet_relationships/planet_relationships.knowme.json')
            .readAsStringSync(),
      ).knowledge;
      await tester.pumpWidget(MaterialApp(
        home: KnowledgeAcquisitionDashboard(
          bootstrap: Future.value(
            KnowledgeAcquisitionBootstrap(
              knowledge: knowledge,
              initial: _base(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Knowledge Acquisition — Internal'), findsOneWidget);
      expect(find.text('Bulk JSON import'), findsOneWidget);
    });
  });

  group('Acquisition — no matrix / engine dependency', () {
    test('acquisition source files do not import the matrix or runtime', () {
      const files = [
        'lib/features/knowledge_workspace/acquisition/knowledge_acquisition_engine.dart',
        'lib/features/knowledge_workspace/acquisition/knowledge_acquisition_dashboard.dart',
      ];
      for (final path in files) {
        final src = File(path).readAsStringSync();
        expect(src.contains('planet_relationship_matrix'), isFalse, reason: path);
        expect(src.contains('core/runtime'), isFalse, reason: path);
        expect(src.contains('core/prediction'), isFalse, reason: path);
        expect(src.contains('core/life_period'), isFalse, reason: path);
      }
    });
  });
}
