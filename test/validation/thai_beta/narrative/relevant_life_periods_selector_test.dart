import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/relevant_life_periods_selector.dart';

class _P {
  const _P(this.id, {this.isCurrent = false, this.isPast = false});
  final String id;
  final bool isCurrent;
  final bool isPast;
}

void main() {
  group('RelevantLifePeriodsSelector', () {
    test('V121-1 mid list → previous/current/next', () {
      final all = [
        const _P('a', isPast: true),
        const _P('b', isPast: true),
        const _P('c', isCurrent: true),
        const _P('d'),
        const _P('e'),
      ];
      final sourceCopy = List<_P>.from(all);
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.map((p) => p.id), ['b', 'c', 'd']);
      expect(identical(all, selected), isFalse);
      expect(all.map((p) => p.id), sourceCopy.map((p) => p.id));
    });

    test('V121-2 first period → current/next only', () {
      final all = [
        const _P('a', isCurrent: true),
        const _P('b'),
        const _P('c'),
      ];
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.map((p) => p.id), ['a', 'b']);
    });

    test('V121-3 last period → previous/current only', () {
      final all = [
        const _P('a', isPast: true),
        const _P('b', isPast: true),
        const _P('c', isCurrent: true),
      ];
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.map((p) => p.id), ['b', 'c']);
    });

    test('V121-4 single period', () {
      final all = [const _P('only', isCurrent: true)];
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.map((p) => p.id), ['only']);
    });

    test('V121-5 empty periods', () {
      final selected = RelevantLifePeriodsSelector.select<_P>(
        periods: const [],
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected, isEmpty);
      expect(
        RelevantLifePeriodsSelector.resolveCurrentIndex<_P>(
          periods: const [],
          isCurrent: (p) => p.isCurrent,
          isPast: (p) => p.isPast,
        ),
        -1,
      );
    });

    test('V121-7 no current → deterministic first non-past fallback', () {
      final all = [
        const _P('a', isPast: true),
        const _P('b', isPast: true),
        const _P('c'),
        const _P('d'),
      ];
      expect(
        RelevantLifePeriodsSelector.resolveCurrentIndex(
          periods: all,
          isCurrent: (p) => p.isCurrent,
          isPast: (p) => p.isPast,
        ),
        2,
      );
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.map((p) => p.id), ['b', 'c', 'd']);
      expect(selected.length, lessThanOrEqualTo(3));
    });

    test('V121-7b all past → last period fallback', () {
      final all = [
        const _P('a', isPast: true),
        const _P('b', isPast: true),
        const _P('c', isPast: true),
      ];
      expect(
        RelevantLifePeriodsSelector.resolveCurrentIndex(
          periods: all,
          isCurrent: (p) => p.isCurrent,
          isPast: (p) => p.isPast,
        ),
        2,
      );
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.map((p) => p.id), ['b', 'c']);
    });

    test('V121-8 long timeline caps at 3', () {
      final all = [
        for (var i = 0; i < 12; i++)
          _P('p$i', isPast: i < 7, isCurrent: i == 7),
      ];
      final selected = RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(selected.length, 3);
      expect(selected.map((p) => p.id), ['p6', 'p7', 'p8']);
    });

    test('V121-9 source preservation', () {
      final all = [
        const _P('a', isPast: true),
        const _P('b', isCurrent: true),
        const _P('c'),
      ];
      final before = List<_P>.from(all);
      RelevantLifePeriodsSelector.select(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(all.length, before.length);
      for (var i = 0; i < all.length; i++) {
        expect(identical(all[i], before[i]), isTrue);
      }
    });

    test('V121-10 determinism', () {
      final all = [
        for (var i = 0; i < 8; i++)
          _P('p$i', isPast: i < 3, isCurrent: i == 3),
      ];
      final a = RelevantLifePeriodsSelector.selectIndices(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      final b = RelevantLifePeriodsSelector.selectIndices(
        periods: all,
        isCurrent: (p) => p.isCurrent,
        isPast: (p) => p.isPast,
      );
      expect(a, b);
      expect(a, [2, 3, 4]);
    });
  });
}
