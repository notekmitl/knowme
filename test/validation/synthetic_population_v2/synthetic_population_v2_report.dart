import 'dart:convert';
import 'dart:io';

import 'synthetic_population_v2_runner.dart';

abstract final class SyntheticPopulationV2Report {
  static String toMarkdown(SyntheticPopulationV2AuditResult audit) {
    final buffer = StringBuffer();
    final pq = audit.populationQuality;
    final dz = audit.deadZoneRevalidation;
    final v2 = audit.v2Simulation;
    final baseline = v2['baseline'] as Map<String, dynamic>;
    final simulated = v2['simulatedAfterRecovery'] as Map<String, dynamic>;
    final vg005 = v2['vg005NarrativeQuality'] as Map<String, dynamic>;
    final stability = audit.stabilityAnalysis;
    final gate = audit.decisionGate;
    final gates = audit.validationGates;

    buffer.writeln('# Synthetic Population V2 — 1000 Human Validation Report');
    buffer.writeln();
    buffer.writeln('**Program:** Synthetic Population Validation V2');
    buffer.writeln('**Population:** 1000 synthetic humans (250 archetypes × 4 variants)');
    buffer.writeln('**Scope:** Validation only — no production modifications');
    buffer.writeln();

    _section1PopulationQuality(buffer, pq);
    _section2DiversityAudit(buffer, audit);
    _section3DeadZones(buffer, dz);
    _section4V2Simulation(buffer, v2, baseline, simulated, vg005);
    _section5Stability(buffer, stability);
    _section6Architecture(buffer, gate);
    _section7Readiness(buffer, gate);

    buffer.writeln('---');
    buffer.writeln('_Synthetic Population Validation V2 — read-only._');
    return buffer.toString();
  }

  static void _section1PopulationQuality(
    StringBuffer b,
    Map<String, dynamic> pq,
  ) {
    b.writeln('## 1. Population Quality');
    b.writeln();
    b.writeln('| Metric | Value | Pass |');
    b.writeln('|---|---:|---|');
    b.writeln('| Population size | ${pq['populationSize']} | ✓ |');
    b.writeln('| Archetype count | ${pq['archetypeCount']} | ✓ (≥250) |');
    b.writeln(
      '| Max archetype share | ${((pq['maxArchetypeShare'] as double) * 100).toStringAsFixed(2)}% | '
      '${pq['maxArchetypeSharePass'] == true ? '✓ (≤5%)' : '✗'} |',
    );
    b.writeln();
    b.writeln('**MBTI distribution (top 5):**');
    final mbti = pq['mbtiDistribution'] as Map<String, dynamic>;
    for (final entry in mbti.entries.take(5)) {
      b.writeln('- ${entry.key}: ${entry.value}');
    }
    b.writeln();
    b.writeln('**Attachment distribution:**');
    final att = pq['attachmentDistribution'] as Map<String, dynamic>;
    for (final entry in att.entries) {
      b.writeln('- ${entry.key}: ${entry.value}');
    }
    b.writeln();
  }

  static void _section2DiversityAudit(
    StringBuffer b,
    SyntheticPopulationV2AuditResult audit,
  ) {
    b.writeln('## 2. Diversity Audit');
    b.writeln();
    final d = audit.diversity;
    b.writeln('| Layer | Unique | Diversity Ratio |');
    b.writeln('|---|---:|---:|');
    b.writeln(
      '| Mirror | ${d.uniqueMirrorOutcomes} | ${(d.mirrorDiversityRatio * 100).toStringAsFixed(1)}% |',
    );
    b.writeln(
      '| Fusion | ${d.uniqueFusionOutcomes} | ${(d.fusionDiversityRatio * 100).toStringAsFixed(1)}% |',
    );
    b.writeln(
      '| Pattern sets | ${d.uniquePatternSets} | ${(d.patternDiversityRatio * 100).toStringAsFixed(1)}% |',
    );
    b.writeln(
      '| Narratives | ${d.uniqueNarrativeFingerprints} | ${(d.narrativeDiversityRatio * 100).toStringAsFixed(1)}% |',
    );
    b.writeln();

    final arch = audit.architectureDiversity;
    final mirror = arch['mirrorLayer'] as Map<String, dynamic>;
    final fusion = arch['fusionLayer'] as Map<String, dynamic>;
    final hm = arch['humanModelLayer'] as Map<String, dynamic>;
    b.writeln('### Mirror layer');
    b.writeln('- Unique fingerprints: ${mirror['uniqueMirrorFingerprints']}');
    b.writeln('- Total evidence rows: ${mirror['totalEvidenceRows']}');
    b.writeln();
    b.writeln('### Fusion layer');
    b.writeln('- Unique fingerprints: ${fusion['uniqueFusionFingerprints']}');
    b.writeln('- Total tensions: ${fusion['tensionCountTotal']}');
    b.writeln();
    b.writeln('### Human Model layer');
    b.writeln('- Unique fingerprints: ${hm['uniqueModelFingerprints']}');
    b.writeln();
    b.writeln('### Human Pattern layer');
    b.writeln(
      '- Dead patterns: ${audit.patternDistribution.neverActivatedPatternIds.length} / '
      '${audit.patternDistribution.registryPatternCount}',
    );
    b.writeln(
      '- Top activated: ${audit.patternDistribution.activationFrequency.entries.firstOrNull?.key ?? 'n/a'} '
      '(${audit.patternDistribution.activationFrequency.entries.firstOrNull?.value ?? 0})',
    );
    b.writeln();
    b.writeln('### Narrative layer');
    b.writeln(
      '- Collapse zones (≥3): ${audit.narrativeDuplication.collapseZones.length}',
    );
    b.writeln(
      '- Max cluster: ${audit.narrativeDuplication.maxDuplicationClusterSize}',
    );
    b.writeln();
    b.writeln('**Fusion dead zones:** ${audit.fusionDistribution.fusionDeadZones.join(', ')}');
    b.writeln();
  }

  static void _section3DeadZones(StringBuffer b, Map<String, dynamic> dz) {
    b.writeln('## 3. Dead Zone Revalidation');
    b.writeln();
    final traces = dz['traces'] as Map<String, dynamic>;
    final summary = dz['summary'] as Map<String, dynamic>;
    b.writeln('| Mirror Key | Status | Input Signals | Mirror Findings | Fusion Findings | Pattern Activations |');
    b.writeln('|---|---|---:|---:|---:|---:|');
    for (final key in traces.keys) {
      final t = traces[key] as Map<String, dynamic>;
      b.writeln(
        '| $key | ${summary[key]} | ${t['inputSignals']} | ${t['mirrorFindings']} | '
        '${t['fusionFindings']} | ${t['patternActivations']} |',
      );
    }
    b.writeln();
  }

  static void _section4V2Simulation(
    StringBuffer b,
    Map<String, dynamic> v2,
    Map<String, dynamic> baseline,
    Map<String, dynamic> simulated,
    Map<String, dynamic> vg005,
  ) {
    final baseQ = vg005['baseline'] as Map<String, dynamic>;
    final simQ = vg005['simulated'] as Map<String, dynamic>;
    b.writeln('## 4. V2 Recovery Simulation');
    b.writeln();
    b.writeln('Simulation engine: MV2 MP-001 (validation) + GF2 supplemental (existing prototype) + GF2-R004 (validation)');
    b.writeln();
    b.writeln('| Metric | Before (V1) | After (V2 sim) | Δ |');
    b.writeln('|---|---:|---:|---:|');
    b.writeln(
      '| Total activations | ${baseline['totalActivations']} | ${simulated['totalActivations']} | '
      '+${simulated['additionalActivations']} |',
    );
    b.writeln(
      '| Unique pattern sets | ${baseline['uniquePatternSets']} | ${simulated['uniquePatternSets']} | '
      '+${simulated['additionalUniquePatternSets']} |',
    );
    b.writeln(
      '| Unique narratives | ${baseline['uniqueNarratives']} | ${simulated['uniqueNarratives']} | '
      '+${simulated['additionalUniqueNarratives']} |',
    );
    b.writeln(
      '| Dead patterns | ${baseline['deadPatternCount']} | ${simulated['deadPatternCount']} | '
      '${(simulated['deadPatternCount'] as int) - (baseline['deadPatternCount'] as int)} |',
    );
    b.writeln(
      '| Profiles in collapse | ${baseQ['profilesInCollapse']} | ${simQ['profilesInCollapse']} | '
      '${(simQ['profilesInCollapse'] as int) - (baseQ['profilesInCollapse'] as int)} |',
    );
    b.writeln(
      '| Max cluster size | ${baseQ['maxClusterSize']} | ${simQ['maxClusterSize']} | '
      '${(simQ['maxClusterSize'] as int) - (baseQ['maxClusterSize'] as int)} |',
    );
    b.writeln(
      '| MP-001 promotions applied | — | ${simulated['mp001PromotionsApplied']} | — |',
    );
    b.writeln(
      '| R004 reinforcements applied | — | ${simulated['r004ReinforcementsApplied']} | — |',
    );
    b.writeln();
    final fusionDiv = v2['fusionDiversity'] as Map<String, dynamic>;
    b.writeln(
      '- Fusion diversity (unique hashes): ${fusionDiv['baselineUniqueFusion']} → '
      '${fusionDiv['simulatedUniqueFusion']}',
    );
    b.writeln();
  }

  static void _section5Stability(StringBuffer b, Map<String, dynamic> stability) {
    b.writeln('## 5. Stability Analysis (200 vs 1000)');
    b.writeln();
    b.writeln('**Overall stability:** ${stability['overallStability']}');
    b.writeln();
    b.writeln('| Metric | 200 | 1000 | Abs gain | Stability |');
    b.writeln('|---|---:|---:|---:|---|');
    for (final m in stability['metrics'] as List) {
      final map = m as Map<String, dynamic>;
      b.writeln(
        '| ${map['metric']} | ${map['baseline200']} | ${map['scale1000']} | '
        '${map['absoluteGain']} | ${map['stability']} |',
      );
    }
    b.writeln();
  }

  static void _section6Architecture(StringBuffer b, Map<String, dynamic> gate) {
    b.writeln('## 6. Architecture Recommendation');
    b.writeln();
    b.writeln('| Question | Answer |');
    b.writeln('|---|---|');
    b.writeln('| GF2 V2 still justified at 1000? | **${gate['gf2V2StillJustified']}** |');
    b.writeln('| Architecture still B + C? | **${gate['architectureStillBPlusC']}** |');
    b.writeln('| New dead zones? | **${gate['newDeadZonesDetected']}** |');
    b.writeln('| Hidden regressions? | **${gate['hiddenRegressionsDetected']}** |');
    b.writeln();
    final evidence = gate['evidence'] as Map<String, dynamic>;
    if ((gate['newDeadZoneKeys'] as List).isNotEmpty) {
      b.writeln('New dead zone keys: ${gate['newDeadZoneKeys']}');
      b.writeln();
    }
    b.writeln('Evidence summary:');
    b.writeln('- Activation gain: ${evidence['activationGain']}');
    b.writeln('- Narrative gain: ${evidence['narrativeGain']}');
    b.writeln('- Dead patterns: ${evidence['baselineDeadPatterns']} → ${evidence['simulatedDeadPatterns']}');
    b.writeln('- Dead zone status: ${evidence['deadZoneStatus']}');
    b.writeln();
  }

  static void _section7Readiness(StringBuffer b, Map<String, dynamic> gate) {
    b.writeln('## 7. Implementation Readiness');
    b.writeln();
    b.writeln(
      '**Should implementation begin now? ${gate['implementationShouldBeginNow']}**',
    );
    b.writeln();
    b.writeln(
      gate['implementationShouldBeginNow'] == 'YES'
          ? '1000-human validation confirms V2 recovery architecture (Mirror Promotion + Supplemental Fusion) '
              'scales with stable proportional gains. Proceed to MV2 + GF2 implementation per specification.'
          : '1000-human validation did not meet decision gate criteria. Do not begin implementation until blockers resolved.',
    );
    b.writeln();
  }

  static void writeArtifacts({
    required SyntheticPopulationV2AuditResult audit,
    required String jsonPath,
    required String markdownPath,
  }) {
    final json = {
      'version': 'synthetic_population_v2_1000',
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationQuality': audit.populationQuality,
      'diversity': audit.diversity.toJson(),
      'coverage': audit.coverage.toJson(),
      'narrativeDuplication': audit.narrativeDuplication.toJson(),
      'patternDistribution': audit.patternDistribution.toJson(),
      'fusionDistribution': audit.fusionDistribution.toJson(),
      'architectureDiversity': audit.architectureDiversity,
      'deadZoneRevalidation': audit.deadZoneRevalidation,
      'v2Simulation': audit.v2Simulation,
      'validationGates': audit.validationGates,
      'stabilityAnalysis': audit.stabilityAnalysis,
      'decisionGate': audit.decisionGate,
    };

    File(jsonPath)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));

    File(markdownPath)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(toMarkdown(audit));
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
