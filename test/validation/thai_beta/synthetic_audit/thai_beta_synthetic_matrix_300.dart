import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

class ThaiBetaSyntheticCase {
  const ThaiBetaSyntheticCase({
    required this.id,
    required this.input,
    required this.boundary,
  });

  final String id;
  final ThaiBetaInput input;
  final bool boundary;
}

/// The canonical deterministic 300-case matrix shared by quality and runtime
/// parity gates. Runtime harnesses must use this builder rather than copying
/// or regenerating their own inputs.
abstract final class ThaiBetaSyntheticMatrix {
  static const seed = 20260803;
  static const locations = <(String, String)>[
    ('กรุงเทพมหานคร', 'bangkok'),
    ('เชียงใหม่', 'chiang mai'),
    ('ขอนแก่น', 'khon kaen'),
    ('ภูเก็ต', 'phuket'),
    ('สงขลา', 'songkhla'),
    ('อุบลราชธานี', 'ubon ratchathani'),
  ];
  static const times = <(int, int)>[
    (0, 0),
    (0, 1),
    (2, 0),
    (5, 29),
    (5, 30),
    (5, 31),
    (11, 59),
    (12, 0),
    (12, 1),
    (18, 0),
    (23, 0),
    (23, 59),
  ];
  static final boundaries = <DateTime>[
    DateTime(1952, 2, 29),
    DateTime(1960, 12, 31),
    DateTime(1961, 1, 1),
    DateTime(1972, 4, 5),
    DateTime(1972, 4, 6),
    DateTime(1980, 2, 29),
    DateTime(1988, 1, 31),
    DateTime(1990, 4, 30),
    DateTime(1999, 12, 31),
    DateTime(2000, 1, 1),
    DateTime(2000, 2, 29),
    DateTime(2004, 2, 29),
    DateTime(2008, 12, 31),
    DateTime(2009, 1, 1),
    DateTime(2012, 2, 29),
    DateTime(2016, 7, 31),
    DateTime(2020, 2, 29),
    DateTime(2020, 12, 31),
    DateTime(2021, 1, 1),
    DateTime(2024, 2, 29),
    DateTime(2024, 3, 1),
    DateTime(2025, 12, 31),
    DateTime(2026, 1, 1),
    DateTime(2026, 7, 31),
  ];

  static List<ThaiBetaSyntheticCase> build() => List.generate(300, (index) {
    final id = 'S${(index + 1).toString().padLeft(3, '0')}';
    // One in four cases is unknown-time. Offset 2 keeps the explicit
    // 00:00, 00:01, sunrise-neighbour and 23:59 boundaries in known-time
    // cases while preserving the required 225/75 split.
    final unknown = index % 4 == 2;
    final boundary = index < boundaries.length;
    final date = boundary ? boundaries[index] : _validDate(index);
    final time = times[index % times.length];
    final location = locations[index % locations.length];
    return ThaiBetaSyntheticCase(
      id: id,
      boundary: boundary,
      input: ThaiBetaInput(
        firstName: id,
        lastName: 'Synthetic',
        birthDate: date,
        birthHour: unknown ? null : time.$1,
        birthMinute: unknown ? 0 : time.$2,
        birthTimeUnknown: unknown,
        province: location.$1,
        provinceKey: location.$2,
      ),
    );
  });

  static DateTime _validDate(int index) {
    // Break the 228-row joint cycle of year/month/location so every synthetic
    // case exercises distinct consumer material rather than differing only in
    // birth-date metadata.
    final materialCycle = index ~/ 228;
    final year = 1950 + ((index * 37 + materialCycle + seed) % 76);
    final month = 1 + (index % 12);
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = 1 + ((index * 11 + seed) % lastDay);
    return DateTime(year, month, day);
  }
}
