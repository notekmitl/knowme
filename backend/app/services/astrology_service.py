from datetime import datetime
import swisseph as swe


SIGNS = [
    "Aries",
    "Taurus",
    "Gemini",
    "Cancer",
    "Leo",
    "Virgo",
    "Libra",
    "Scorpio",
    "Sagittarius",
    "Capricorn",
    "Aquarius",
    "Pisces"
]


PLANETS = {
    "sun": swe.SUN,
    "moon": swe.MOON,
    "mercury": swe.MERCURY,
    "venus": swe.VENUS,
    "mars": swe.MARS,
    "jupiter": swe.JUPITER,
    "saturn": swe.SATURN,
}


ASPECTS = {
    "conjunction": 0,
    "sextile": 60,
    "square": 90,
    "trine": 120,
    "opposition": 180,
}


def get_sign(longitude):

    index = int(longitude / 30)

    return SIGNS[index]


def get_house(
    longitude,
    house_cusps
):

    for i in range(12):

        current_cusp = house_cusps[i]
        next_cusp = house_cusps[(i + 1) % 12]

        if current_cusp > next_cusp:
            next_cusp += 360

        adjusted_longitude = longitude

        if adjusted_longitude < current_cusp:
            adjusted_longitude += 360

        if current_cusp <= adjusted_longitude < next_cusp:
            return i + 1

    return 12


def calculate_aspects(
    planet_results,
    orb=6
):

    aspects = []

    planet_names = list(
        planet_results.keys()
    )

    for i in range(len(planet_names)):

        for j in range(i + 1, len(planet_names)):

            p1 = planet_names[i]
            p2 = planet_names[j]

            lon1 = planet_results[p1]["longitude"]
            lon2 = planet_results[p2]["longitude"]

            difference = abs(lon1 - lon2)

            if difference > 180:
                difference = 360 - difference

            for aspect_name, angle in ASPECTS.items():

                if abs(difference - angle) <= orb:

                    aspects.append({
                        "planet1": p1,
                        "planet2": p2,
                        "aspect": aspect_name,
                        "angle": round(difference, 2)
                    })

    return aspects


def get_chart(
    birth_date: str,
    birth_time: str,
    latitude: float,
    longitude: float
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

    planet_results = {}

    for name, planet_id in PLANETS.items():

        result = swe.calc_ut(
            julian_day,
            planet_id
        )

        planet_longitude = result[0][0]

        planet_results[name] = {
            "sign": get_sign(planet_longitude),
            "longitude": planet_longitude
        }

    houses_data = swe.houses(
        julian_day,
        latitude,
        longitude
    )

    house_cusps = houses_data[0]
    ascendant = houses_data[1][0]

    for planet_name, planet_data in planet_results.items():

        house_number = get_house(
            planet_data["longitude"],
            house_cusps
        )

        planet_data["house"] = house_number

    aspects = calculate_aspects(
        planet_results
    )

    return {
        "sun_sign": planet_results["sun"]["sign"],
        "moon_sign": planet_results["moon"]["sign"],
        "rising_sign": get_sign(ascendant),

        "planets": planet_results,

        "houses": {
            "ascendant": ascendant,
            "cusps": list(house_cusps)
        },

        "aspects": aspects
    }