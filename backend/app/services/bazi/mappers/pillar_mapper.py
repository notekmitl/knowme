"""Map stems/branches to KnowMe pillar structures."""

from app.services.bazi.constants import (
    GAN_ROMAN,
    WU_XING_GAN,
    WU_XING_ZHI,
    YIN_STEMS,
    YANG_STEMS,
    ZHI_ROMAN,
)


def stem_polarity(stem: str) -> str:
    if stem in YANG_STEMS:
        return "yang"
    if stem in YIN_STEMS:
        return "yin"
    return "unknown"


def map_pillar(gan: str, zhi: str) -> dict:
    return {
        "stem": gan,
        "branch": zhi,
        "stem_roman": GAN_ROMAN.get(gan, ""),
        "branch_roman": ZHI_ROMAN.get(zhi, ""),
        "stem_element": WU_XING_GAN.get(gan, ""),
        "branch_element": WU_XING_ZHI.get(zhi, ""),
        "pillar_label": f"{gan}{zhi}",
    }


def map_pillars_from_eight_char(eight_char) -> dict:
    return {
        "year": map_pillar(eight_char.getYearGan(), eight_char.getYearZhi()),
        "month": map_pillar(eight_char.getMonthGan(), eight_char.getMonthZhi()),
        "day": map_pillar(eight_char.getDayGan(), eight_char.getDayZhi()),
        "hour": map_pillar(eight_char.getTimeGan(), eight_char.getTimeZhi()),
    }
