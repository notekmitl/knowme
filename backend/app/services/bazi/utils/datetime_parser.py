"""Parse governed BaZi birth input with strict IANA-zone resolution."""

from datetime import datetime, timezone as dt_timezone
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

    The known-time calculation path calls this only when time is present.
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

    dt = resolve_local_datetime(dt, _validate_timezone(timezone))
    return (
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
    )


def parse_birth_datetime_aware(
    birth_date: str,
    birth_time: str | None,
    timezone: str,
) -> datetime:
    """Return one unambiguous, existing historical local civil datetime."""
    if not has_known_birth_time(birth_time):
        raise MissingBirthTime("birth_time is required for Known-time BaZi")

    time_part = str(birth_time).strip()
    try:
        naive = datetime.strptime(
            f"{birth_date} {time_part}",
            "%Y-%m-%d %H:%M",
        )
    except ValueError as exc:
        raise InvalidBirthDatetime(
            f"Invalid birth_date/birth_time: {birth_date} {time_part}"
        ) from exc
    return resolve_local_datetime(naive, _validate_timezone(timezone))


def resolve_local_datetime(naive: datetime, zone: ZoneInfo) -> datetime:
    """Resolve a local clock reading without choosing a DST fold by guess."""
    candidates: list[datetime] = []
    for fold in (0, 1):
        aware = naive.replace(tzinfo=zone, fold=fold)
        round_trip = aware.astimezone(dt_timezone.utc).astimezone(zone)
        if round_trip.replace(tzinfo=None) == naive:
            candidates.append(aware)

    if not candidates:
        raise InvalidBirthDatetime(
            "birth time does not exist in the historical timezone transition"
        )

    offsets = {candidate.utcoffset() for candidate in candidates}
    if len(offsets) > 1:
        raise InvalidBirthDatetime(
            "birth time is ambiguous in the historical timezone transition"
        )
    return candidates[0]
