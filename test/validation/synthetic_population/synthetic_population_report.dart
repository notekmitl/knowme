import 'dart:convert';
import 'dart:io';

import 'synthetic_population_runner.dart';

abstract final class SyntheticPopulationReport {
  static Map<String, dynamic> toJson(SyntheticPopulationAudit audit) {
    return {
      'version': 'synthetic_human_population_v1',
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationSize': audit.records.length,
      'archetypeCount': audit.records
          .map((item) => item.profile.archetypeId)
          .toSet()
          .length,
      'diversity': audit.diversity.toJson(),
      'coverage': audit.coverage.toJson(),
      'narrativeDuplication': audit.narrativeDuplication.toJson(),
      'patternDistribution': audit.patternDistribution.toJson(),
      'fusionDistribution': audit.fusionDistribution.toJson(),
      'recommendations': audit.recommendations,
      'sampleRecords':
          audit.records.take(5).map((item) => item.toJson()).toList(),
    };
  }

  static String toMarkdown(SyntheticPopulationAudit audit) {
    final buffer = StringBuffer();

    buffer.writeln('# Synthetic Human Population V1');
    buffer.writeln();
    buffer.writeln(
      'Validation-only stress test across **${audit.records.length}** '
      'synthetic humans (50 archetypes × 4 variants).',
    );
    buffer.writeln();
    buffer.writeln('## Population Architecture');
    buffer.writeln();
    buffer.writeln(
      '- **Archetypes:** 50 coherent role templates (Architect → Executor)',
    );
    buffer.writeln(
      '- **Variants:** A (canonical), B (J/P flip), C (trait shift), D (astro shift)',
    );
    buffer.writeln(
      '- **Dimensions:** MBTI, Big Five, EQ, Attachment (validation metadata), Thai, BaZi, Zodiac',
    );
    buffer.writeln(
      '- **Pipeline:** Lens → Mirror → Global Fusion → Human Model → Human Pattern → Narrative',
    );
    buffer.writeln(
      '- **Scope:** No production runtime changes; validation harness only',
    );
    buffer.writeln();
    buffer.writeln('## Diversity Metrics');
    buffer.writeln();
    buffer.writeln('| Layer | Unique Outcomes | Diversity Ratio |');
    buffer.writeln('|-------|-----------------|-----------------|');
    buffer.writeln(
      '| Mirror | ${audit.diversity.uniqueMirrorOutcomes} | '
      '${_pct(audit.diversity.mirrorDiversityRatio)} |',
    );
    buffer.writeln(
      '| Fusion | ${audit.diversity.uniqueFusionOutcomes} | '
      '${_pct(audit.diversity.fusionDiversityRatio)} |',
    );
    buffer.writeln(
      '| Pattern sets | ${audit.diversity.uniquePatternSets} | '
      '${_pct(audit.diversity.patternDiversityRatio)} |',
    );
    buffer.writeln(
      '| Narratives | ${audit.diversity.uniqueNarrativeFingerprints} | '
      '${_pct(audit.diversity.narrativeDiversityRatio)} |',
    );
    buffer.writeln();
    buffer.writeln('## Dominant Systems Audit');
    buffer.writeln();
    buffer.writeln(
      '**Overpowered / dominant mirror contributors:** '
      '${audit.coverage.dominantSystems.isEmpty ? 'none flagged' : audit.coverage.dominantSystems.join(', ')}',
    );
    buffer.writeln();
    for (final entry in audit.coverage.signalShareBySystem.entries) {
      buffer.writeln(
        '- ${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}% '
        '(${audit.coverage.signalCountsBySystem[entry.key]} signals)',
      );
    }
    buffer.writeln();
    buffer.writeln('## Weak Systems Audit');
    buffer.writeln();
    buffer.writeln(
      '**Weak contributors (≤8% mirror signal share):** '
      '${audit.coverage.weakSystems.isEmpty ? 'none flagged' : audit.coverage.weakSystems.join(', ')}',
    );
    buffer.writeln();
    buffer.writeln('## Narrative Duplication Analysis');
    buffer.writeln();
    buffer.writeln(
      '- Unique narratives: ${audit.narrativeDuplication.uniqueNarratives}',
    );
    buffer.writeln(
      '- Duplication rate: ${_pct(audit.narrativeDuplication.duplicationRate)}',
    );
    buffer.writeln(
      '- Max cluster size: ${audit.narrativeDuplication.maxDuplicationClusterSize}',
    );
    buffer.writeln(
      '- Collapse zones (≥3 identical): ${audit.narrativeDuplication.collapseZones.length}',
    );
    buffer.writeln();
    buffer.writeln('## Dead Zone Analysis');
    buffer.writeln();
    buffer.writeln(
      '### Pattern dead zones (${audit.patternDistribution.deadZonePatternIds.length})',
    );
    buffer.writeln();
    buffer.writeln(
      _bulletList(audit.patternDistribution.deadZonePatternIds.take(20)),
    );
    buffer.writeln();
    buffer.writeln(
      '### Fusion dead zones — mirror keys never reaching fusion '
      '(${audit.fusionDistribution.fusionDeadZones.length})',
    );
    buffer.writeln();
    buffer.writeln(
      _bulletList(audit.fusionDistribution.fusionDeadZones.take(20)),
    );
    buffer.writeln();
    buffer.writeln('## Pattern Distribution');
    buffer.writeln();
    buffer.writeln(
      '- Registry patterns: ${audit.patternDistribution.registryPatternCount}',
    );
    buffer.writeln(
      '- Ever activated: ${audit.patternDistribution.everActivatedPatternCount}',
    );
    buffer.writeln(
      '- Never activated: ${audit.patternDistribution.neverActivatedPatternIds.length}',
    );
    buffer.writeln();
    buffer.writeln('Top activated patterns:');
    buffer.writeln();
    for (final entry
        in audit.patternDistribution.activationFrequency.entries.take(10)) {
      buffer.writeln('- ${entry.key}: ${entry.value}');
    }
    buffer.writeln();
    buffer.writeln('## Recommendations');
    buffer.writeln();
    for (final item in audit.recommendations) {
      buffer.writeln('- $item');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln(
      '_Generated by Synthetic Human Population V1 validation harness._',
    );

    return buffer.toString();
  }

  static void writeArtifacts({
    required SyntheticPopulationAudit audit,
    required String jsonPath,
    required String markdownPath,
  }) {
    final jsonFile = File(jsonPath);
    jsonFile.parent.createSync(recursive: true);
    jsonFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(toJson(audit)),
    );

    final mdFile = File(markdownPath);
    mdFile.parent.createSync(recursive: true);
    mdFile.writeAsStringSync(toMarkdown(audit));
  }

  static String _pct(double value) => '${(value * 100).toStringAsFixed(1)}%';

  static String _bulletList(Iterable<String> items) {
    if (items.isEmpty) return '- _(none)_';
    return items.map((item) => '- $item').join('\n');
  }
}
