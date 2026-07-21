import '../../foundation/v2/models/thai_chart.dart';
import '../constants/thai_signal_extractor_version.dart';
import '../models/thai_signal.dart';
import '../models/thai_signal_evidence.dart';
import '../models/thai_signal_fact_type.dart';
import '../models/thai_signal_provenance.dart';
import '../models/thai_signal_source.dart';

/// Extracts whole-sign house structural signals from [ThaiChart].
abstract final class HouseSignalExtractor {
  static const houseSignConfidenceWeight = 0.70;
  static const houseLordConfidenceWeight = 0.65;

  static List<ThaiSignal> extract(ThaiChart chart) {
    if (chart.houses.isEmpty) {
      return const [];
    }

    final provenance = ThaiSignalProvenance(
      engineVersion: chart.metadata.engineVersion,
      extractorVersion: ThaiSignalExtractorContract.extractorVersion,
      enginePath: const ['house'],
      requiresBirthTime: true,
    );

    final signals = <ThaiSignal>[];

    for (final house in chart.houses) {
      signals.add(
        ThaiSignal(
          signalId:
              'house_${house.houseNumber}_sign_${_signSuffix(house.signKey)}',
          source: ThaiSignalSource.house,
          factType: ThaiSignalFactType.houseSign,
          evidence: ThaiSignalEvidence(
            factKeys: [
              'house:${house.houseNumber}',
              'sign:${house.signKey}',
            ],
            displayEn:
                'House ${house.houseNumber} sign: ${house.signKey}',
            displayTh:
                'เรือนที่ ${house.houseNumber}: ${house.signKey}',
            auditRef: 'chart.houses[${house.houseNumber - 1}].signKey',
          ),
          confidenceWeight: houseSignConfidenceWeight,
          contentKeyRefs: [house.signKey],
          provenance: provenance,
          facts: {
            'houseNumber': house.houseNumber.toString(),
            'signKey': house.signKey,
          },
        ),
      );

      signals.add(
        ThaiSignal(
          signalId:
              'house_${house.houseNumber}_lord_${_lordSuffix(house.lordKey)}',
          source: ThaiSignalSource.house,
          factType: ThaiSignalFactType.houseLord,
          evidence: ThaiSignalEvidence(
            factKeys: [
              'house:${house.houseNumber}',
              'lord:${house.lordKey}',
            ],
            displayEn:
                'House ${house.houseNumber} lord: ${house.lordKey}',
            displayTh:
                'เจ้าเรือนที่ ${house.houseNumber}: ${house.lordKey}',
            auditRef: 'chart.houses[${house.houseNumber - 1}].lordKey',
          ),
          confidenceWeight: houseLordConfidenceWeight,
          contentKeyRefs: [house.lordKey],
          provenance: provenance,
          facts: {
            'houseNumber': house.houseNumber.toString(),
            'lordKey': house.lordKey,
          },
        ),
      );
    }

    return List<ThaiSignal>.unmodifiable(signals);
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
