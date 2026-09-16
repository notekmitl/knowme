class BaziPillar {
  const BaziPillar({
    required this.stem,
    required this.branch,
    required this.stemRoman,
    required this.branchRoman,
    required this.stemElement,
    required this.branchElement,
    required this.pillarLabel,
    this.hiddenStems = const [],
    this.stemTenGod = '',
    this.hiddenTenGods = const [],
    this.growthStage = '',
    this.nayin = '',
  });

  final String stem;
  final String branch;
  final String stemRoman;
  final String branchRoman;
  final String stemElement;
  final String branchElement;
  final String pillarLabel;
  final List<String> hiddenStems;
  final String stemTenGod;
  final List<String> hiddenTenGods;
  final String growthStage;
  final String nayin;

  bool get isAvailable => pillarLabel.trim().isNotEmpty;

  factory BaziPillar.fromMap(Map<String, dynamic> map) {
    return BaziPillar(
      stem: _string(map['stem']),
      branch: _string(map['branch']),
      stemRoman: _string(map['stem_roman']),
      branchRoman: _string(map['branch_roman']),
      stemElement: _string(map['stem_element']),
      branchElement: _string(map['branch_element']),
      pillarLabel: _string(map['pillar_label']),
      hiddenStems: _stringList(map['hidden_stems']),
      stemTenGod: _string(map['stem_ten_god']),
      hiddenTenGods: _stringList(map['hidden_ten_gods']),
      growthStage: _string(map['growth_stage']),
      nayin: _string(map['nayin']),
    );
  }
}

class BaziTenGodBalance {
  const BaziTenGodBalance({
    this.visible = const {},
    this.hidden = const {},
    this.familyWeight = const {},
    this.topFamilies = const [],
    this.method = '',
  });

  final Map<String, int> visible;
  final Map<String, int> hidden;
  final Map<String, int> familyWeight;
  final List<String> topFamilies;
  final String method;

  factory BaziTenGodBalance.fromMap(Map<String, dynamic> map) {
    return BaziTenGodBalance(
      visible: _intMap(map['visible']),
      hidden: _intMap(map['hidden']),
      familyWeight: _intMap(map['family_weight']),
      topFamilies: _stringList(map['top_families']),
      method: _string(map['method']),
    );
  }
}

class BaziDayMasterSupport {
  const BaziDayMasterSupport({
    this.score = 0,
    this.maxScore = 0,
    this.band = '',
    this.seasonScore = 0,
    this.groundScore = 0,
    this.visibleSupportScore = 0,
    this.resourceElement = '',
    this.method = '',
  });

  final int score;
  final int maxScore;
  final String band;
  final int seasonScore;
  final int groundScore;
  final int visibleSupportScore;
  final String resourceElement;
  final String method;

  factory BaziDayMasterSupport.fromMap(Map<String, dynamic> map) {
    return BaziDayMasterSupport(
      score: _int(map['score']),
      maxScore: _int(map['max_score']),
      band: _string(map['band']),
      seasonScore: _int(map['season_score']),
      groundScore: _int(map['ground_score']),
      visibleSupportScore: _int(map['visible_support_score']),
      resourceElement: _string(map['resource_element']),
      method: _string(map['method']),
    );
  }
}

class BaziRelation {
  const BaziRelation({
    required this.kind,
    this.roles = const [],
    this.symbols = const [],
    this.targetElement = '',
  });

  final String kind;
  final List<String> roles;
  final List<String> symbols;
  final String targetElement;

  factory BaziRelation.fromMap(Map<String, dynamic> map) {
    return BaziRelation(
      kind: _string(map['kind']),
      roles: _stringList(map['roles']),
      symbols: _stringList(map['symbols']),
      targetElement: _string(map['target_element']),
    );
  }
}

class BaziAnnualInfluence {
  const BaziAnnualInfluence({
    required this.year,
    required this.age,
    required this.pillarLabel,
    required this.stem,
    required this.branch,
    required this.stemTenGod,
    this.natalRelations = const [],
  });

  final int year;
  final int age;
  final String pillarLabel;
  final String stem;
  final String branch;
  final String stemTenGod;
  final List<BaziRelation> natalRelations;

  factory BaziAnnualInfluence.fromMap(Map<String, dynamic> map) {
    return BaziAnnualInfluence(
      year: _int(map['year']),
      age: _int(map['age']),
      pillarLabel: _string(map['pillar_label']),
      stem: _string(map['stem']),
      branch: _string(map['branch']),
      stemTenGod: _string(map['stem_ten_god']),
      natalRelations: _relationList(map['natal_relations']),
    );
  }
}

class BaziLuckCycle {
  const BaziLuckCycle({
    required this.startYear,
    required this.endYear,
    required this.startAge,
    required this.endAge,
    required this.pillarLabel,
    required this.stem,
    required this.branch,
    required this.stemTenGod,
    this.natalRelations = const [],
    this.annual = const [],
  });

  final int startYear;
  final int endYear;
  final int startAge;
  final int endAge;
  final String pillarLabel;
  final String stem;
  final String branch;
  final String stemTenGod;
  final List<BaziRelation> natalRelations;
  final List<BaziAnnualInfluence> annual;

  factory BaziLuckCycle.fromMap(Map<String, dynamic> map) {
    return BaziLuckCycle(
      startYear: _int(map['start_year']),
      endYear: _int(map['end_year']),
      startAge: _int(map['start_age']),
      endAge: _int(map['end_age']),
      pillarLabel: _string(map['pillar_label']),
      stem: _string(map['stem']),
      branch: _string(map['branch']),
      stemTenGod: _string(map['stem_ten_god']),
      natalRelations: _relationList(map['natal_relations']),
      annual: _mapList(
        map['annual'],
      ).map(BaziAnnualInfluence.fromMap).toList(growable: false),
    );
  }
}

class BaziLuck {
  const BaziLuck({
    this.gender = '',
    this.direction = '',
    this.onset = const {},
    this.cycles = const [],
    this.method = '',
  });

  final String gender;
  final String direction;
  final Map<String, dynamic> onset;
  final List<BaziLuckCycle> cycles;
  final String method;

  bool get isAvailable => cycles.isNotEmpty;

  factory BaziLuck.fromMap(Map<String, dynamic> map) {
    return BaziLuck(
      gender: _string(map['gender']),
      direction: _string(map['direction']),
      onset: _map(map['onset']),
      cycles: _mapList(
        map['cycles'],
      ).map(BaziLuckCycle.fromMap).toList(growable: false),
      method: _string(map['method']),
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

  bool get isAvailable => zh.trim().isNotEmpty || en.trim().isNotEmpty;

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
    required this.contractId,
    required this.contractName,
    required this.engineVersion,
    required this.generatedAt,
    required this.inputHash,
    required this.completeness,
    required this.dayMaster,
    required this.yearAnimal,
    required this.dominantElement,
    required this.pillars,
    required this.elementBalance,
    required this.timeKnown,
    this.enginePolicy = const {},
    this.input = const {},
    this.ambiguities = const {},
    this.suppressedFields = const [],
    this.tenGodBalance = const BaziTenGodBalance(),
    this.dayMasterSupport = const BaziDayMasterSupport(),
    this.natalRelations = const [],
    this.luck = const BaziLuck(),
  });

  final String version;
  final String contractId;
  final String contractName;
  final String engineVersion;
  final String generatedAt;
  final String inputHash;
  final String completeness;
  final BaziDayMaster dayMaster;
  final BaziYearAnimal yearAnimal;
  final String? dominantElement;
  final BaziPillars pillars;
  final BaziElementBalance elementBalance;
  final bool timeKnown;
  final Map<String, dynamic> enginePolicy;
  final Map<String, dynamic> input;
  final Map<String, bool> ambiguities;
  final List<String> suppressedFields;
  final BaziTenGodBalance tenGodBalance;
  final BaziDayMasterSupport dayMasterSupport;
  final List<BaziRelation> natalRelations;
  final BaziLuck luck;

  factory BaziChartModel.fromMap(Map<String, dynamic> map) {
    return BaziChartModel(
      version: _string(map['version']),
      contractId: _string(map['contract_id']).isNotEmpty
          ? _string(map['contract_id'])
          : _string(map['version']),
      contractName: _string(map['contract_name']).isNotEmpty
          ? _string(map['contract_name'])
          : 'KnowMe BaZi Reader',
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
      timeKnown: map['time_known'] is bool
          ? map['time_known'] as bool
          : _map(map['pillars'])['hour'] is Map,
      enginePolicy: Map<String, dynamic>.from(map['engine_policy'] ?? {}),
      input: Map<String, dynamic>.from(map['input'] ?? {}),
      ambiguities: _boolMap(map['ambiguities']),
      suppressedFields: _stringList(map['suppressed_fields']),
      tenGodBalance: BaziTenGodBalance.fromMap(_map(map['ten_god_balance'])),
      dayMasterSupport: BaziDayMasterSupport.fromMap(
        _map(map['day_master_support']),
      ),
      natalRelations: _relationList(map['natal_relations']),
      luck: BaziLuck.fromMap(_map(map['luck'])),
    );
  }
}

List<BaziRelation> _relationList(dynamic value) {
  return _mapList(value).map(BaziRelation.fromMap).toList(growable: false);
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_map).toList(growable: false);
}

Map<String, int> _intMap(dynamic value) {
  if (value is! Map) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: _int(entry.value),
  };
}

Map<String, bool> _boolMap(dynamic value) {
  if (value is! Map) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value is bool)
        entry.key as String: entry.value as bool,
  };
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
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
