class BaziPillar {
  const BaziPillar({
    required this.stem,
    required this.branch,
    required this.stemRoman,
    required this.branchRoman,
    required this.stemElement,
    required this.branchElement,
    required this.pillarLabel,
  });

  final String stem;
  final String branch;
  final String stemRoman;
  final String branchRoman;
  final String stemElement;
  final String branchElement;
  final String pillarLabel;

  factory BaziPillar.fromMap(Map<String, dynamic> map) {
    return BaziPillar(
      stem: _string(map['stem']),
      branch: _string(map['branch']),
      stemRoman: _string(map['stem_roman']),
      branchRoman: _string(map['branch_roman']),
      stemElement: _string(map['stem_element']),
      branchElement: _string(map['branch_element']),
      pillarLabel: _string(map['pillar_label']),
    );
  }
}

class BaziDayMaster {
  const BaziDayMaster({
    required this.stem,
    required this.stemRoman,
    required this.element,
    required this.polarity,
    required this.pillarLabel,
  });

  final String stem;
  final String stemRoman;
  final String element;
  final String polarity;
  final String pillarLabel;

  factory BaziDayMaster.fromMap(Map<String, dynamic> map) {
    return BaziDayMaster(
      stem: _string(map['stem']),
      stemRoman: _string(map['stem_roman']),
      element: _string(map['element']),
      polarity: _string(map['polarity']),
      pillarLabel: _string(map['pillar_label']),
    );
  }
}

class BaziYearAnimal {
  const BaziYearAnimal({
    required this.zh,
    required this.roman,
    required this.en,
  });

  final String zh;
  final String roman;
  final String en;

  factory BaziYearAnimal.fromMap(Map<String, dynamic> map) {
    return BaziYearAnimal(
      zh: _string(map['zh']),
      roman: _string(map['roman']),
      en: _string(map['en']),
    );
  }
}

class BaziElementBalance {
  const BaziElementBalance({
    required this.wood,
    required this.fire,
    required this.earth,
    required this.metal,
    required this.water,
    required this.totalSlots,
    required this.method,
  });

  final int wood;
  final int fire;
  final int earth;
  final int metal;
  final int water;
  final int totalSlots;
  final String method;

  factory BaziElementBalance.fromMap(Map<String, dynamic> map) {
    return BaziElementBalance(
      wood: _int(map['wood']),
      fire: _int(map['fire']),
      earth: _int(map['earth']),
      metal: _int(map['metal']),
      water: _int(map['water']),
      totalSlots: _int(map['total_slots']),
      method: _string(map['method']),
    );
  }
}

class BaziPillars {
  const BaziPillars({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
  });

  final BaziPillar year;
  final BaziPillar month;
  final BaziPillar day;
  final BaziPillar hour;

  factory BaziPillars.fromMap(Map<String, dynamic> map) {
    return BaziPillars(
      year: BaziPillar.fromMap(_map(map['year'])),
      month: BaziPillar.fromMap(_map(map['month'])),
      day: BaziPillar.fromMap(_map(map['day'])),
      hour: BaziPillar.fromMap(_map(map['hour'])),
    );
  }
}

class BaziChartModel {
  const BaziChartModel({
    required this.version,
    required this.engineVersion,
    required this.generatedAt,
    required this.inputHash,
    required this.completeness,
    required this.dayMaster,
    required this.yearAnimal,
    required this.dominantElement,
    required this.pillars,
    required this.elementBalance,
    this.enginePolicy = const {},
    this.input = const {},
  });

  final String version;
  final String engineVersion;
  final String generatedAt;
  final String inputHash;
  final String completeness;
  final BaziDayMaster dayMaster;
  final BaziYearAnimal yearAnimal;
  final String? dominantElement;
  final BaziPillars pillars;
  final BaziElementBalance elementBalance;
  final Map<String, dynamic> enginePolicy;
  final Map<String, dynamic> input;

  factory BaziChartModel.fromMap(Map<String, dynamic> map) {
    return BaziChartModel(
      version: _string(map['version']),
      engineVersion: _string(map['engine_version']),
      generatedAt: _string(map['generated_at']),
      inputHash: _string(map['input_hash']),
      completeness: _string(map['completeness']),
      dayMaster: BaziDayMaster.fromMap(_map(map['day_master'])),
      yearAnimal: BaziYearAnimal.fromMap(_map(map['year_animal'])),
      dominantElement: map['dominant_element'] is String
          ? map['dominant_element'] as String
          : null,
      pillars: BaziPillars.fromMap(_map(map['pillars'])),
      elementBalance: BaziElementBalance.fromMap(_map(map['element_balance'])),
      enginePolicy: Map<String, dynamic>.from(map['engine_policy'] ?? {}),
      input: Map<String, dynamic>.from(map['input'] ?? {}),
    );
  }
}

String _string(dynamic value) {
  if (value is String) return value;
  return '';
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return {};
}
