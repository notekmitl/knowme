from app.services.astrology.interpretations.en.planet_signs import (
    PLANET_SIGN_INTERPRETATIONS as EN_INTERPRETATIONS
)

from app.services.astrology.interpretations.th.planet_signs import (
    PLANET_SIGN_INTERPRETATIONS as TH_INTERPRETATIONS
)


def generate_interpretations(
    planets
):

    results = []

    for planet_name, planet_data in planets.items():

        sign = planet_data["sign"].lower()

        key = f"{planet_name}_{sign}"

        results.append({
            "planet": planet_name,

            "en":
                EN_INTERPRETATIONS.get(
                    key,
                    ""
                ),

            "th":
                TH_INTERPRETATIONS.get(
                    key,
                    ""
                )
        })

    return results