"""KnowMe BaZi Reader V3 constants - isolated from Western astrology."""

BAZI_VERSION = "knowme_bazi_reader_v3"
CONTRACT_ID = "knowme_bazi_reader_v3"
CONTRACT_NAME = "KnowMe BaZi Reader V3"
ENGINE_VERSION = "lunar_python@1.4.8+tzdata@2025.2+noaa_eot_v1"
ELEMENT_BALANCE_METHOD = "surface_stem_branch_compatibility_v1"

ENGINE_POLICY = {
    "contract_id": CONTRACT_ID,
    "contract_name": CONTRACT_NAME,
    "scope": "knowme_reader_v3_not_universal_school_standard",
    "calendar_input": "gregorian_apparent_solar_time_when_time_known",
    "timezone_role": "historical_iana_utc_offset_at_birth",
    "year_boundary": "lichun",
    "month_boundary": "jieqi_jie",
    "eight_char_sect": 2,
    "day_boundary": "apparent_solar_00:00_when_time_known",
    "solar_time_correction": "noaa_fractional_year_eot_v1_plus_longitude",
    "coordinates_role": "known_time_requires_coordinates_longitude_used",
    "birth_time_required": False,
    "unknown_time_policy": "never_impute_time_omit_hour_and_time_outputs",
    "reader_fact_layers": [
        "hidden_stems",
        "ten_gods",
        "day_master_support",
        "stem_branch_relations",
        "luck_cycles_when_gender_and_time_are_known",
    ],
}

YANG_STEMS = frozenset({"甲", "丙", "戊", "庚", "壬"})
YIN_STEMS = frozenset({"乙", "丁", "己", "辛", "癸"})

GAN_ROMAN = {
    "甲": "jia",
    "乙": "yi",
    "丙": "bing",
    "丁": "ding",
    "戊": "wu",
    "己": "ji",
    "庚": "geng",
    "辛": "xin",
    "壬": "ren",
    "癸": "gui",
}

ZHI_ROMAN = {
    "子": "zi",
    "丑": "chou",
    "寅": "yin",
    "卯": "mao",
    "辰": "chen",
    "巳": "si",
    "午": "wu",
    "未": "wei",
    "申": "shen",
    "酉": "you",
    "戌": "xu",
    "亥": "hai",
}

WU_XING_GAN = {
    "甲": "wood",
    "乙": "wood",
    "丙": "fire",
    "丁": "fire",
    "戊": "earth",
    "己": "earth",
    "庚": "metal",
    "辛": "metal",
    "壬": "water",
    "癸": "water",
}

WU_XING_ZHI = {
    "寅": "wood",
    "卯": "wood",
    "巳": "fire",
    "午": "fire",
    "辰": "earth",
    "丑": "earth",
    "戌": "earth",
    "未": "earth",
    "申": "metal",
    "酉": "metal",
    "亥": "water",
    "子": "water",
}

SHENGXIAO_ZH_TO_ROMAN = {
    "鼠": "rat",
    "牛": "ox",
    "虎": "tiger",
    "兔": "rabbit",
    "龙": "dragon",
    "蛇": "snake",
    "马": "horse",
    "羊": "goat",
    "猴": "monkey",
    "鸡": "rooster",
    "狗": "dog",
    "猪": "pig",
}

SHENGXIAO_ROMAN_TO_EN = {
    "rat": "Rat",
    "ox": "Ox",
    "tiger": "Tiger",
    "rabbit": "Rabbit",
    "dragon": "Dragon",
    "snake": "Snake",
    "horse": "Horse",
    "goat": "Goat",
    "monkey": "Monkey",
    "rooster": "Rooster",
    "dog": "Dog",
    "pig": "Pig",
}

ELEMENT_TIEBREAK_ORDER = ("wood", "fire", "earth", "metal", "water")
