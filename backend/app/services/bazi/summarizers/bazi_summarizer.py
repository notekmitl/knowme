"""Day Master, element balance, and dominant element for BaZi V1."""

from app.services.bazi.constants import (
    ELEMENT_BALANCE_METHOD,
    ELEMENT_TIEBREAK_ORDER,
    WU_XING_GAN,
)
from app.services.bazi.mappers.pillar_mapper import stem_polarity


def summarize_day_master(day_gan: str) -> dict:
    element = WU_XING_GAN.get(day_gan, "")
    polarity = stem_polarity(day_gan)
    return {
        "stem": day_gan,
        "stem_roman": _stem_roman(day_gan),
        "element": element,
        "polarity": polarity,
    }


def _stem_roman(stem: str) -> str:
    from app.services.bazi.constants import GAN_ROMAN

    return GAN_ROMAN.get(stem, "")


def compute_element_balance(pillars: dict) -> dict:
    """
    Count visible stem + branch elements across only the available pillars.

    Unknown time omits the Hour pillar, and a transition-ambiguous Year/Month
    pillar is omitted too. This is not full BaZi strength analysis.
    """
    counts = {element: 0 for element in ELEMENT_TIEBREAK_ORDER}
    total_slots = 0

    for key in ("year", "month", "day", "hour"):
        pillar = pillars.get(key)
        if not isinstance(pillar, dict):
            continue
        for field in ("stem_element", "branch_element"):
            element = pillar.get(field)
            if element in counts:
                counts[element] += 1
                total_slots += 1

    return {
        "wood": counts["wood"],
        "fire": counts["fire"],
        "earth": counts["earth"],
        "metal": counts["metal"],
        "water": counts["water"],
        "total_slots": total_slots,
        "method": ELEMENT_BALANCE_METHOD,
    }


def compute_dominant_element(element_balance: dict) -> str | None:
    """
    Dominant Element V1: highest surface count; ties broken by ELEMENT_TIEBREAK_ORDER.

    Count-based approximation only — not 日主 strength or 用神 analysis.
    """
    counts = {
        element: element_balance.get(element, 0)
        for element in ELEMENT_TIEBREAK_ORDER
    }
    max_count = max(counts.values())
    if max_count == 0:
        return None

    for element in ELEMENT_TIEBREAK_ORDER:
        if counts[element] == max_count:
            return element

    return None
