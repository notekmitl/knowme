enum Element { fire, earth, air, water }

extension ElementExtension on Element {
  String get displayName {
    switch (this) {
      case Element.fire:
        return "Fire";
      case Element.earth:
        return "Earth";
      case Element.air:
        return "Air";
      case Element.water:
        return "Water";
    }
  }
}
