import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/evidence/knowledge_evidence_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart';
import 'package:knowme/features/knowledge_workspace/application/knowledge_workspace_data.dart';
import 'package:knowme/features/knowledge_workspace/knowledge_workspace_routes.dart';
import 'package:knowme/features/knowledge_workspace/presentation/knowledge_workspace_page.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';
import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';

class _FakeAccess implements ThaiResearchAdminAccess {
  _FakeAccess(this.value);
  final ThaiResearchAccess value;
  @override
  Stream<ThaiResearchAccess> watch() => Stream.value(value);
}

const _evidenceJson = '''
{
  "domain": "knowledge_evidence",
  "records": [
    { "id": "EV-0001", "sourceType": "book", "school": "thaiTraditional",
      "author": "Author A", "book": "Book A", "edition": "1st",
      "language": "th", "reviewStatus": "verified" }
  ]
}
''';

const _researchJson = '''
{
  "domain": "knowledge_research",
  "records": [
    { "id": "RR-0001", "topic": "planet_relationship", "entity": "Saturn–Venus",
      "interpretation": "Friends.",
      "relationship": [{ "from": "saturn", "to": "venus", "relation": "friend" }],
      "evidenceIds": ["EV-0001"], "confidence": "high", "status": "verified" }
  ]
}
''';

KnowledgeWorkspaceData _buildData() {
  final knowledge = PlanetRelationshipKnowledgeImporter.importJson(
    File('knowledge/planet_relationships/planet_relationships.knowme.json')
        .readAsStringSync(),
  ).knowledge;
  final evidenceEngine = KnowledgeEvidenceEngine.load(
    evidenceJson: _evidenceJson,
    researchJson: _researchJson,
  );
  return KnowledgeWorkspaceData.build(
    knowledge: knowledge,
    evidenceEngine: evidenceEngine,
  );
}

void main() {
  group('KnowledgeWorkspaceData — aggregation', () {
    final data = _buildData();

    test('builds one view per V2 relationship (56), matrix value carried', () {
      expect(data.relationships.length, 56);
      final sv = data.relationships
          .firstWhere((v) => v.from == 'saturn' && v.to == 'venus');
      expect(sv.currentMatrix, 'friend');
      expect(sv.knowledgeStatus, PlanetRelationshipStatus.unknown);
    });

    test('joins research + evidence onto the linked relationship', () {
      final sv = data.relationships
          .firstWhere((v) => v.from == 'saturn' && v.to == 'venus');
      expect(sv.research.single.id, 'RR-0001');
      expect(sv.evidence.single.id, 'EV-0001');
      // A pair with no research stays empty.
      final sunMoon = data.relationships
          .firstWhere((v) => v.from == 'sun' && v.to == 'moon');
      expect(sunMoon.research, isEmpty);
      expect(sunMoon.evidence, isEmpty);
    });

    test('knowledge coverage is the V2 status split', () {
      expect(data.knowledgeCoverage.total, 56);
      expect(data.knowledgeCoverage.unknown, 56);
      expect(data.knowledgeCoverage.verified, 0);
    });
  });

  group('KnowledgeWorkspaceData — filters', () {
    final data = _buildData();

    test('filter by planet', () {
      final saturn = data.filterRelationships(
          const KnowledgeWorkspaceFilter(planet: 'saturn'));
      expect(saturn, isNotEmpty);
      expect(saturn.every((v) => v.from == 'saturn' || v.to == 'saturn'),
          isTrue);
    });

    test('filter by relation', () {
      final enemies = data.filterRelationships(
          const KnowledgeWorkspaceFilter(relation: 'enemy'));
      expect(enemies, isNotEmpty);
      expect(enemies.every((v) => v.currentMatrix == 'enemy'), isTrue);
    });

    test('filter by school/author/book uses linked evidence', () {
      final bySchool = data.filterRelationships(
          const KnowledgeWorkspaceFilter(school: 'thaiTraditional'));
      expect(bySchool.length, 1);
      expect(bySchool.single.pairKey, 'saturn->venus');

      expect(data.schools, contains('thaiTraditional'));
      expect(data.authors, contains('Author A'));
      expect(data.books, contains('Book A · 1st'));
    });
  });

  group('Knowledge Workspace — page + admin gating', () {
    testWidgets('renders relationships when data is injected', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: KnowledgeWorkspacePage(
          dataFuture: Future.value(_buildData()),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Knowledge Workspace — Internal'), findsOneWidget);
      // First row in the list (sun is first in planet order).
      expect(find.text('sun → moon'), findsOneWidget);
    });

    testWidgets('admin guard hides workspace from non-admins', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ThaiResearchAdminGuard(
          access: _FakeAccess(ThaiResearchAccess.notAdmin),
          adminBuilder: (_) => const Text('WORKSPACE'),
        ),
      ));
      await tester.pump();
      expect(find.text('WORKSPACE'), findsNothing);
    });

    testWidgets('admin guard shows workspace for admins', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ThaiResearchAdminGuard(
          access: _FakeAccess(ThaiResearchAccess.admin),
          adminBuilder: (_) => const Text('WORKSPACE'),
        ),
      ));
      await tester.pump();
      expect(find.text('WORKSPACE'), findsOneWidget);
    });

    test('route name is the internal admin path', () {
      expect(KnowledgeWorkspaceRoutes.routeName, '/internal/knowledge');
      final route = KnowledgeWorkspaceRoutes.onGenerateRoute(
        const RouteSettings(name: '/internal/knowledge'),
      );
      expect(route, isNotNull);
      expect(
        KnowledgeWorkspaceRoutes.onGenerateRoute(
            const RouteSettings(name: '/somewhere-else')),
        isNull,
      );
    });
  });

  group('Knowledge Workspace — no runtime/prediction dependency', () {
    test('workspace source files import only the knowledge layer', () {
      const files = [
        'lib/features/knowledge_workspace/application/knowledge_workspace_data.dart',
        'lib/features/knowledge_workspace/presentation/knowledge_workspace_page.dart',
      ];
      for (final path in files) {
        final src = File(path).readAsStringSync();
        expect(src.contains('core/runtime'), isFalse, reason: path);
        expect(src.contains('core/prediction'), isFalse, reason: path);
        expect(src.contains('core/decision'), isFalse, reason: path);
        expect(src.contains('core/question'), isFalse, reason: path);
        expect(src.contains('mirror/runtime'), isFalse, reason: path);
      }
    });
  });
}
