import 'life_planet.dart';

/// V9 — natal context for Life Timeline Intelligence.
///
/// The intelligence engine compares each life period against *who the person
/// is*. That natal anchor is two planets:
///   • [birthRuler] — the weekday ruler (where the life-period ring begins).
///   • [lagnaLord]  — the lord of the rising sign, when birth time is known.
///
/// Both are resolved upstream from the canonical profile (weekday ruler from the
/// birth date, lagna lord from the foundation engine). Keeping this as a small
/// value object lets the core engine stay reusable and free of presentation /
/// foundation types.
class LifeNatalContext {
  const LifeNatalContext({
    required this.birthRuler,
    this.lagnaLord,
  });

  /// Always available — derived from weekday of birth.
  final LifePlanet birthRuler;

  /// Available only when birth time (and therefore the lagna) is known.
  final LifePlanet? lagnaLord;

  /// The distinct natal anchor planets (birth ruler + lagna lord if different).
  List<LifePlanet> get anchors {
    final lord = lagnaLord;
    if (lord == null || lord == birthRuler) return [birthRuler];
    return [birthRuler, lord];
  }

  bool get hasLagna => lagnaLord != null;
}
