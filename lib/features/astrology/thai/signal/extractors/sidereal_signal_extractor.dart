import '../../foundation/v2/models/thai_chart.dart';
import '../constants/thai_signal_extractor_version.dart';
import '../models/thai_signal.dart';
import '../models/thai_signal_evidence.dart';
import '../models/thai_signal_fact_type.dart';
import '../models/thai_signal_provenance.dart';
import '../models/thai_signal_source.dart';

/// Extracts sidereal lagna structural signals from [ThaiChart].
abstract final class SiderealSignalExtractor {
  static const lagnaConfidenceWeight = 0.95;

  static List<ThaiSignal> extract(ThaiChart chart) {
    final lagna = chart.lagna;
    if (lagna == null) {
      return const [];
    }

    final provenance = ThaiSignalProvenance(
      engineVersion: chart.metadata.engineVersion,
      extractorVersion: ThaiSignalExtractorContract.extractorVersion,
      enginePath: const ['sidereal'],
      requiresBirthTime: true,
    );

    return [
      ThaiSignal(
        signalId: 'lagna_sign_${_signSuffix(lagna.signKey)}',
        source: ThaiSignalSource.sidereal,
        factType: ThaiSignalFactType.lagnaSign,
        evidence: ThaiSignalEvidence(
          factKeys: ['lagna:${lagna.signKey}'],
          displayEn: 'Lagna sign: ${lagna.signKey}',
          displayTh: 'ลัคนา: ${lagna.signKey}',
          auditRef: 'chart.lagna.signKey',
        ),
        confidenceWeight: lagnaConfidenceWeight,
        contentKeyRefs: [lagna.signKey],
        provenance: provenance,
        facts: {
          'signKey': lagna.signKey,
          'signIndex': lagna.signIndex.toString(),
        },
      ),
      ThaiSignal(
        signalId: 'lagna_lord_${_lordSuffix(lagna.lordKey)}',
        source: ThaiSignalSource.sidereal,
        factType: ThaiSignalFactType.lagnaLord,
        evidence: ThaiSignalEvidence(
          factKeys: ['lagnaLord:${lagna.lordKey}'],
          displayEn: 'Lagna lord: ${lagna.lordKey}',
          displayTh: 'เจ้าเรือนลัคนา: ${lagna.lordKey}',
          auditRef: 'chart.lagna.lordKey',
        ),
        confidenceWeight: lagnaConfidenceWeight,
        contentKeyRefs: [lagna.lordKey],
        provenance: provenance,
        facts: {
          'lordKey': lagna.lordKey,
          'signKey': lagna.signKey,
        },
      ),
    ];
  }

  static String _signSuffix(String signKey) {
    const prefix = 'lagna_';
    return signKey.substring(prefix.length);
  }

  static String _lordSuffix(String lordKey) {
    const prefix = 'lagna_lord_';
    return lordKey.substring(prefix.length);
  }
}
