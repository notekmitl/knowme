import importlib.util
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
SPEC = importlib.util.spec_from_file_location("pr89_v14_packet", ROOT / "tool" / "pr89_v14_packet.py")
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)
OBSERVATIONS = json.loads(
    (ROOT / "tool" / "pr89_v14_visual_review_r15.json").read_text(encoding="utf-8")
)["pages"]
EXPECTED = [
    (fixture, page, count)
    for fixture, count in (("known-time", 6), ("unknown-time", 5))
    for page in range(1, count + 1)
]


class VisualReviewEvidenceTest(unittest.TestCase):
    def test_final_r15_observations_are_complete_and_page_specific(self):
        MODULE.validate_observations(OBSERVATIONS, EXPECTED)
        self.assertEqual(len(OBSERVATIONS), 11)
        self.assertEqual(len({(row["fixture"], row["page"]) for row in OBSERVATIONS}), 11)
        self.assertEqual(OBSERVATIONS[0]["first_heading"], "KnowMe — รายงานโหรไทย")
        self.assertNotEqual(OBSERVATIONS[0]["first_heading"], "หน้า 1 / 6")
        self.assertEqual(OBSERVATIONS[5]["continuation_heading"], "โครงสร้างดวงหลัก — ต่อ")
        self.assertEqual(OBSERVATIONS[10]["continuation_heading"], "รายงานนี้ดูจากอะไร — ต่อ")
        self.assertTrue(all(row["continuation_heading"] == "none" for row in OBSERVATIONS if row not in (OBSERVATIONS[5], OBSERVATIONS[10])))
        self.assertTrue(all(isinstance(row["cards_present"], list) and row["cards_present"] for row in OBSERVATIONS))

    def test_generic_placeholder_is_rejected(self):
        rows = [dict(row) for row in OBSERVATIONS]
        rows[0]["split_state"] = "complete or intentionally continued with visible orientation"
        with self.assertRaisesRegex(ValueError, "Generic placeholder"):
            MODULE.validate_observations(rows, EXPECTED)

    def test_footer_heading_is_rejected(self):
        rows = [dict(row) for row in OBSERVATIONS]
        rows[0]["first_heading"] = "หน้า 1 / 6"
        with self.assertRaisesRegex(ValueError, "Footer recorded as heading"):
            MODULE.validate_observations(rows, EXPECTED)

    def test_page_identity_mismatch_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "page identities do not match"):
            MODULE.validate_observations(OBSERVATIONS[:-1], EXPECTED)


if __name__ == "__main__":
    unittest.main()
