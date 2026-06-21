import '../../foundation/engines/mahabhuta_engine.dart';
import '../../foundation/engines/myanmar_seven_engine.dart';
import '../../foundation/models/profile_warning.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../foundation/v2/contracts/thai_v2_engine_contract.dart';
import '../constants/thai_signal_extractor_version.dart';
import '../models/thai_signal.dart';
import '../models/thai_signal_evidence.dart';
import '../models/thai_signal_fact_type.dart';
import '../models/thai_signal_provenance.dart';
import '../models/thai_signal_source.dart';

class SevenNumbersSignalAdapterResult {
  const SevenNumbersSignalAdapterResult({
    required this.signals,
    this.warnings = const [],
  });

  final List<ThaiSignal> signals;
  final List<ProfileWarning> warnings;
}

/// Adapts Myanmar Seven and Mahabhuta engine output into structural signals.
///
/// Calls V1 engines directly from [ThaiBirthData] — results are not stored on
/// [ThaiChart].
abstract final class SevenNumbersSignalAdapter {
  static const sevenNumbersConfidenceWeight = 0.50;

  static SevenNumbersSignalAdapterResult extract(ThaiBirthData birthData) {
    final myanmar = MyanmarSevenEngine.calculate(birthData);
    final mahabhuta = MahabhutaEngine.calculate(birthData);

    final provenance = ThaiSignalProvenance(
      engineVersion: ThaiV2EngineContract.engineVersion,
      extractorVersion: ThaiSignalExtractorContract.extractorVersion,
      enginePath: const ['sevenNumbers'],
      requiresBirthTime: false,
    );

    final signals = <ThaiSignal>[];

    for (final key in myanmar.myanmarKeys) {
      signals.add(
        ThaiSignal(
          signalId: key,
          source: ThaiSignalSource.sevenNumbers,
          factType: ThaiSignalFactType.myanmarPosition,
          evidence: ThaiSignalEvidence(
            factKeys: ['myanmar:$key'],
            displayEn: 'Myanmar seven: $key',
            displayTh: 'เลข 7 ตัว: $key',
          ),
          confidenceWeight: sevenNumbersConfidenceWeight,
          contentKeyRefs: [key],
          provenance: provenance,
          facts: {'contentKey': key},
        ),
      );
    }

    for (final key in mahabhuta.mahabhutaPositionKeys) {
      signals.add(
        ThaiSignal(
          signalId: key,
          source: ThaiSignalSource.sevenNumbers,
          factType: ThaiSignalFactType.mahabhutaPosition,
          evidence: ThaiSignalEvidence(
            factKeys: ['mahabhuta:$key'],
            displayEn: 'Mahabhuta position: $key',
            displayTh: 'มหาภูติ: $key',
          ),
          confidenceWeight: sevenNumbersConfidenceWeight,
          contentKeyRefs: [key],
          provenance: provenance,
          facts: {'contentKey': key},
        ),
      );
    }

    final warnings = <ProfileWarning>[
      ...myanmar.warnings,
      ...mahabhuta.warnings,
    ];

    return SevenNumbersSignalAdapterResult(
      signals: List<ThaiSignal>.unmodifiable(signals),
      warnings: List<ProfileWarning>.unmodifiable(warnings),
    );
  }
}
