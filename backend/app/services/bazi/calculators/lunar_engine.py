"""Thin wrapper around lunar_python for KnowMe BaZi V1."""

from lunar_python import Solar

from app.services.bazi.constants import ENGINE_POLICY


class BaziComputeError(RuntimeError):
    """Raised when lunar_python fails to produce EightChar."""


def compute_eight_char(
    year: int,
    month: int,
    day: int,
    hour: int,
    minute: int,
    second: int,
):
    """
    Build Solar → Lunar → EightChar for local civil datetime.

    Year pillar uses 立春 (Li Chun) via EightChar Exact methods.
    Month pillar uses 节 (Jie) solar terms via library Exact methods.
    """
    try:
        solar = Solar.fromYmdHms(year, month, day, hour, minute, second)
        lunar = solar.getLunar()
        eight_char = lunar.getEightChar()
        if ENGINE_POLICY["eight_char_sect"] == 2:
            eight_char.setSect(2)
        return lunar, eight_char
    except Exception as exc:
        raise BaziComputeError(str(exc)) from exc
