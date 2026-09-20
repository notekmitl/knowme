"""Deterministic whole-chart analysis for Western Reader V2."""

from __future__ import annotations

from collections import Counter


SIGN_META = {
    "Aries": ("fire", "cardinal", "positive", "mars"),
    "Taurus": ("earth", "fixed", "negative", "venus"),
    "Gemini": ("air", "mutable", "positive", "mercury"),
    "Cancer": ("water", "cardinal", "negative", "moon"),
    "Leo": ("fire", "fixed", "positive", "sun"),
    "Virgo": ("earth", "mutable", "negative", "mercury"),
    "Libra": ("air", "cardinal", "positive", "venus"),
    "Scorpio": ("water", "fixed", "negative", "mars"),
    "Sagittarius": ("fire", "mutable", "positive", "jupiter"),
    "Capricorn": ("earth", "cardinal", "negative", "saturn"),
    "Aquarius": ("air", "fixed", "positive", "saturn"),
    "Pisces": ("water", "mutable", "negative", "jupiter"),
}

PLANET_WEIGHTS = {
    "sun": 5,
    "moon": 5,
    "mercury": 2,
    "venus": 3,
    "mars": 3,
    "jupiter": 2,
    "saturn": 2,
}

ANGULAR_HOUSES = {1, 4, 7, 10}


def analyze_chart(planets: dict, houses: dict, aspects: list[dict]) -> dict:
    """Return stable balances, dominant planets, and house emphasis."""
    elements = Counter({key: 0 for key in ("fire", "earth", "air", "water")})
    modalities = Counter({key: 0 for key in ("cardinal", "fixed", "mutable")})
    polarities = Counter({key: 0 for key in ("positive", "negative")})

    for planet, data in planets.items():
        meta = SIGN_META.get(data.get("sign"))
        if meta is None:
            continue
        weight = PLANET_WEIGHTS.get(planet, 1)
        elements[meta[0]] += weight
        modalities[meta[1]] += weight
        polarities[meta[2]] += weight

    rising_sign = _sign_for_longitude(houses.get("ascendant"))
    if rising_sign in SIGN_META:
        element, modality, polarity, _ = SIGN_META[rising_sign]
        elements[element] += 4
        modalities[modality] += 4
        polarities[polarity] += 4

    aspect_counts = Counter()
    for aspect in aspects:
        aspect_counts[aspect.get("planet1")] += 1
        aspect_counts[aspect.get("planet2")] += 1

    rulers = Counter()
    for sign in (
        planets.get("sun", {}).get("sign"),
        planets.get("moon", {}).get("sign"),
        rising_sign,
    ):
        meta = SIGN_META.get(sign)
        if meta is not None:
            rulers[meta[3]] += 1

    planet_scores = []
    for planet, data in planets.items():
        house = int(data.get("house") or 0)
        score = PLANET_WEIGHTS.get(planet, 1)
        score += rulers[planet] * 2
        score += 2 if house in ANGULAR_HOUSES else 0
        score += min(aspect_counts[planet], 4) * 0.5
        planet_scores.append(
            {
                "planet": planet,
                "score": round(score, 2),
                "sign": data.get("sign"),
                "house": house,
                "reasons": {
                    "big3_rulerships": rulers[planet],
                    "angular": house in ANGULAR_HOUSES,
                    "major_aspects": aspect_counts[planet],
                },
            }
        )
    planet_scores.sort(key=lambda item: (-item["score"], item["planet"]))

    house_scores = Counter()
    for planet, data in planets.items():
        house = int(data.get("house") or 0)
        if 1 <= house <= 12:
            house_scores[house] += PLANET_WEIGHTS.get(planet, 1)
    emphasized_houses = [
        {"house": house, "score": score}
        for house, score in sorted(
            house_scores.items(),
            key=lambda item: (-item[1], item[0]),
        )[:3]
    ]

    return {
        "elements": _balance(elements),
        "modalities": _balance(modalities),
        "polarities": _balance(polarities),
        "dominant_planets": planet_scores[:3],
        "house_emphasis": emphasized_houses,
        "major_aspects": aspects[:6],
    }


def _balance(values: Counter) -> dict:
    ordered = dict(values)
    total = sum(ordered.values())
    dominant = _dominant_key(ordered)
    return {
        "scores": ordered,
        "percentages": {
            key: round((value / total) * 100) if total else 0
            for key, value in ordered.items()
        },
        "dominant": dominant,
        "least": _least_key(ordered),
    }


def _dominant_key(values: dict) -> str | None:
    if not values:
        return None
    highest = max(values.values())
    winners = [key for key, value in values.items() if value == highest]
    return winners[0] if len(winners) == 1 else "balanced"


def _least_key(values: dict) -> str | None:
    if not values:
        return None
    lowest = min(values.values())
    winners = [key for key, value in values.items() if value == lowest]
    return winners[0] if len(winners) == 1 else "balanced"


def _sign_for_longitude(value) -> str | None:
    if not isinstance(value, (int, float)):
        return None
    signs = list(SIGN_META)
    return signs[int(float(value) % 360 // 30)]
