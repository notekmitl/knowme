import '../../../content/models/thai_content_key.dart';
import '../../constants/thai_lagna_rulership.dart';
import '../models/thai_house.dart';
import '../models/thai_lagna.dart';

/// Whole-sign house derivation from sidereal lagna.
abstract final class HouseEngine {
  static const houseCount = 12;

  static List<ThaiHouse> calculate({required ThaiLagna lagna}) {
    final houses = <ThaiHouse>[];

    for (var houseNumber = 1; houseNumber <= houseCount; houseNumber++) {
      final signIndex = (lagna.signIndex + houseNumber - 1) % ThaiContentKeys.allLagna.length;
      final signKey = ThaiContentKeys.allLagna[signIndex];
      final lordKey = ThaiLagnaRulership.lordForLagna(signKey)!;

      houses.add(
        ThaiHouse(
          houseNumber: houseNumber,
          signKey: signKey,
          lordKey: lordKey,
        ),
      );
    }

    return List<ThaiHouse>.unmodifiable(houses);
  }
}
