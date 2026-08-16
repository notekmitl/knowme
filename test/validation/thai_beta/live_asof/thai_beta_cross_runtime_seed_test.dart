import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_stable_hash.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  test(
    'stable presenter seed and accepted output are cross-runtime invariant',
    () {
      final analysis = ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Acceptance',
          lastName: 'Fixture',
          birthDate: DateTime(1982, 6, 6),
          birthHour: 0,
          birthMinute: 35,
          province: 'เชียงใหม่',
          provinceKey: 'chiang_mai',
        ),
        startedAt: DateTime(2026, 8, 16, 16, 15, 15, 572),
        asOf: DateTime(2026, 8, 16, 16, 19, 44, 454, 535),
      );
      expect(analysis.isSuccess, isTrue);
      final mirror = analysis.pipelineResult!.mirrorResult!;
      final topThemeIds = mirror.topThemes
          .map((theme) => theme.themeId)
          .toList();
      final seen = <String>{};
      final allThemeIds = <String>[];
      void add(Iterable<String> ids) {
        for (final id in ids) {
          if (seen.add(id)) allThemeIds.add(id);
        }
      }

      add(topThemeIds);
      final themeScores = <double>[];
      for (final sectionId in ThaiMirrorSectionId.values) {
        final section = mirror.sectionById(sectionId);
        if (section == null) continue;
        add(section.supportingThemes.map((theme) => theme.themeId));
        themeScores.addAll(
          section.supportingThemes.map((theme) => theme.score),
        );
      }
      themeScores.addAll(mirror.topThemes.map((theme) => theme.score));
      final lagnaKey = mirror.profileContext.lagnaKey;
      var presenterSeed = 0;
      for (var i = 0; i < allThemeIds.length; i++) {
        presenterSeed ^= ThaiMirrorStableHash.string(allThemeIds[i]) * (i + 17);
      }
      for (var i = 0; i < themeScores.length; i++) {
        presenterSeed ^= (themeScores[i] * 10000).round() * (i + 1);
      }
      if (lagnaKey != null && lagnaKey.isNotEmpty) {
        presenterSeed ^= ThaiMirrorStableHash.string(lagnaKey) * 29;
      }
      if (presenterSeed == 0 && topThemeIds.isNotEmpty) {
        presenterSeed = ThaiMirrorStableHash.string(topThemeIds.first);
      }

      final text = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
      ).fullPlainText;
      final lines = text.split('\n');
      String matching(String value) =>
          lines.firstWhere((line) => line.contains(value), orElse: () => '');
      final isCompiledJavaScript = identical(1, 1.0);
      final hasProductionMismatch =
          text.contains(
            'ด้านการเงินคุณต้องคิดเรื่องเก็บเงินและความมั่นคงก่อนเรื่องอื่น',
          ) &&
          text.contains('ต่อไปงานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป');
      final hasFrozenAcceptance =
          text.contains(
            'ด้านการเงินคุณอยากใช้เงินวันนี้ แต่ยังต้องเก็บเพื่อแผนระยะยาว',
          ) &&
          text.contains('ต่อไปงานและหน้าที่บังคับให้คุณจัดลำดับชีวิตใหม่');
      expect(hasProductionMismatch, isFalse);
      expect(hasFrozenAcceptance, isTrue);

      final output = {
        'schema': 'knowme-v15-cross-runtime-seed-post-repair-v1',
        'runtime': isCompiledJavaScript ? 'compiled-javascript' : 'dart-vm',
        'presenterSeed': presenterSeed,
        'orderedThemeIds': allThemeIds,
        'topThemeIds': topThemeIds,
        'themeScores': themeScores,
        'lagnaKey': lagnaKey,
        'stringHashCodes': {
          for (final value in {...allThemeIds, ?lagnaKey})
            value: value.hashCode,
        },
        'stableStringHashes': {
          for (final value in {...allThemeIds, ?lagnaKey})
            value: ThaiMirrorStableHash.string(value),
        },
        'canonicalTextSha256': sha256.convert(utf8.encode(text)).toString(),
        'reportHash': analysis.reportHash,
        'financeLine': matching('ด้านการเงิน'),
        'nextTransitionLine': matching('ต่อไปงาน'),
        'hasProductionMismatch': hasProductionMismatch,
        'hasFrozenAcceptance': hasFrozenAcceptance,
      };
      // Kept in VM and Chrome raw logs for an exact cross-runtime comparison.
      // ignore: avoid_print
      print(const JsonEncoder.withIndent('  ').convert(output));
    },
  );
}
