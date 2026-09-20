import swisseph as swe

from app.services.astrology.constants import PLANETS
from app.services.astrology.utils.astrology_utils import get_sign


def calculate_planets(julian_day):

    planet_results = {}

    for name, planet_id in PLANETS.items():

        result = swe.calc_ut(
            julian_day,
            planet_id,
            swe.FLG_SWIEPH | swe.FLG_SPEED,
        )

        longitude = result[0][0]
        longitude_speed = result[0][3]

        planet_results[name] = {
            "sign": get_sign(longitude),
            "longitude": round(longitude, 6),
            "degree": round(longitude % 30, 4),
            "retrograde": longitude_speed < 0,
        }

    return planet_results
