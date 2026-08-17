import 'package:knowme/features/thai_beta/domain/thai_beta_canonical_degree.dart';

const s008VmRawDegree = 102.39560244592322;
const s008ChromeRawDegree = 102.39560244592323;

const canonicalDegreeVectors = <({String label, double? input, int? expected})>[
  (label: 'null', input: null, expected: null),
  (label: 'zero', input: 0, expected: 0),
  (label: 'negative-zero', input: -0.0, expected: 0),
  (label: 's008-vm-raw', input: s008VmRawDegree, expected: 102395602446),
  (
    label: 's008-chrome-raw',
    input: s008ChromeRawDegree,
    expected: 102395602446,
  ),
  (
    label: 's008-adjacent-lower',
    input: 102.39560244592321,
    expected: 102395602446,
  ),
  (
    label: 'larger-than-precision',
    input: 102.395602447,
    expected: 102395602447,
  ),
  (label: 'below-sign-boundary', input: 29.9999999994, expected: 29999999999),
  (label: 'above-sign-boundary', input: 29.9999999996, expected: 30000000000),
  (label: 'exact-sign-boundary', input: 30, expected: 30000000000),
  (label: 'full-turn', input: 360, expected: 0),
  (label: 'above-full-turn', input: 721.5, expected: 1500000000),
  (label: 'negative-wrap', input: -1.25, expected: 358750000000),
  (label: 'below-full-turn', input: 359.9999999994, expected: 359999999999),
  (label: 'rounds-to-full-turn', input: 359.9999999996, expected: 0),
];

Map<String, Object?> evaluateCanonicalDegreeVectors() => {
  'schema': 'knowme-canonical-degree-v1',
  'unitsPerDegree': ThaiBetaCanonicalDegree.unitsPerDegree,
  'unitsPerTurn': ThaiBetaCanonicalDegree.unitsPerTurn,
  'maxJavaScriptSafeInteger': ThaiBetaCanonicalDegree.maxJavaScriptSafeInteger,
  'isJavaScriptSafe': ThaiBetaCanonicalDegree.isJavaScriptSafe,
  'vectors': [
    for (final vector in canonicalDegreeVectors)
      {
        'label': vector.label,
        'expected': vector.expected,
        'actual': ThaiBetaCanonicalDegree.fromDegrees(vector.input),
      },
  ],
};
