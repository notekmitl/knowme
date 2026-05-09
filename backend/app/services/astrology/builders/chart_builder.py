from datetime import datetime
import swisseph as swe

from app.services.astrology.calculators.planet_calculator import calculate_planets
from app.services.astrology.calculators.house_calculator import (
    calculate_houses,
    get_house,
)
from app.services.astrology.calculators.aspect_calculator import calculate_aspects

from app.services.astrology.utils.astrology_utils import get_sign

from app.services.astrology.interpretations.interpretation_engine import (
    generate_interpretations
)


def build_chart(
    birth_date,
    birth_time,
    latitude,
    longitude
):

    dt = datetime.strptime(
        f"{birth_date} {birth_time}",
        "%Y-%m-%d %H:%M"
    )

    decimal_hour = (
        dt.hour +
        dt.minute / 60
    )

    julian_day = swe.julday(
        dt.year,
        dt.month,
        dt.day,
        decimal_hour
    )

    planets = calculate_planets(
        julian_day
    )

    houses = calculate_houses(
        julian_day,
        latitude,
        longitude
    )

    for _, planet_data in planets.items():

        planet_data["house"] = get_house(
            planet_data["longitude"],
            houses["cusps"]
        )

    aspects = calculate_aspects(
        planets
    )

    interpretations = generate_interpretations(
        planets
    )

    return {

        "big3": {
            "sun": planets["sun"]["sign"],
            "moon": planets["moon"]["sign"],
            "rising": get_sign(
                houses["ascendant"]
            )
        },

        "planets": planets,

        "houses": {
            "ascendant": houses["ascendant"],
            "cusps": list(houses["cusps"])
        },

        "aspects": aspects,

        "interpretations": interpretations
    }