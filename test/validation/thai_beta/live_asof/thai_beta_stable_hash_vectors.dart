import 'package:knowme/features/astrology/thai/mirror/thai_mirror_stable_hash.dart';

typedef StableStringVector = ({String label, String input, int expected});
typedef StableStringsVector = ({
  String label,
  List<String> inputs,
  int expected,
});
typedef StableArithmeticVector = ({
  String label,
  int value,
  int unsigned32,
  int signed32,
  int multiply32,
  int exactXor,
  int exactModulo7,
});

final stableStringVectors = <StableStringVector>[
  (label: 'empty', input: '', expected: 1),
  (label: 'ascii', input: 'KnowMe', expected: 67511776),
  (label: 'thai', input: 'รู้จักตัวเอง', expected: 1037061087),
  (label: 'thai-combining-marks', input: 'กํา', expected: 165550981),
  (label: 'unicode-bmp', input: '漢字', expected: 801637601),
  (label: 'emoji-surrogate-pair', input: '🪷✨', expected: 117797691),
  (
    label: 'long-string',
    input: List.filled(64, 'KnowMe-ไทย-🪷').join(),
    expected: 364781858,
  ),
  (label: 'theme-persistence', input: 'persistence', expected: 961841110),
  (label: 'theme-builder', input: 'builder', expected: 504794108),
  (
    label: 'theme-develop-patience',
    input: 'develop_patience',
    expected: 56504523,
  ),
  (label: 'lagna-aquarius', input: 'lagna_aquarius', expected: 804501464),
  (label: 'lagna-aries', input: 'lagna_aries', expected: 25355652),
];

final stableStringsVectors = <StableStringsVector>[
  (label: 'multiple-empty', inputs: const [], expected: 1),
  (
    label: 'multiple-single',
    inputs: const ['persistence'],
    expected: 577084451,
  ),
  (
    label: 'multiple-theme-order-a',
    inputs: const ['persistence', 'builder'],
    expected: 1068502878,
  ),
  (
    label: 'multiple-theme-order-b',
    inputs: const ['builder', 'persistence'],
    expected: 668601578,
  ),
  (
    label: 'multiple-repeated',
    inputs: const ['persistence', 'persistence'],
    expected: 29881152,
  ),
  (
    label: 'multiple-lagna-domain-slot',
    inputs: const ['lagna_aquarius', 'career', 'current'],
    expected: 30805547,
  ),
  (
    label: 'multiple-real-selection-parts',
    inputs: const ['lagna_aquarius', 'career', 'current', 'persistence'],
    expected: 98011434,
  ),
];

final stableArithmeticVectors = <StableArithmeticVector>[
  (
    label: 'zero',
    value: 0,
    unsigned32: 0,
    signed32: 0,
    multiply32: 0,
    exactXor: 28924034132,
    exactModulo7: 0,
  ),
  (
    label: 'one',
    value: 1,
    unsigned32: 1,
    signed32: 1,
    multiply32: 2654435761,
    exactXor: 28924034133,
    exactModulo7: 0,
  ),
  (
    label: 'signed-max',
    value: 0x7FFFFFFF,
    unsigned32: 0x7FFFFFFF,
    signed32: 0x7FFFFFFF,
    multiply32: 3788015183,
    exactXor: 29058024363,
    exactModulo7: 6,
  ),
  (
    label: 'sign-bit',
    value: 0x80000000,
    unsigned32: 0x80000000,
    signed32: -2147483648,
    multiply32: 0x80000000,
    exactXor: 26776550484,
    exactModulo7: 6,
  ),
  (
    label: 'unsigned-max',
    value: 0xFFFFFFFF,
    unsigned32: 0xFFFFFFFF,
    signed32: -1,
    multiply32: 1640531535,
    exactXor: 26910540715,
    exactModulo7: 5,
  ),
  (
    label: 'signed-min',
    value: -2147483648,
    unsigned32: 0x80000000,
    signed32: -2147483648,
    multiply32: 0x80000000,
    exactXor: -29058024364,
    exactModulo7: 6,
  ),
  (
    label: 'overflow-wrap',
    value: 0x100000001,
    unsigned32: 1,
    signed32: 1,
    multiply32: 2654435761,
    exactXor: 33219001429,
    exactModulo7: 6,
  ),
  (
    label: 'mixed-bits',
    value: 0x12345678,
    unsigned32: 0x12345678,
    signed32: 0x12345678,
    multiply32: 4141252856,
    exactXor: 28692572716,
    exactModulo7: 5,
  ),
];

Map<String, Object?> evaluateStableHashVectors() => {
  'schema': 'knowme-stable-hash-v1',
  'stringVectors': [
    for (final vector in stableStringVectors)
      {
        'label': vector.label,
        'expected': vector.expected,
        'actual': ThaiMirrorStableHash.string(vector.input),
      },
  ],
  'multipleStringVectors': [
    for (final vector in stableStringsVectors)
      {
        'label': vector.label,
        'expected': vector.expected,
        'actual': ThaiMirrorStableHash.strings(vector.inputs),
      },
  ],
  'arithmeticVectors': [
    for (final vector in stableArithmeticVectors)
      {
        'label': vector.label,
        'unsigned32': {
          'expected': vector.unsigned32,
          'actual': ThaiMirrorStableHash.unsigned32(vector.value),
        },
        'signed32': {
          'expected': vector.signed32,
          'actual': ThaiMirrorStableHash.signed32(vector.value),
        },
        'multiply32': {
          'expected': vector.multiply32,
          'actual': ThaiMirrorStableHash.multiply32(vector.value, 2654435761),
        },
        'exactXor': {
          'expected': vector.exactXor,
          'actual': ThaiMirrorStableHash.exactXor(28924034132, vector.value),
        },
        'exactModulo7': {
          'expected': vector.exactModulo7,
          'actual': ThaiMirrorStableHash.exactXorProductModulo(
            left: 28924034132,
            value: vector.value,
            multiplier: 2654435761,
            modulus: 7,
          ),
        },
      },
  ],
};
