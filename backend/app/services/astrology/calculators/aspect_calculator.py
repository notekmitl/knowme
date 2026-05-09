from app.services.astrology.constants import ASPECTS


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