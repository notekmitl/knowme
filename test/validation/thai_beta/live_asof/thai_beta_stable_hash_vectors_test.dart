import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_stable_hash.dart';

import 'thai_beta_stable_hash_vectors.dart';

void main() {
  group('KnowMe Stable Hash v1 fixed vectors', () {
    test('UTF-16 string vectors are exact', () {
      for (final vector in stableStringVectors) {
        expect(
          ThaiMirrorStableHash.string(vector.input),
          vector.expected,
          reason: vector.label,
        );
      }
    });

    test('ordered multiple-string vectors are exact', () {
      for (final vector in stableStringsVectors) {
        expect(
          ThaiMirrorStableHash.strings(vector.inputs),
          vector.expected,
          reason: vector.label,
        );
      }
    });

    test('32-bit and exact wide-product vectors are exact', () {
      for (final vector in stableArithmeticVectors) {
        expect(
          ThaiMirrorStableHash.unsigned32(vector.value),
          vector.unsigned32,
          reason: '${vector.label}/unsigned32',
        );
        expect(
          ThaiMirrorStableHash.signed32(vector.value),
          vector.signed32,
          reason: '${vector.label}/signed32',
        );
        expect(
          ThaiMirrorStableHash.multiply32(vector.value, 2654435761),
          vector.multiply32,
          reason: '${vector.label}/multiply32',
        );
        expect(
          ThaiMirrorStableHash.exactXor(28924034132, vector.value),
          vector.exactXor,
          reason: '${vector.label}/exactXor',
        );
        expect(
          ThaiMirrorStableHash.exactXorProductModulo(
            left: 28924034132,
            value: vector.value,
            multiplier: 2654435761,
            modulus: 7,
          ),
          vector.exactModulo7,
          reason: '${vector.label}/exactModulo7',
        );
      }
    });
  });
}
