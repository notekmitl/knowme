import '../reasoning_module.dart';
import '../reasoning_request.dart';
import '../reasoning_runtime.dart';
import 'fusion_agreement.dart';
import 'fusion_conflict.dart';
import 'fusion_confidence.dart';
import 'fusion_context.dart';
import 'fusion_evidence.dart';
import 'fusion_observation.dart';
import 'fusion_priority.dart';
import 'fusion_result.dart';
import 'fusion_rule.dart';

/// P2 — the Cross-System Fusion Runtime.
///
/// Sits **above** the global [ReasoningRuntime] (it does not replace it): for a
/// [FusionContext] it fans the request out across every provider that supports
/// the capability, collects each provider's response as a [FusionObservation],
/// then detects agreement, conflict, missing evidence and priority, and merges
/// everything into one [FusionResult]. With a single registered provider it runs
/// in **single-provider mode** (no agreement/conflict, confidence passed through).
/// No AI, no presenter, no UI — deterministic structure only.
class FusionRuntime {
  const FusionRuntime(this.runtime, {this.rule = const FusionRule()});

  /// Builds a fusion runtime over a discovered global runtime.
  factory FusionRuntime.discover({FusionRule rule = const FusionRule()}) =>
      FusionRuntime(ReasoningRuntime.discover(), rule: rule);

  final ReasoningRuntime runtime;
  final FusionRule rule;

  FusionResult fuse(FusionContext context) {
    final observations = _observe(context);
    if (observations.isEmpty) {
      throw StateError(
        'No providers support ${context.capability.name} for fusion',
      );
    }

    final byDomain = _domainNets(observations);
    final domains = byDomain.keys.toList()..sort();

    final agreements = <FusionAgreement>[];
    final conflicts = <FusionConflict>[];
    final mergedEvidence = <FusionEvidence>[];
    final missing = <String>[];
    final agreedDomains = <String>{};

    for (final domain in domains) {
      final perModule = byDomain[domain]!;
      final modules = perModule.keys.toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      final netTotal = perModule.values.fold<int>(0, (a, b) => a + b);
      final positives = [
        for (final e in perModule.entries)
          if (e.value > 0) e.key,
      ]..sort((a, b) => a.index.compareTo(b.index));
      final negatives = [
        for (final e in perModule.entries)
          if (e.value < 0) e.key,
      ]..sort((a, b) => a.index.compareTo(b.index));

      mergedEvidence.add(FusionEvidence(
        domain: domain,
        netMagnitude: netTotal,
        modules: modules,
      ));

      if (positives.isNotEmpty && negatives.isNotEmpty) {
        final nets = perModule.values;
        conflicts.add(FusionConflict(
          domain: domain,
          positiveModules: positives,
          negativeModules: negatives,
          spread: nets.reduce((a, b) => a > b ? a : b) -
              nets.reduce((a, b) => a < b ? a : b),
        ));
      } else if (positives.length + negatives.length >= 2) {
        agreedDomains.add(domain);
        agreements.add(FusionAgreement(
          domain: domain,
          modules: modules,
          direction: netTotal.sign,
          magnitude: netTotal.abs(),
        ));
      }

      if (perModule.length < observations.length) {
        missing.add(domain);
      }
    }

    final priorities = _priorities(mergedEvidence, agreedDomains);
    final confidence = _confidence(observations, agreements, conflicts);

    return FusionResult(
      capability: context.capability,
      observations: observations,
      agreements: agreements,
      conflicts: conflicts,
      mergedEvidence: mergedEvidence,
      priorities: priorities,
      confidence: confidence,
      singleProviderMode: observations.length == 1,
      missingEvidence: missing,
    );
  }

  // --- Internals -----------------------------------------------------------

  List<FusionObservation> _observe(FusionContext context) {
    final observations = <FusionObservation>[];
    for (final provider in runtime.providers) {
      if (!provider.supports(context.capability)) continue;
      if (context.modules != null &&
          !context.modules!.contains(provider.module)) {
        continue;
      }
      final response = runtime.run(ReasoningRequest(
        module: provider.module,
        capability: context.capability,
        birthDate: context.birthDate,
        asOf: context.asOf,
        parameters: context.parameters,
      ));
      observations.add(FusionObservation.fromResponse(response));
    }
    return observations;
  }

  Map<String, Map<ReasoningModule, int>> _domainNets(
    List<FusionObservation> observations,
  ) {
    final byDomain = <String, Map<ReasoningModule, int>>{};
    for (final o in observations) {
      final nets = <String, int>{};
      for (final e in o.evidence) {
        final domain = e.domain;
        if (domain == null) continue;
        nets[domain] = (nets[domain] ?? 0) + e.magnitude;
      }
      nets.forEach((domain, net) {
        (byDomain[domain] ??= {})[o.module] = net;
      });
    }
    return byDomain;
  }

  List<FusionPriority> _priorities(
    List<FusionEvidence> mergedEvidence,
    Set<String> agreedDomains,
  ) {
    final scored = [
      for (final e in mergedEvidence)
        MapEntry(
          e.domain,
          e.netMagnitude.abs() +
              (agreedDomains.contains(e.domain)
                  ? rule.agreementPriorityBoost
                  : 0),
        ),
    ]..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        return byScore != 0 ? byScore : a.key.compareTo(b.key);
      });

    return [
      for (var i = 0; i < scored.length; i++)
        FusionPriority(
          domain: scored[i].key,
          rank: i + 1,
          score: scored[i].value,
          agreed: agreedDomains.contains(scored[i].key),
        ),
    ];
  }

  FusionConfidence _confidence(
    List<FusionObservation> observations,
    List<FusionAgreement> agreements,
    List<FusionConflict> conflicts,
  ) {
    final base = (observations.fold<int>(0, (a, o) => a + o.confidence) /
            observations.length)
        .round();
    final adjusted = (base +
            agreements.length * rule.agreementBonus -
            conflicts.length * rule.conflictPenalty)
        .clamp(0, 100);
    return FusionConfidence.fromValue(
      adjusted,
      providerCount: observations.length,
      rule: rule,
    );
  }
}
