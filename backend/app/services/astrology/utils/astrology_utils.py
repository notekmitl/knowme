from app.services.astrology.constants import SIGNS


def get_sign(longitude):

    index = int(longitude / 30)

    return SIGNS[index]