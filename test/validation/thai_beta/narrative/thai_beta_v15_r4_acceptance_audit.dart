import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_context.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_report_claim_ledger.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_report_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

void writeR4AcceptanceAudits({
  required Directory output,
  required Map<String, ThaiBetaAnalysis> fixtures,
  required Map<String, String> webTexts,
  required Map<String, String> pdfTexts,
}) {
  final claims = <Map<String, Object?>>[];
  final traceRows = <Map<String, Object?>>[];
  final plans = <String, ThaiBetaReportNarrativePlan>{};
  final coverage = <String, Object?>{};
  var freshnessExcludedClaims = 0;
  var expressedClaims = 0;
  var unexpressedClaims = 0;

  void addClaim({
    required String fixture,
    required ThaiBetaReportClaimAllocation allocation,
  }) {
    final web = webTexts[fixture] ?? '';
    final pdf = pdfTexts[fixture] ?? '';
    final webFound = allocation.isPresentIn(web);
    final pdfFound = allocation.isPresentIn(pdf);
    final expressed = allocation.expressed;
    if (expressed) {
      expressedClaims++;
    } else {
      unexpressedClaims++;
    }
    if (allocation.excludedFromFreshness) freshnessExcludedClaims++;
    final row = <String, Object?>{
      'fixture': fixture,
      ...allocation.toJson(),
      'renderedOutputs': [
        if (webFound) 'canonical-web',
        if (pdfFound) 'canonical-pdf',
      ],
    };
    claims.add(row);
    traceRows.add({
      'fixture': fixture,
      'canonicalId': allocation.canonicalId,
      'expressed': expressed,
      'primaryExpression': allocation.primaryExpression,
      'canonicalWeb': {
        'found': webFound,
        'occurrences': _occurrences(web, allocation.primaryExpression),
      },
      'canonicalPdf': {
        'found': pdfFound,
        'occurrences': _occurrences(pdf, allocation.primaryExpression),
      },
      'traceabilityReference': allocation.traceabilityReference,
    });
  }

  for (final entry in fixtures.entries) {
    final fixture = entry.key;
    final analysis = entry.value;
    final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
    final plan = ThaiBetaReportNarrativePlan.fromPrediction(
      prediction: analysis.consumerViewState!.futurePrediction,
      context: ThaiBetaNarrativeContext.fromAnalysis(analysis),
    );
    plans[fixture] = plan;
    final planEvidence = {
      'theme:${plan.themeId}',
      'life-period:${plan.lifePeriodLabel}',
      for (final material in plan.materialsByDomain.values.expand(
        (items) => items,
      ))
        material.evidenceKey,
    };
    final hookBody = view.hero.summary
        .split('\n\n')
        .map((paragraph) => paragraph.trim())
        .firstWhere((paragraph) => paragraph.isNotEmpty);
    addClaim(
      fixture: fixture,
      allocation: ThaiBetaReportClaimAllocation(
        canonicalId: 'hook:headline',
        evidenceKeys: planEvidence,
        evidenceSignature: plan.materialIdentity,
        evidenceType: 'report-level-plan',
        role: 'opening-headline',
        section: view.hero.headline,
        domain: '${plan.primary.name}+${plan.secondary.name}',
        horizon: null,
        primaryExpression: view.hero.headline,
        traceabilityReference: plan.materialIdentity,
        expressed: true,
      ),
    );
    addClaim(
      fixture: fixture,
      allocation: ThaiBetaReportClaimAllocation(
        canonicalId: 'hook:body',
        evidenceKeys: planEvidence,
        evidenceSignature: plan.materialIdentity,
        evidenceType: 'report-level-plan',
        role: 'opening-tension-consequence-question',
        section: view.hero.headline,
        domain: '${plan.primary.name}+${plan.secondary.name}',
        horizon: null,
        primaryExpression: hookBody,
        traceabilityReference: plan.materialIdentity,
        expressed: true,
      ),
    );

    final reading = ThaiBirthProfileCoreReading.fromAnalysis(
      analysis,
      consumerView: view,
    );
    for (final section in reading.sections) {
      for (final claim in section.claims) {
        final atomSignature =
            claim.sourceAtoms
                .expand((atom) => atom.evidenceRefs)
                .map((ref) => '${ref.sourceRef}=${ref.rawValue}')
                .toSet()
                .toList()
              ..sort();
        final medical = claim.semanticKey == 'disclosure:medical';
        final excluded = section.isMethodology || medical;
        addClaim(
          fixture: fixture,
          allocation: ThaiBetaReportClaimAllocation(
            canonicalId: 'core:${claim.semanticKey}',
            evidenceKeys: claim.evidenceKeys.toSet(),
            evidenceSignature: atomSignature.join('|'),
            evidenceType: section.isMethodology
                ? 'methodology'
                : 'computed-core-reading',
            confidence: 'supported',
            role: claim.role.name,
            section: section.title,
            domain: claim.domain.name,
            horizon: null,
            primaryExpression: claim.text,
            traceabilityReference: claim.semanticKey,
            expressed: true,
            excludedFromFreshness: excluded,
            exclusionReason: section.isMethodology
                ? 'necessary-methodology'
                : medical
                ? 'required-medical-disclosure'
                : '',
          ),
        );
      }
    }

    final timeline = view.lifeTimeline!;
    for (var index = 0; index < timeline.periods.length; index++) {
      final period = timeline.periods[index];
      if (period.isPast) {
        for (final reflection in <(String, String)>[
          ('theme', period.summary),
          ('question', period.whatChanges),
        ]) {
          if (reflection.$2.trim().isEmpty) continue;
          addClaim(
            fixture: fixture,
            allocation: ThaiBetaReportClaimAllocation(
              canonicalId: 'past:$index:${reflection.$1}',
              evidenceKeys: {
                'life-period:${period.phaseName}',
                'age:${period.ageLabel}',
                'theme:${period.keyword}',
              },
              evidenceSignature:
                  '${period.phaseName}|${period.ageLabel}|${period.keyword}',
              evidenceType: 'life-period-reflection',
              confidence: 'reflective-not-biographical',
              role: 'past-${reflection.$1}',
              section: '${period.phaseName} (${period.ageLabel})',
              domain: 'life-period',
              horizon: 'past',
              primaryExpression: reflection.$2,
              traceabilityReference: 'timeline.periods[$index]',
              expressed: true,
            ),
          );
        }
      }
      if (period.isCurrent) {
        for (
          var domainIndex = 0;
          domainIndex < period.lifeDomains.length;
          domainIndex++
        ) {
          final domain = period.lifeDomains[domainIndex];
          addClaim(
            fixture: fixture,
            allocation: ThaiBetaReportClaimAllocation(
              canonicalId: 'current-timeline:$domainIndex:${domain.title}',
              evidenceKeys: domain.evidenceKeys.toSet(),
              evidenceSignature: domain.evidenceKeys.join('|'),
              evidenceType: 'current-life-period',
              confidence: 'supported',
              role: 'current-pressure',
              section: 'ช่วงปัจจุบัน',
              domain: domain.title,
              horizon: 'current',
              primaryExpression: domain.body,
              traceabilityReference:
                  'timeline.periods[$index].lifeDomains[$domainIndex]',
              expressed: true,
            ),
          );
        }
      }
    }

    final prediction = view.futurePrediction!;
    for (
      var windowIndex = 0;
      windowIndex < prediction.windows.length;
      windowIndex++
    ) {
      final window = prediction.windows[windowIndex];
      for (final domain in window.domains) {
        final material = domain.material!;
        addClaim(
          fixture: fixture,
          allocation: ThaiBetaReportClaimAllocation(
            canonicalId:
                'forecast:${material.horizon.name}:${material.domain.name}',
            evidenceKeys: {material.evidenceKey},
            evidenceSignature: material.serialize(),
            evidenceType: material.sourceOwnership,
            confidence: material.band.name,
            role: 'forecast-${plan.roleFor(material.domain).name}',
            section: window.windowLabel,
            domain: material.domain.name,
            horizon: material.horizon.name,
            primaryExpression: domain.body,
            permittedCallback: domain.risk,
            callbackNewInformation:
                '${domain.decisionImpact} ${domain.preparationAction}'.trim(),
            traceabilityReference: material.evidenceKey,
            expressed: true,
          ),
        );
      }
    }
    addClaim(
      fixture: fixture,
      allocation: ThaiBetaReportClaimAllocation(
        canonicalId: 'closing:decision-boundary',
        evidenceKeys: planEvidence,
        evidenceSignature: plan.materialIdentity,
        evidenceType: 'report-level-plan',
        role: 'closing',
        section: 'คำแนะนำปิดท้ายช่วงถัดไป',
        domain: '${plan.primary.name}+${plan.secondary.name}',
        horizon: 'closing',
        primaryExpression: prediction.detailedClosingAdvice,
        traceabilityReference: plan.materialIdentity,
        expressed: true,
      ),
    );

    coverage[fixture] = {
      'materialIdentity': plan.materialIdentity,
      'motifs': [plan.primary.name, plan.secondary.name],
      'horizons': prediction.windows.length,
      'domainsPerHorizon': prediction.windows
          .map((window) => window.domains.length)
          .toList(),
      'complete4x3':
          prediction.windows.length == 3 &&
          prediction.windows.every(
            (window) =>
                window.domains.length == 4 &&
                window.domains
                        .map((domain) => domain.material!.domain)
                        .toSet()
                        .length ==
                    4,
          ),
    };
  }

  final claimLedger = {
    'schema': 'knowme-claim-ledger-v1.5-r4',
    'policy': {
      'domainSignatureBlanketExemptions': false,
      'callbacksRequireNewInformation': true,
      'consumerSystemLabelsAllowed': false,
      'expressedClaimMustAppearInCanonicalWebAndPdf': true,
    },
    'summary': {
      'totalClaims': claims.length,
      'expressedClaims': expressedClaims,
      'unexpressedClaims': unexpressedClaims,
      'freshnessExcludedClaims': freshnessExcludedClaims,
      'freshnessExclusionReasons': _frequency(
        claims
            .where((row) => row['excludedFromFreshness'] == true)
            .map((row) => '${row['exclusionReason']}'),
      ),
    },
    'claims': claims,
  };
  _writeJson(output, 'claim-ledger.json', claimLedger);

  final traceFailures = traceRows
      .where(
        (row) =>
            row['expressed'] == true &&
            (((row['canonicalWeb']! as Map)['found'] != true) ||
                ((row['canonicalPdf']! as Map)['found'] != true)),
      )
      .toList(growable: false);
  final traceability = {
    'schema': 'knowme-claim-render-traceability-v1.5-r4',
    'totalClaims': traceRows.length,
    'expressedClaims': expressedClaims,
    'expressedFoundInCanonicalWebAndPdf':
        expressedClaims - traceFailures.length,
    'expressedPresenceRate': expressedClaims == 0
        ? 1
        : (expressedClaims - traceFailures.length) / expressedClaims,
    'failures': traceFailures,
    'claims': traceRows,
  };
  _writeJson(output, 'claim-render-traceability.json', traceability);

  final units = _consumerUnits(fixtures, webTexts, claims);
  _writeJson(output, 'consumer-unit-audit.json', {
    'schema': 'knowme-consumer-unit-audit-v1.5-r4',
    'definition':
        'Every rendered title or paragraph in canonical Web text. Narrative prose is counted. Static headings, required medical disclosure, evidence boundary, and methodology are excluded with a reason.',
    'summary': {
      'totalUnits': units.length,
      'countedUnits': units.where((unit) => unit['counted'] == true).length,
      'excludedUnits': units.where((unit) => unit['counted'] != true).length,
      'exclusionReasons': _frequency(
        units
            .where((unit) => unit['counted'] != true)
            .map((unit) => '${unit['reason']}'),
      ),
    },
    'units': units,
  });

  final r3Texts = <String, String>{};
  final r3Evidence = Directory(
    '${Directory.current.path}/product-acceptance/thai-narrative-v1.5-r3/evidence',
  );
  for (final fixture in fixtures.keys) {
    final file = File('${r3Evidence.path}/$fixture-web-text.txt');
    if (!file.existsSync()) {
      throw StateError('Missing immutable R3 source: ${file.path}');
    }
    r3Texts[fixture] = file.readAsStringSync();
  }
  final materialIdentities = {
    for (final entry in plans.entries) entry.key: entry.value.materialIdentity,
  };
  final r3Freshness = _freshnessAudit(
    version: 'R3',
    texts: r3Texts,
    materialIdentities: materialIdentities,
  );
  final r4Freshness = _freshnessAudit(
    version: 'R4',
    texts: webTexts,
    materialIdentities: materialIdentities,
  );
  final r3ReuseRate = r3Freshness['exactReuseRate']! as double;
  final r4ReuseRate = r4Freshness['exactReuseRate']! as double;
  final freshnessRateDelta = r3ReuseRate - r4ReuseRate;
  final hookReuse = _hookReuse(fixtures, plans);
  final callbacksWithoutNewInformation = claims.where((row) {
    if (!(row['canonicalId'] as String).startsWith('forecast:')) return false;
    final callback = '${row['callbackNewInformation'] ?? ''}'.trim();
    final primary = '${row['primaryExpression'] ?? ''}'.trim();
    return callback.isEmpty || _normalize(callback) == _normalize(primary);
  }).length;
  final systemHits = _phraseHits(webTexts.values, const [
    'น้ำหนักเด่น',
    'น้ำหนักปานกลาง',
    'น้ำหนักเบา',
    'คาบเกี่ยวรอยต่อ',
  ]);
  final unsupportedBiographyHits = _phraseHits(webTexts.values, const [
    'ตอนเรียนคุณ',
    'ครอบครัวทำให้คุณ',
    'โอกาสจากเครือข่ายจะ',
    'คุณเก็บความคาดหวังไว้เงียบ',
    'คุณถูกผลักให้',
    'ร่างกายและใจถูกใช้จนสุดแรง',
    'คุณต้องแบกงานหลายเรื่อง',
  ]);
  final forbiddenPatternHits = _phraseHits(webTexts.values, const [
    'ใช้ความมั่นคงที่สร้างทีละขั้น',
    'ระยะยาว ให้เก็บ',
    'และต้องยืนยันจากสิ่งที่เกิดซ้ำเพราะไม่มีเวลาเกิด',
    'กดให้เงินพร้อมใช้ยังไม่ถูกเบียดยากขึ้น',
    'เพื่อไม่ให้การพักฟื้นแรงไม่ทัน',
  ]);
  final repeatedPastBoundaryHits = webTexts.values.fold<int>(
    0,
    (total, text) =>
        total + 'นี่เป็นกรอบตั้งคำถาม ไม่ใช่ข้อสรุป'.allMatches(text).length,
  );
  final semicolonHits = webTexts.values.fold<int>(
    0,
    (total, text) => total + ';'.allMatches(text).length,
  );
  final withinReportExactDuplicates = <String, int>{};
  final withinReportNgramPairs = <String, List<Map<String, Object?>>>{};
  for (final entry in fixtures.entries) {
    final bodies = ThaiBetaNarrativeComposer.narrativeView(entry.value)
        .futurePrediction!
        .windows
        .expand((window) => window.domains)
        .map((domain) => domain.body)
        .toList(growable: false);
    final normalized = bodies.map(_normalize).toList(growable: false);
    withinReportExactDuplicates[entry.key] =
        normalized.length - normalized.toSet().length;
    final pairs = <Map<String, Object?>>[];
    for (var left = 0; left < normalized.length; left++) {
      for (var right = left + 1; right < normalized.length; right++) {
        final similarity = _ngramSimilarity(
          normalized[left],
          normalized[right],
        );
        if (similarity >= .72) {
          pairs.add({'left': left, 'right': right, 'similarity': similarity});
        }
      }
    }
    withinReportNgramPairs[entry.key] = pairs;
  }
  _writeJson(output, 'r4-audit-metrics.json', {
    'schema': 'knowme-narrative-v1.5-r4-audit-v1',
    'fixtures': fixtures.length,
    'coverage': coverage,
    'freshness': {
      'denominatorDefinition': r4Freshness['denominatorDefinition'],
      'beforeR3': r3Freshness,
      'afterR4': r4Freshness,
      'absoluteReuseRateReduction': freshnessRateDelta,
      'relativeReuseRateReduction': r3ReuseRate == 0
          ? 0
          : freshnessRateDelta / r3ReuseRate,
    },
    'hookExactReuseAcrossMateriallyDifferentFixtures': hookReuse,
    'withinReportExactDuplicateForecastBodies': withinReportExactDuplicates,
    'withinReportNgramPairsAtOrAbove072': withinReportNgramPairs,
    'callbacksWithoutNewInformation': callbacksWithoutNewInformation,
    'consumerSystemLanguageHits': systemHits,
    'unsupportedBiographyHits': unsupportedBiographyHits,
    'forbiddenRepeatedPatternHits': forbiddenPatternHits,
    'repeatedPastBoundaryHits': repeatedPastBoundaryHits,
    'consumerSemicolonHits': semicolonHits,
    'claimRenderTraceability': {
      'expressedClaims': expressedClaims,
      'failures': traceFailures.length,
      'presenceRate': expressedClaims == 0
          ? 1
          : (expressedClaims - traceFailures.length) / expressedClaims,
    },
    'domainSignatureBlanketExemptions': 0,
    'webPdfCanonicalPairs': fixtures.length,
  });
  _writeJson(output, 'claim-coverage-matrix.json', coverage);

  if (traceFailures.isNotEmpty) {
    throw StateError(
      '${traceFailures.length} expressed claims are absent from canonical output',
    );
  }
  if (r4ReuseRate >= r3ReuseRate ||
      hookReuse['reusedInstances'] != 0 ||
      callbacksWithoutNewInformation != 0 ||
      systemHits != 0 ||
      unsupportedBiographyHits != 0 ||
      forbiddenPatternHits != 0 ||
      repeatedPastBoundaryHits != 0 ||
      semicolonHits != 0 ||
      withinReportExactDuplicates.values.any((count) => count != 0) ||
      withinReportNgramPairs.values.any((pairs) => pairs.isNotEmpty)) {
    throw StateError('R4 consumer narrative acceptance metrics failed');
  }
}

List<Map<String, Object?>> _consumerUnits(
  Map<String, ThaiBetaAnalysis> fixtures,
  Map<String, String> webTexts,
  List<Map<String, Object?>> claims,
) {
  final units = <Map<String, Object?>>[];
  for (final entry in fixtures.entries) {
    final fixture = entry.key;
    final document = ThaiBetaReportExportDocument.fromAnalysis(entry.value);
    final fixtureClaims = claims
        .where((claim) => claim['fixture'] == fixture)
        .toList(growable: false);
    final claimed = <String, Map<String, Object?>>{
      for (final claim in fixtureClaims)
        if ('${claim['primaryExpression']}'.trim().isNotEmpty)
          '${claim['primaryExpression']}'.trim(): claim,
    };
    var index = 0;
    void add({
      required String section,
      required String kind,
      required String text,
      required bool counted,
      required String reason,
      String? claimId,
    }) {
      units.add({
        'fixture': fixture,
        'unitId': '$fixture:${index++}',
        'section': section,
        'kind': kind,
        'text': text,
        'normalizedText': _normalize(text),
        'counted': counted,
        'reason': reason,
        'claimId': claimId,
      });
    }

    add(
      section: 'document',
      kind: 'heading',
      text: document.title,
      counted: false,
      reason: 'static-heading',
    );
    add(
      section: 'document',
      kind: 'subtitle',
      text: document.subtitle,
      counted: false,
      reason: 'static-report-subtitle',
    );
    for (final section in document.sections) {
      final headingClaim = claimed[section.title];
      if (headingClaim != null &&
          headingClaim['canonicalId'] == 'hook:headline') {
        add(
          section: section.title,
          kind: 'hook-headline',
          text: section.title,
          counted: true,
          reason: 'consumer-narrative',
          claimId: '${headingClaim['canonicalId']}',
        );
      } else {
        add(
          section: section.title,
          kind: 'heading',
          text: section.title,
          counted: false,
          reason: 'static-heading',
        );
      }
      for (final paragraph in section.paragraphs) {
        final text = paragraph.trim();
        if (text.isEmpty) continue;
        final claim = claimed[text];
        if (claim != null) {
          final excluded = claim['excludedFromFreshness'] == true;
          add(
            section: section.title,
            kind: '${claim['role']}',
            text: text,
            counted: !excluded,
            reason: excluded
                ? '${claim['exclusionReason']}'
                : 'consumer-narrative',
            claimId: '${claim['canonicalId']}',
          );
          continue;
        }
        final classification = _classifyRenderedParagraph(section.title, text);
        add(
          section: section.title,
          kind: classification.$1,
          text: text,
          counted: classification.$2,
          reason: classification.$3,
        );
      }
    }
    final canonical = webTexts[fixture] ?? '';
    for (final claim in fixtureClaims.where(
      (claim) => claim['expressed'] == true,
    )) {
      if (!canonical.contains('${claim['primaryExpression']}')) {
        throw StateError(
          '$fixture missing consumer unit ${claim['canonicalId']}',
        );
      }
    }
  }
  return units;
}

(String, bool, String) _classifyRenderedParagraph(String section, String text) {
  if (section == ThaiBirthProfileCoreReadingCopy.methodologyTitle ||
      section == 'ที่มาของผลวิเคราะห์') {
    return ('methodology', false, 'necessary-methodology');
  }
  if (section == 'ข้อจำกัด' || text.contains('ไม่มีเวลาเกิด จึงไม่ใช้ลัคนา')) {
    return ('evidence-boundary', false, 'necessary-evidence-boundary');
  }
  if (text == ThaiBirthProfileCoreReadingCopy.medicalDisclaimer ||
      text.contains('ไม่ใช่การวินิจฉัยโรค')) {
    return ('medical-disclosure', false, 'required-medical-disclosure');
  }
  if (section == 'ธีมสำหรับทบทวนอดีต') {
    return ('past-boundary', false, 'single-past-evidence-boundary');
  }
  if (_staticParagraphs.contains(text) || text.length < 18) {
    return ('static-label', false, 'static-label-or-timing');
  }
  return ('consumer-narrative', true, 'consumer-narrative');
}

Map<String, Object?> _freshnessAudit({
  required String version,
  required Map<String, String> texts,
  required Map<String, String> materialIdentities,
}) {
  final instances = <Map<String, String>>[];
  for (final entry in texts.entries) {
    final lines = entry.value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    var excludedTail = false;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (line == ThaiBirthProfileCoreReadingCopy.methodologyTitle ||
          line == 'ที่มาของผลวิเคราะห์' ||
          line == 'ข้อจำกัด') {
        excludedTail = true;
      }
      final hookPosition = index == 4 || line.startsWith('ลายเซ็นของคำอ่าน:');
      final excluded =
          !hookPosition &&
          (excludedTail ||
              _isStaticLine(line) ||
              line == ThaiBirthProfileCoreReadingCopy.medicalDisclaimer ||
              line.contains('ไม่ใช่การวินิจฉัยโรค') ||
              line.contains(
                'ส่วนนี้ใช้ตั้งคำถามกับความทรงจำจริง ไม่ใช่ข้อสรุป',
              ) ||
              line.contains('ไม่มีเวลาเกิด จึงไม่ใช้ลัคนา'));
      if (excluded) continue;
      instances.add({
        'fixture': entry.key,
        'materialIdentity': materialIdentities[entry.key] ?? entry.key,
        'text': line,
        'normalized': _normalize(line),
      });
    }
  }
  final groups = <String, List<Map<String, String>>>{};
  for (final instance in instances) {
    groups.putIfAbsent(instance['normalized']!, () => []).add(instance);
  }
  final reuseGroups = groups.values
      .where((group) {
        final materialGroups = group
            .map((instance) => instance['materialIdentity'])
            .toSet();
        return materialGroups.length > 1;
      })
      .toList(growable: false);
  final reusedInstances = reuseGroups.fold<int>(
    0,
    (total, group) => total + group.length,
  );
  return {
    'version': version,
    'denominatorDefinition':
        'All non-empty canonical rendered lines classified as consumer narrative. Static headings/labels, methodology, required medical disclosure, and evidence-boundary copy are excluded. No domain-signature exemption is used.',
    'instances': instances.length,
    'reusedInstancesAcrossMateriallyDifferentFixtures': reusedInstances,
    'exactReuseRate': instances.isEmpty
        ? 0
        : reusedInstances / instances.length,
    'reuseGroupCount': reuseGroups.length,
    'reuseGroups': reuseGroups
        .map(
          (group) => {
            'text': group.first['text'],
            'occurrences': group
                .map(
                  (instance) => {
                    'fixture': instance['fixture'],
                    'materialIdentity': instance['materialIdentity'],
                  },
                )
                .toList(),
          },
        )
        .toList(),
  };
}

Map<String, Object?> _hookReuse(
  Map<String, ThaiBetaAnalysis> fixtures,
  Map<String, ThaiBetaReportNarrativePlan> plans,
) {
  final units = <Map<String, String>>[];
  for (final entry in fixtures.entries) {
    final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
    units.add({
      'fixture': entry.key,
      'materialIdentity': plans[entry.key]!.materialIdentity,
      'kind': 'headline',
      'text': view.hero.headline,
    });
    units.add({
      'fixture': entry.key,
      'materialIdentity': plans[entry.key]!.materialIdentity,
      'kind': 'body',
      'text': view.hero.summary.split('\n\n').first,
    });
  }
  final groups = <String, List<Map<String, String>>>{};
  for (final unit in units) {
    final key = '${unit['kind']}|${_normalize(unit['text']!)}';
    groups.putIfAbsent(key, () => []).add(unit);
  }
  final reused = groups.values.where(
    (group) => group.map((unit) => unit['materialIdentity']).toSet().length > 1,
  );
  return {
    'instances': units.length,
    'reusedInstances': reused.fold<int>(
      0,
      (total, group) => total + group.length,
    ),
    'groups': reused.toList(),
  };
}

bool _isStaticLine(String line) =>
    _staticParagraphs.contains(line) ||
    _staticHeadings.contains(line) ||
    RegExp(r'^อิทธิพลดาว[^—]+$').hasMatch(line) ||
    RegExp(r'^.+\([0-9]+[–-][0-9]+\)$').hasMatch(line) ||
    (line.length < 18 && !line.contains('คำถาม'));

const _staticHeadings = <String>{
  'KnowMe — รายงานโหราไทย',
  'รายงานฉบับสำหรับอ่านและบันทึกส่วนตัว',
  'ดวงจากวันเกิดของคุณ',
  'สรุปตัวคุณแบบตรง ๆ',
  'การงาน',
  'การเงิน',
  'ความรัก',
  'ความรักและความสัมพันธ์',
  'สุขภาพ',
  'สุขภาพและพลังชีวิต',
  'คำชี้หลักจากพื้นดวง',
  'แผนที่ชีวิต',
  'อดีตของคุณ',
  'ธีมสำหรับทบทวนอดีต',
  'ช่วงปัจจุบัน',
  'คุณอยู่ช่วงไหนของชีวิต',
  'สิ่งที่ต้องตัดสินใจตอนนี้',
  'แนวโน้ม 12 เดือนข้างหน้า',
  'ช่วงชีวิตถัดไป',
  'แนวโน้มระยะยาว',
  'คำแนะนำปิดท้ายช่วงถัดไป',
  'คำทำนายช่วงสำคัญ',
  'รายงานนี้ดูจากอะไร',
  'ที่มาของผลวิเคราะห์',
  'ข้อจำกัด',
};

const _staticParagraphs = <String>{
  'คำอ่านพื้นดวงและจังหวะชีวิตจากวัน เวลา และสถานที่เกิด',
  'คำอ่านพื้นดวงและจังหวะชีวิตจากวันและสถานที่เกิด',
  'ข้อมูลวัน เวลา และสถานที่เกิด',
  'วิธีนับวันทางโหราศาสตร์ไทย',
  'โครงสร้างดวงหลัก',
  'ความหมายและข้อจำกัดของผลลัพธ์',
  'ลองเทียบแต่ละช่วงกับเหตุการณ์และความรู้สึกที่เกิดขึ้นจริง',
  'ดูช่วงที่ผ่านมา ช่วงปัจจุบัน และช่วงข้างหน้า เพื่อเข้าใจจังหวะชีวิตในภาพรวม',
  'ดูภาพรวมของช่วงถัดไป เพื่อเตรียมสิ่งสำคัญไว้ล่วงหน้า',
};

Map<String, int> _frequency(Iterable<String> values) {
  final out = <String, int>{};
  for (final value in values.where((value) => value.trim().isNotEmpty)) {
    out.update(value, (count) => count + 1, ifAbsent: () => 1);
  }
  return out;
}

int _phraseHits(Iterable<String> texts, List<String> phrases) =>
    texts.fold<int>(
      0,
      (total, text) =>
          total +
          phrases.fold<int>(
            0,
            (subtotal, phrase) => subtotal + phrase.allMatches(text).length,
          ),
    );

int _occurrences(String haystack, String needle) {
  final value = needle.trim();
  return value.isEmpty ? 0 : value.allMatches(haystack).length;
}

String _normalize(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[\-–—:;,.!?()•]'), '')
    .toLowerCase();

double _ngramSimilarity(String left, String right) {
  Set<String> grams(String value) {
    const width = 12;
    if (value.length < width) return {value};
    return {
      for (var index = 0; index <= value.length - width; index++)
        value.substring(index, index + width),
    };
  }

  final leftGrams = grams(left);
  final rightGrams = grams(right);
  final union = leftGrams.union(rightGrams);
  if (union.isEmpty) return 0;
  return leftGrams.intersection(rightGrams).length / union.length;
}

void _writeJson(Directory output, String name, Object value) {
  final json = const JsonEncoder.withIndent('  ').convert(value);
  File('${output.path}/$name').writeAsStringSync('$json\n', encoding: utf8);
}
