"""Parse Compatibility V1 birth input as local civil calendar fields."""

from datetime import datetime
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


class InvalidBirthDatetime(ValueError):
    """Raised when birth date/time or timezone cannot be parsed."""


class MissingBirthTime(ValueError):
    """Legacy error retained for callers that explicitly require known time."""


def has_known_birth_time(birth_time: str | None) -> bool:
    """Return whether the caller supplied a non-empty civil clock time."""
    return birth_time is not None and bool(str(birth_time).strip())


def parse_birth_date(
    birth_date: str,
    timezone: str,
) -> tuple[int, int, int]:
    """Validate the IANA zone and return Gregorian local-civil date fields."""
    _validate_timezone(timezone)

    try:
        parsed = datetime.strptime(str(birth_date).strip(), "%Y-%m-%d")
    except ValueError as exc:
        raise InvalidBirthDatetime(
            f"Invalid birth_date: {birth_date}"
        ) from exc

    return parsed.year, parsed.month, parsed.day


def _validate_timezone(timezone: str) -> ZoneInfo:
    zone_name = str(timezone).strip()
    if not zone_name:
        raise InvalidBirthDatetime("Invalid timezone: timezone is required")

    try:
        return ZoneInfo(zone_name)
    except ZoneInfoNotFoundError as exc:
        raise InvalidBirthDatetime(f"Invalid timezone: {timezone}") from exc


def parse_birth_datetime(
    birth_date: str,
    birth_time: str | None,
    timezone: str,
) -> tuple[int, int, int, int, int, int]:
    """
    Returns (year, month, day, hour, minute, second) in local civil time.

    Compatibility V1 calls this only for Known-time input.
    """
    if not has_known_birth_time(birth_time):
        raise MissingBirthTime("birth_time is required for Known-time BaZi")

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

    dt = dt.replace(tzinfo=_validate_timezone(timezone))
    return (
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
    )
