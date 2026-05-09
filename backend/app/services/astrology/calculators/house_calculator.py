import swisseph as swe


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


def calculate_houses(
    julian_day,
    latitude,
    longitude
):

    houses_data = swe.houses(
        julian_day,
        latitude,
        longitude
    )

    return {
        "cusps": houses_data[0],
        "ascendant": houses_data[1][0]
    }