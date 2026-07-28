from datetime import datetime, timezone
import importlib.util
from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[3]
SPEC = importlib.util.spec_from_file_location(
    "production_funnel_measurement",
    ROOT / "tool" / "production_funnel_measurement.py",
)
assert SPEC and SPEC.loader
measurement = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = measurement
SPEC.loader.exec_module(measurement)


def at(day: int, hour: int = 0) -> datetime:
    return datetime(2026, 7, day, hour, tzinfo=timezone.utc)


class ProductionFunnelMeasurementTest(unittest.TestCase):
    def test_unique_users_not_duplicate_rows_define_stages(self):
        rows = [
            measurement.UserObservation(
                "internal-a",
                True,
                (
                    ("home_view", at(1)),
                    ("mbti_start", at(2)),
                    ("mbti_start", at(2, 1)),
                    ("mbti_complete", at(3)),
                    ("narrative_preview_seen", at(3, 1)),
                ),
            ),
            measurement.UserObservation(
                "internal-b",
                True,
                (("home_view", at(1)),),
            ),
        ]

        result = measurement.aggregate(rows, start=at(1), end=at(5))

        funnel = result["funnel"]
        self.assertEqual(funnel["eligible"], 2)
        self.assertEqual(funnel["mbtiStarted"], 1)
        self.assertEqual(funnel["mbtiCompleted"], 1)
        self.assertEqual(funnel["narrativeReached"], 1)
        self.assertEqual(funnel["mbtiStartRate"]["numerator"], 1)
        self.assertEqual(funnel["mbtiStartRate"]["denominator"], 2)
        self.assertEqual(result["dataQuality"]["duplicateEventRows"], 1)

    def test_non_astrology_home_user_is_not_eligible(self):
        result = measurement.aggregate(
            [
                measurement.UserObservation(
                    "internal-a",
                    False,
                    (("home_view", at(1)), ("mbti_start", at(2))),
                )
            ],
            start=at(1),
            end=at(5),
        )

        self.assertEqual(result["funnel"]["eligible"], 0)
        self.assertEqual(result["funnel"]["mbtiStarted"], 0)
        self.assertIsNone(result["funnel"]["narrativeReachRate"]["rate"])

    def test_end_is_exclusive_and_small_sample_is_improve(self):
        result = measurement.aggregate(
            [
                measurement.UserObservation(
                    "internal-a",
                    True,
                    (("home_view", at(1)), ("mbti_start", at(5))),
                )
            ],
            start=at(1),
            end=at(5),
        )

        self.assertEqual(result["funnel"]["eligible"], 1)
        self.assertEqual(result["funnel"]["mbtiStarted"], 0)
        self.assertEqual(result["decision"]["verdict"], "IMPROVE")
        self.assertFalse(result["dataQuality"]["decisionSized"])

    def test_output_contract_contains_no_internal_keys(self):
        result = measurement.aggregate(
            [
                measurement.UserObservation(
                    "secret-internal-key",
                    True,
                    (("home_view", at(1)),),
                )
            ],
            start=at(1),
            end=at(5),
        )

        self.assertNotIn("secret-internal-key", str(result))


if __name__ == "__main__":
    unittest.main()
