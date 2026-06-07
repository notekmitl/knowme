"""Year branch animal (生肖) mapping."""

from app.services.bazi.constants import (
    SHENGXIAO_ROMAN_TO_EN,
    SHENGXIAO_ZH_TO_ROMAN,
)


def map_year_animal(lunar) -> dict:
    zh = lunar.getYearShengXiaoExact()
    roman = SHENGXIAO_ZH_TO_ROMAN.get(zh, "")
    return {
        "zh": zh,
        "roman": roman,
        "en": SHENGXIAO_ROMAN_TO_EN.get(roman, roman.title() if roman else ""),
    }
