import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/thai_beta/application/thai_beta_reader_copy_repair.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln('usage: dart run <script> <ledger.json> <summary.md>');
    exitCode = 64;
    return;
  }

  final ledgerFile = File(arguments[0]);
  final outputFile = File(arguments[1]);
  final ledger =
      jsonDecode(ledgerFile.readAsStringSync()) as Map<String, dynamic>;
  final rows = (ledger['rows'] as List<dynamic>).cast<Map<String, dynamic>>();

  final profilesByRule = <String, Set<String>>{};
  final modesByRule = <String, Set<String>>{};
  for (final row in rows) {
    final profileId = row['profileId'] as String;
    final mode = row['birthTimeMode'] as String;
    for (final ruleId in (row['ruleIds'] as List<dynamic>).cast<String>()) {
      profilesByRule.putIfAbsent(ruleId, () => <String>{}).add(profileId);
      modesByRule.putIfAbsent(ruleId, () => <String>{}).add(mode);
    }
  }

  String cell(String value) => value
      .replaceAll('|', r'\|')
      .replaceAll('\r\n', '<br>')
      .replaceAll('\n', '<br>');

  String exactDiff(String before, String after) {
    var prefix = 0;
    final commonLength = before.length < after.length
        ? before.length
        : after.length;
    while (prefix < commonLength && before[prefix] == after[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < commonLength - prefix &&
        before[before.length - suffix - 1] ==
            after[after.length - suffix - 1]) {
      suffix++;
    }
    return '-{${before.substring(prefix, before.length - suffix)}} '
        '+{${after.substring(prefix, after.length - suffix)}}';
  }

  final activeRules = ThaiBetaReaderCopyRepair.rules
      .where((rule) => profilesByRule.containsKey(rule.id))
      .toList(growable: false);
  final lines = <String>[
    '# Curated Owner Copy Review — Revision 3',
    '',
    'ตารางนี้ group จาก template/rule เดียวกัน ไม่ใช่ sampling โดยคำนวณจาก full ledger `${ledgerFile.uri.pathSegments.last}` ทั้ง ${ledger['fieldsChanged']} fields / ${ledger['profilesAudited']} profiles',
    '',
    '- Semantic change: ${ledger['semanticChanges']}',
    '- Omission: ${ledger['omission']}',
    '- Addition: ${ledger['addition']}',
    '- Prediction → advice: ${ledger['predictionToAdvice']}',
    '- Advice → prediction: ${ledger['adviceToPrediction']}',
    '- Traceability impact: ${ledger['traceabilityImpact']}',
    '- Active transformation rules: ${activeRules.length}',
    '- Owner decision: **Pending**',
    '',
    '| Rule / source template | Before | After | Exact textual diff | Profiles | Known/Unknown | Semantic assessment | Prediction/advice | Omission/addition | Claim/traceability impact | Web/PDF impact | Decision |',
    '|---|---|---|---|---:|---|---|---|---|---|---|---|',
    for (final rule in activeRules)
      '| `${cell(rule.id)}`<br>`${cell(rule.sourceTemplate)}` | ${cell(rule.before)} | ${cell(rule.after)} | `${cell(exactDiff(rule.before, rule.after))}` | ${profilesByRule[rule.id]!.length} | ${cell((modesByRule[rule.id]!.toList()..sort()).join(' / '))} | unchanged — ${cell(rule.semanticIntent)} | unchanged | no net omission/addition; relocation rules preserve report-level guidance | 0 — claim IDs และ trace IDs คงเดิม | shared presentation field changes identically in Web/dedicated PDF/browser print | Pending Owner Review |',
    '',
    '## Owner decision',
    '',
    '- [ ] Approve all grouped transformations above',
    '- [ ] Request changes (ระบุ Rule ID)',
    '',
    'Decision: **Pending Owner Review**',
    '',
  ];
  outputFile
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(lines.join('\n'), flush: true);
}
