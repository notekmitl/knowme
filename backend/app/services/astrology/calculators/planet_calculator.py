import swisseph as swe

from app.services.astrology.constants import PLANETS
from app.services.astrology.utils.astrology_utils import get_sign


def calculate_planets(julian_day):

    planet_results = {}

    for name, planet_id in PLANETS.items():

        result = swe.calc_ut(
            julian_day,
            planet_id
        )

        longitude = result[0][0]

        planet_results[name] = {
            "sign": get_sign(longitude),
            "longitude": longitude
        }

    return planet_results