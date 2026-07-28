#!/usr/bin/env python3
"""Read-only, privacy-safe Production Funnel Measurement V1.

The command reads owner-scoped production documents with the existing local
service account, keeps user identifiers in memory only, and emits aggregate
JSON. It never writes to Firestore and never includes a UID or profile value in
its output.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping

import firebase_admin
from firebase_admin import credentials, firestore


BANGKOK = timezone(timedelta(hours=7))
DEFAULT_START = datetime(2026, 6, 23, tzinfo=BANGKOK)
BASELINE_RATE = 1 / 38
TARGET_RATE = 0.25
MIN_DECISION_SAMPLE = 20
STAGE_EVENTS = ("mbti_start", "mbti_complete", "narrative_preview_seen")


@dataclass(frozen=True)
class UserObservation:
    """Minimum in-memory fields needed for aggregate measurement."""

    internal_key: str
    astrology_ready: bool
    events: tuple[tuple[str, datetime], ...]


def parse_instant(value: Any) -> datetime | None:
    if isinstance(value, datetime):
        parsed = value
    elif isinstance(value, str):
        try:
            parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return None
    else:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def percent(numerator: int, denominator: int) -> dict[str, Any]:
    return {
        "numerator": numerator,
        "denominator": denominator,
        "rate": None if denominator == 0 else numerator / denominator,
    }


def aggregate(
    observations: Iterable[UserObservation],
    *,
    start: datetime,
    end: datetime,
) -> dict[str, Any]:
    if start.tzinfo is None or end.tzinfo is None:
        raise ValueError("start and end must be timezone-aware")
    if end <= start:
        raise ValueError("end must be after start")

    eligible: set[str] = set()
    stage_users: dict[str, set[str]] = {
        event: set() for event in STAGE_EVENTS
    }
    event_counts: Counter[str] = Counter()
    duplicate_rows = 0
    invalid_stage_order = 0

    for user in observations:
        in_window = [
            (event, at)
            for event, at in user.events
            if start <= at.astimezone(timezone.utc) < end
        ]
        per_event = Counter(event for event, _ in in_window)
        duplicate_rows += sum(max(0, count - 1) for count in per_event.values())
        event_counts.update(per_event)

        if user.astrology_ready and per_event["home_view"] > 0:
            eligible.add(user.internal_key)
        for event in STAGE_EVENTS:
            if per_event[event] > 0:
                stage_users[event].add(user.internal_key)

        first_at: dict[str, datetime] = {}
        for event, at in sorted(in_window, key=lambda row: row[1]):
            first_at.setdefault(event, at)
        if (
            "mbti_start" in first_at
            and "mbti_complete" in first_at
            and first_at["mbti_complete"] < first_at["mbti_start"]
        ):
            invalid_stage_order += 1
        if (
            "mbti_complete" in first_at
            and "narrative_preview_seen" in first_at
            and first_at["narrative_preview_seen"] < first_at["mbti_complete"]
        ):
            invalid_stage_order += 1

    started = eligible & stage_users["mbti_start"]
    completed = eligible & stage_users["mbti_complete"]
    narrative = eligible & stage_users["narrative_preview_seen"]

    stage_counts = [
        ("eligible", len(eligible)),
        ("mbti_started", len(started)),
        ("mbti_completed", len(completed)),
        ("narrative_reached", len(narrative)),
    ]
    drop_offs = []
    for (from_name, from_count), (to_name, to_count) in zip(
        stage_counts, stage_counts[1:]
    ):
        lost = max(0, from_count - to_count)
        drop_offs.append(
            {
                "from": from_name,
                "to": to_name,
                "count": lost,
                "rate": None if from_count == 0 else lost / from_count,
            }
        )

    biggest = max(drop_offs, key=lambda item: (item["count"], item["rate"] or 0))
    narrative_rate = percent(len(narrative), len(eligible))
    enough_sample = len(eligible) >= MIN_DECISION_SAMPLE
    decision = "IMPROVE"
    decision_reason = (
        "Sample is below the minimum decision size; keep collecting the "
        "existing telemetry and improve the largest observed transition "
        "before making an effectiveness claim."
    )
    if enough_sample and narrative_rate["rate"] is not None:
        if narrative_rate["rate"] >= TARGET_RATE:
            decision = "KEEP"
            decision_reason = "Narrative reach meets or exceeds the 25% target."
        elif len(narrative) == 0:
            decision = "STOP"
            decision_reason = (
                "A decision-sized eligible cohort produced no narrative reach."
            )
        else:
            decision_reason = (
                "Narrative reach is below the 25% target; improve the largest "
                "observed funnel transition."
            )

    return {
        "schemaVersion": 1,
        "timezone": "Asia/Bangkok (UTC+07:00)",
        "window": {
            "startInclusive": start.astimezone(BANGKOK).isoformat(),
            "endExclusive": end.astimezone(BANGKOK).isoformat(),
        },
        "definitions": {
            "eligible": (
                "Authenticated user with profile.birthDate and at least one "
                "home_view event in the measurement window."
            ),
            "mbtiStarted": (
                "Eligible unique user with mbti_start; event-row counts are "
                "not used because current instrumentation can emit duplicates."
            ),
            "mbtiCompleted": (
                "Eligible unique user with mbti_complete, emitted only after "
                "the result and completed session are saved successfully."
            ),
            "narrativeReached": (
                "Eligible unique user with narrative_preview_seen after the "
                "MBTI narrative preview finishes loading."
            ),
        },
        "funnel": {
            "eligible": len(eligible),
            "mbtiStarted": len(started),
            "mbtiStartRate": percent(len(started), len(eligible)),
            "mbtiCompleted": len(completed),
            "mbtiCompletionRateFromEligible": percent(
                len(completed), len(eligible)
            ),
            "mbtiCompletionRateFromStarted": percent(
                len(completed), len(started)
            ),
            "narrativeReached": len(narrative),
            "narrativeReachRate": narrative_rate,
            "dropOffs": drop_offs,
            "biggestObservedDropOff": biggest,
        },
        "comparison": {
            "historicalBaseline": {
                "numerator": 1,
                "denominator": 38,
                "rate": BASELINE_RATE,
                "comparable": False,
                "reason": (
                    "The June baseline counts generated full Narrative output "
                    "among all Firestore accounts; V1 counts preview_seen among "
                    "active astrology-ready Home users."
                ),
            },
            "targetNarrativeReach": TARGET_RATE,
            "distanceToTarget": (
                None
                if narrative_rate["rate"] is None
                else narrative_rate["rate"] - TARGET_RATE
            ),
        },
        "dataQuality": {
            "eligibleSampleSize": len(eligible),
            "minimumDecisionSample": MIN_DECISION_SAMPLE,
            "decisionSized": enough_sample,
            "eventRowsByType": dict(sorted(event_counts.items())),
            "duplicateEventRows": duplicate_rows,
            "invalidStageOrderUsers": invalid_stage_order,
            "anonymousCoverage": False,
            "anonymousCoverageReason": (
                "FunnelTelemetry returns before writing when Firebase Auth has "
                "no current UID."
            ),
            "knownRisks": [
                "mbti_start is emitted by both Home CTA handlers and MBTI page bootstrap.",
                "home_view proves Home was opened, not that an astrology report was read.",
                "client at timestamps can differ from server createdAt.",
                "small samples cannot establish causal lift from Funnel Recovery V2.",
            ],
        },
        "decision": {
            "verdict": decision,
            "reason": decision_reason,
            "singleBottleneck": {
                "from": biggest["from"],
                "to": biggest["to"],
            },
        },
    }


def read_production(
    *,
    service_account: Path,
) -> tuple[list[UserObservation], int]:
    if not service_account.is_file():
        raise FileNotFoundError(f"Missing service account: {service_account}")
    if not firebase_admin._apps:
        firebase_admin.initialize_app(
            credentials.Certificate(str(service_account))
        )
    db = firestore.client()
    observations: list[UserObservation] = []
    invalid_timestamps = 0

    for user_doc in db.collection("users").stream():
        user_ref = db.collection("users").document(user_doc.id)
        profile_doc = user_ref.collection("profile").document("main").get()
        profile = (profile_doc.to_dict() or {}) if profile_doc.exists else {}
        events: list[tuple[str, datetime]] = []
        log_ref = (
            user_ref.collection("funnel_telemetry")
            .document("_events")
            .collection("log")
        )
        for event_doc in log_ref.stream():
            data: Mapping[str, Any] = event_doc.to_dict() or {}
            at = parse_instant(data.get("createdAt")) or parse_instant(
                data.get("at")
            )
            if at is None:
                invalid_timestamps += 1
                continue
            event = data.get("event")
            if isinstance(event, str) and event:
                events.append((event, at))
        observations.append(
            UserObservation(
                internal_key=user_doc.id,
                astrology_ready=bool(profile.get("birthDate")),
                events=tuple(events),
            )
        )
    return observations, invalid_timestamps


def local_midnight(value: str) -> datetime:
    return datetime.strptime(value, "%Y-%m-%d").replace(tzinfo=BANGKOK)


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    today = datetime.now(BANGKOK).date()
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--start",
        default=DEFAULT_START.date().isoformat(),
        help="Inclusive Bangkok date (YYYY-MM-DD).",
    )
    parser.add_argument(
        "--end",
        default=today.isoformat(),
        help="Exclusive Bangkok date (YYYY-MM-DD); defaults to today, excluding the partial day.",
    )
    parser.add_argument(
        "--service-account",
        type=Path,
        default=repo_root / "backend/firebase/serviceAccountKey.json",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional aggregate JSON output. Never contains user identifiers.",
    )
    args = parser.parse_args()

    try:
        observations, invalid_timestamps = read_production(
            service_account=args.service_account
        )
        result = aggregate(
            observations,
            start=local_midnight(args.start),
            end=local_midnight(args.end),
        )
        result["dataQuality"]["invalidTimestampRows"] = invalid_timestamps
    except Exception as error:
        print(f"Measurement failed: {error}", file=sys.stderr)
        return 1

    payload = json.dumps(result, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload + "\n", encoding="utf-8")
    print(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
