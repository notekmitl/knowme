import 'dart:convert';
import 'dart:io';

import 'human_pattern_activation_audit_runner.dart';

abstract final class HumanPatternActivationAuditReport {
  static Map<String, dynamic> toJson(HumanPatternActivationAuditResult result) {
    return {
      'version': 'human_pattern_activation_audit_v1',
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationSize': result.records.length,
      'auditA_patternDeadZones': result.patternDeadZones.toJson(),
      'auditB_eqSignalSurvival': result.eqSignalSurvival.toJson(),
      'auditC_narrativeCollapse': result.narrativeCollapse.toJson(),
      'auditD_systemDominance': result.systemDominance.toJson(),
      'auditE_patternUtilization': result.patternUtilization.toJson(),
      'rootCauseAnalysis':
          result.rootCauseAnalysis.map((item) => item.toJson()).toList(),
      'evidenceBasedConclusions': result.evidenceBasedConclusions,
    };
  }

  static String toMarkdown(HumanPatternActivationAuditResult result) {
    final buffer = StringBuffer();
    final dz = result.patternDeadZones;
    final eq = result.eqSignalSurvival;
    final narrative = result.narrativeCollapse;
    final dominance = result.systemDominance;
    final util = result.patternUtilization;

    buffer.writeln('# Human Pattern Activation Audit V1');
    buffer.writeln();
    buffer.writeln(
      'Read-only investigation across **${result.records.length}** synthetic humans. '
      'No production systems modified.',
    );
    buffer.writeln();

    buffer.writeln('## Audit A — Pattern Dead Zones');
    buffer.writeln();
    buffer.writeln(
      '**Never activated:** ${dz.neverActivated.length} / ${util.registryPatternCount}',
    );
    buffer.writeln();
    buffer.writeln('| Pattern | Class | Primary Block | Source Rate | Rule Pass |');
    buffer.writeln('|---------|-------|---------------|-------------|-----------|');
    for (final entry in dz.neverActivated) {
      buffer.writeln(
        '| ${entry.patternId} | ${entry.deadZoneClass.key} | '
        '${entry.primaryBlockReason} | '
        '${_pct(entry.sourceResolutionRate)} | ${_pct(entry.rulePassRate)} |',
      );
    }
    buffer.writeln();

    buffer.writeln('## Audit B — EQ Signal Survival');
    buffer.writeln();
    buffer.writeln('| Layer | EQ Signal Count | Survival Rate | Loss Rate |');
    buffer.writeln('|-------|-----------------|---------------|-----------|');
    for (final layer in eq.eqLayerCounts.keys) {
      buffer.writeln(
        '| $layer | ${eq.eqLayerCounts[layer]} | '
        '${_pct(eq.eqSurvivalRates[layer] ?? 0)} | '
        '${_pct(eq.eqLossRates[layer] ?? 0)} |',
      );
    }
    buffer.writeln();
    buffer.writeln(
      '**Primary EQ loss boundary:** ${eq.primaryEqLossLayer}',
    );
    buffer.writeln(
      '**Profiles with zero EQ at narrative:** ${eq.profilesWithZeroEqAtNarrative}/200',
    );
    buffer.writeln();

    buffer.writeln('## Audit C — Narrative Collapse');
    buffer.writeln();
    buffer.writeln('| Layer | Unique Outcomes | Compression Ratio |');
    buffer.writeln('|-------|-----------------|-------------------|');
    for (final entry in narrative.layerUniques.entries) {
      buffer.writeln(
        '| ${entry.key} | ${entry.value} | '
        '${_pct(narrative.layerCompressionRatios[entry.key] ?? 0)} |',
      );
    }
    buffer.writeln();
    buffer.writeln(
      '**Primary collapse step:** ${narrative.primaryCollapseStage}',
    );
    buffer.writeln(
      '**Collapse zones (≥3 identical):** ${narrative.collapseZones.length}',
    );
    buffer.writeln();
    buffer.writeln('Top collapse zones:');
    for (final zone in narrative.collapseZones.take(5)) {
      buffer.writeln(
        '- Cluster ${zone.clusterSize}: stage=${zone.collapseStage}, '
        'mirrors=${zone.uniqueMirrorFingerprints}, patterns=${zone.uniquePatternSets}',
      );
    }
    buffer.writeln();

    buffer.writeln('## Audit D — System Dominance');
    buffer.writeln();
    for (final layer in dominance.layerSystemShares.keys) {
      buffer.writeln('### $layer');
      final shares = dominance.layerSystemShares[layer]!;
      for (final entry in shares.entries) {
        buffer.writeln('- ${entry.key}: ${_pct(entry.value)}');
      }
      buffer.writeln();
    }
    buffer.writeln('**Narrative survivors:** ${dominance.narrativeSurvivors}');
    buffer.writeln();

    buffer.writeln('## Audit E — Pattern Utilization');
    buffer.writeln();
    buffer.writeln('**Top 10 activated:**');
    for (final item in util.topActivated) {
      buffer.writeln(
        '- ${item.patternId}: ${item.activationCount}/200 (${_pct(item.activationRate)})',
      );
    }
    buffer.writeln();
    buffer.writeln('**Never activated (${util.neverActivated.length}):**');
    buffer.writeln(
      util.neverActivated.map((item) => item.patternId).join(', '),
    );
    buffer.writeln();
    buffer.writeln('**Family distribution:** ${util.familyDistribution}');
    buffer.writeln('**Dimension distribution:** ${util.dimensionDistribution}');
    buffer.writeln();

    buffer.writeln('## Root Cause Analysis');
    buffer.writeln();
    for (final finding in result.rootCauseAnalysis) {
      buffer.writeln('### ${finding.topic}');
      buffer.writeln(finding.finding);
      buffer.writeln();
    }

    buffer.writeln('## Evidence-Based Conclusions');
    buffer.writeln();
    for (final line in result.evidenceBasedConclusions) {
      buffer.writeln('- $line');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('_Human Pattern Activation Audit V1 — read-only._');

    return buffer.toString();
  }

  static void writeArtifacts({
    required HumanPatternActivationAuditResult result,
    required String jsonPath,
    required String markdownPath,
  }) {
    final jsonFile = File(jsonPath);
    jsonFile.parent.createSync(recursive: true);
    jsonFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(toJson(result)),
    );

    final mdFile = File(markdownPath);
    mdFile.parent.createSync(recursive: true);
    mdFile.writeAsStringSync(toMarkdown(result));
  }

  static String _pct(double value) => '${(value * 100).toStringAsFixed(1)}%';
}
