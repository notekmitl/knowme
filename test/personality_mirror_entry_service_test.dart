import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';

void main() {
  group('PersonalityMirrorEntryService gate rules', () {
    test('canOpenMirror requires at least two primary lens groups', () {
      expect(
        PersonalityMirrorEntryService.canOpenMirror(_coverage(
          hasMbti: true,
        )),
        isFalse,
      );
      expect(
        PersonalityMirrorEntryService.canOpenMirror(_coverage(
          hasMbti: true,
          hasBigFive: true,
        )),
        isTrue,
      );
      expect(
        PersonalityMirrorEntryService.canOpenMirror(_coverage(
          hasMbti: true,
          hasEq: true,
        )),
        isTrue,
      );
      expect(
        PersonalityMirrorEntryService.canOpenMirror(_coverage(
          hasBigFive: true,
          hasEq: true,
        )),
        isTrue,
      );
    });

    test('canShowFullExperience requires all three primary lens groups', () {
      expect(
        PersonalityMirrorEntryService.canShowFullExperience(_coverage(
          hasMbti: true,
          hasBigFive: true,
        )),
        isFalse,
      );
      expect(
        PersonalityMirrorEntryService.canShowFullExperience(_coverage(
          hasMbti: true,
          hasBigFive: true,
          hasEq: true,
        )),
        isTrue,
      );
    });

    test('primaryLensCount matches lens groups', () {
      expect(
        PersonalityMirrorEntryService.primaryLensCount(_coverage(
          hasMbti: true,
        )),
        1,
      );
      expect(
        PersonalityMirrorEntryService.primaryLensCount(_coverage(
          hasMbti: true,
          hasBigFive: true,
          hasEq: true,
        )),
        3,
      );
    });

    test('tileStatus maps to locked, partial, and ready', () {
      expect(
        PersonalityMirrorEntryState.fromCoverage(_coverage(hasMbti: true))
            .tileStatus,
        PersonalityMirrorTileStatus.locked,
      );
      expect(
        PersonalityMirrorEntryState.fromCoverage(_coverage(
          hasMbti: true,
          hasBigFive: true,
        )).tileStatus,
        PersonalityMirrorTileStatus.partial,
      );
      expect(
        PersonalityMirrorEntryState.fromCoverage(_coverage(
          hasMbti: true,
          hasBigFive: true,
          hasEq: true,
        )).tileStatus,
        PersonalityMirrorTileStatus.ready,
      );
    });
  });
}

PersonalityCoverage _coverage({
  bool hasMbti = false,
  bool hasBigFive = false,
  bool hasEq = false,
}) {
  final available = <PersonalityLensId>[];
  if (hasMbti) available.add(PersonalityLensId.mbti);
  if (hasBigFive) available.add(PersonalityLensId.bigFive);
  if (hasEq) available.add(PersonalityLensId.eqAwareness);

  var weighted = 0.0;
  if (hasMbti) weighted += PersonalityMirrorWeights.mbti;
  if (hasBigFive) weighted += PersonalityMirrorWeights.bigFive;
  if (hasEq) weighted += PersonalityMirrorWeights.eqModuleShare;

  return PersonalityCoverage(
    availableLensIds: available,
    missingLensIds: PersonalityLensId.all
        .where((id) => !available.contains(id))
        .toList(),
    eqModulesCompleted: hasEq ? 1 : 0,
    eqModulesExpected: PersonalityLensId.eqLenses.length,
    weightedCoverage: weighted,
  );
}
