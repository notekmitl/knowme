import sys
from types import SimpleNamespace

from app.services.astrology import save_chart_service


class _Doc:
    def __init__(self, path):
        self.path = path

    def collection(self, name):
        return _Collection(f"{self.path}/{name}")


class _Collection:
    def __init__(self, path):
        self.path = path

    def document(self, name):
        return _Doc(f"{self.path}/{name}")


class _Batch:
    def __init__(self):
        self.sets = []
        self.deletes = []
        self.commits = 0

    def set(self, ref, data, merge=False):
        self.sets.append((ref.path, data, merge))

    def delete(self, ref):
        self.deletes.append(ref.path)

    def commit(self):
        self.commits += 1


class _Db:
    def __init__(self):
        self.batch_value = _Batch()

    def collection(self, name):
        return _Collection(name)

    def batch(self):
        return self.batch_value


def test_atomic_save_writes_profile_chart_snapshot_and_invalidates_fusion(monkeypatch):
    db = _Db()
    monkeypatch.setitem(
        sys.modules,
        "app.services.firebase_service",
        SimpleNamespace(db=db),
    )

    save_chart_service.save_chart(
        "uid-1",
        {"version": "western_natal_v2"},
        {"version": "western_natal_v2"},
        profile_data={"birthDate": "1982-06-06"},
    )

    paths = [item[0] for item in db.batch_value.sets]
    assert paths == [
        "users/uid-1",
        "users/uid-1/profile/main",
        "users/uid-1/astrology/western_natal",
        "users/uid-1/results/astrology",
    ]
    assert db.batch_value.deletes == ["users/uid-1/results/astrology_fusion"]
    assert db.batch_value.commits == 1


def test_results_snapshot_keeps_fusion_big3_contract():
    snapshot = save_chart_service.build_results_snapshot(
        {
            "version": "western_natal_v2",
            "contract_id": "knowme_western_reader_v2",
            "engine_version": "engine-v2",
            "input_hash": "abc",
            "big3": {"sun": "Gemini", "moon": "Sagittarius", "rising": "Pisces"},
            "planets": {},
        }
    )

    assert snapshot["element_summary"] == {
        "fire": 1,
        "earth": 0,
        "air": 1,
        "water": 1,
    }
    assert snapshot["modality_summary"] == {
        "cardinal": 0,
        "fixed": 0,
        "mutable": 3,
    }
    assert snapshot["mirrored_from"] == "astrology/western_natal"
