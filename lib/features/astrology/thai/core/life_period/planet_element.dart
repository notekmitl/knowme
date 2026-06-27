import 'life_planet.dart';

/// V9 — Life Timeline Intelligence: planetary element model.
///
/// Each [LifePlanet] carries one of the four traditional Thai elements (ธาตุ:
/// ไฟ / ดิน / ลม / น้ำ — the same four elements the foundation expresses through
/// `ramahabhuta`). Elements add a second relationship axis on top of the natural
/// friend/enemy table: two planets can be natural neutrals yet still *support*
/// or *conflict* through their elements.
///
/// This lives in the reusable core module — it returns **evidence only** (the
/// element, the element relation and a signed score). No narrative prose lives
/// here; the presentation layer turns this evidence into copy.
///
/// Classical planet → element associations (Thai/Vedic):
///   • ไฟ (fire):  Sun, Mars        — radiant, driving, igniting
///   • ดิน (earth): Mercury         — grounded, practical, structuring
///   • ลม (air):   Jupiter, Saturn, Rahu — expansive, moving, shifting
///   • น้ำ (water): Moon, Venus      — feeling, relating, flowing
enum ThaiElement {
  fire,
  earth,
  air,
  water,
}

extension ThaiElementLabel on ThaiElement {
  /// Short Thai label ("ไฟ"). A *label*, never narrative copy.
  String get labelTh => switch (this) {
        ThaiElement.fire => 'ไฟ',
        ThaiElement.earth => 'ดิน',
        ThaiElement.air => 'ลม',
        ThaiElement.water => 'น้ำ',
      };
}

/// The element relation between two planets' elements.
///
/// The model is symmetric and defensible:
///   • same element            → [supporting] (resonance)
///   • ไฟ ↔ ลม  (air feeds fire) → [supporting]
///   • ดิน ↔ น้ำ (water nourishes earth) → [supporting]
///   • ไฟ ↔ น้ำ (water quenches fire) → [conflicting]
///   • ดิน ↔ ลม (wind erodes earth) → [conflicting]
///   • everything else          → [neutral]
enum ElementRelation { supporting, neutral, conflicting }

extension ElementRelationScore on ElementRelation {
  /// Signed weight contributed to a combined relationship assessment.
  int get score => switch (this) {
        ElementRelation.supporting => 1,
        ElementRelation.neutral => 0,
        ElementRelation.conflicting => -1,
      };

  String get labelTh => switch (this) {
        ElementRelation.supporting => 'ธาตุเสริมกัน',
        ElementRelation.neutral => 'ธาตุเป็นกลาง',
        ElementRelation.conflicting => 'ธาตุขัดกัน',
      };
}

abstract final class PlanetElements {
  static const Map<LifePlanet, ThaiElement> _elementOf = {
    LifePlanet.sun: ThaiElement.fire,
    LifePlanet.mars: ThaiElement.fire,
    LifePlanet.mercury: ThaiElement.earth,
    LifePlanet.jupiter: ThaiElement.air,
    LifePlanet.saturn: ThaiElement.air,
    LifePlanet.rahu: ThaiElement.air,
    LifePlanet.moon: ThaiElement.water,
    LifePlanet.venus: ThaiElement.water,
  };

  static ThaiElement of(LifePlanet planet) => _elementOf[planet]!;

  /// The element relation between two planets (symmetric).
  ///
  ///   • same element            → supporting (resonance)
  ///   • fire ↔ air              → supporting (air feeds fire)
  ///   • earth ↔ water           → supporting (water nourishes earth)
  ///   • fire ↔ water            → conflicting (water quenches fire)
  ///   • earth ↔ air             → conflicting (wind erodes earth)
  ///   • everything else         → neutral
  static ElementRelation relation(LifePlanet from, LifePlanet to) {
    final a = of(from);
    final b = of(to);
    if (a == b) return ElementRelation.supporting;
    if (_isPair(a, b, ThaiElement.fire, ThaiElement.air) ||
        _isPair(a, b, ThaiElement.earth, ThaiElement.water)) {
      return ElementRelation.supporting;
    }
    if (_isPair(a, b, ThaiElement.fire, ThaiElement.water) ||
        _isPair(a, b, ThaiElement.earth, ThaiElement.air)) {
      return ElementRelation.conflicting;
    }
    return ElementRelation.neutral;
  }

  static bool _isPair(
    ThaiElement a,
    ThaiElement b,
    ThaiElement x,
    ThaiElement y,
  ) =>
      (a == x && b == y) || (a == y && b == x);
}
