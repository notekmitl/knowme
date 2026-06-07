"""Parse birth date/time into local civil datetime components."""

from datetime import datetime
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


class InvalidBirthDatetime(ValueError):
    """Raised when birth date/time or timezone cannot be parsed."""


class MissingBirthTime(ValueError):
    """Raised when birth_time is required but absent."""


def parse_birth_datetime(
    birth_date: str,
    birth_time: str,
    timezone: str,
) -> tuple[int, int, int, int, int, int]:
    """
    Returns (year, month, day, hour, minute, second) in local civil time.

    KnowMe BaZi V1 requires birth_time — no three-pillar mode.
    """
    if not birth_time or not str(birth_time).strip():
        raise MissingBirthTime("birth_time is required for BaZi V1")

    try:
        tz = ZoneInfo(timezone)
    except ZoneInfoNotFoundError as exc:
        raise InvalidBirthDatetime(f"Invalid timezone: {timezone}") from exc

    time_part = str(birth_time).strip()
    try:
        dt = datetime.strptime(
            f"{birth_date} {time_part}",
            "%Y-%m-%d %H:%M",
        )
    except ValueError as exc:
        raise InvalidBirthDatetime(
            f"Invalid birth_date/birth_time: {birth_date} {time_part}"
        ) from exc

    dt = dt.replace(tzinfo=tz)
    return (
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
    )
