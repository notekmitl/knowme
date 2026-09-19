import sys
from datetime import datetime
from types import SimpleNamespace

from app.services.bazi import save_bazi_service


class _Document:
    def __init__(self, path: str):
        self.path = path

    def collection(self, name: str):
        return _Collection(f"{self.path}/{name}")


class _Collection:
    def __init__(self, path: str):
        self.path = path

    def document(self, name: str):
        return _Document(f"{self.path}/{name}")


class _Batch:
    def __init__(self):
        self.writes = []
        self.deletes = []
        self.commit_count = 0

    def set(self, ref, value, merge=False):
        self.writes.append((ref.path, value, merge))

    def delete(self, ref):
        self.deletes.append(ref.path)

    def commit(self):
        self.commit_count += 1


class _Firestore:
    def __init__(self):
        self.created_batch = _Batch()

    def collection(self, name: str):
        return _Collection(name)

    def batch(self):
        return self.created_batch


def test_save_bazi_commits_all_documents_in_one_batch(monkeypatch):
    firestore = _Firestore()
    monkeypatch.setitem(
        sys.modules,
        "app.services.firebase_service",
        SimpleNamespace(db=firestore),
    )

    chart = {"contract_id": "knowme_bazi_reader_v3"}
    result = {"status": "completed"}
    profile = {
        "name": "Test User",
        "gender": "male",
        "birthDate": "1990-05-12",
        "birthTime": "15:30",
        "birthPlace": "Bangkok",
        "latitude": 13.7563,
        "longitude": 100.5018,
        "timezone": "Asia/Bangkok",
    }

    assert (
        save_bazi_service.save_bazi(
            "uid-1",
            chart,
            result,
            profile_data=profile,
        )
        is True
    )

    batch = firestore.created_batch
    assert batch.commit_count == 1
    assert [write[0] for write in batch.writes] == [
        "users/uid-1",
        "users/uid-1/profile/main",
        "users/uid-1/astrology/chinese_bazi",
        "users/uid-1/results/chinese_bazi",
    ]
    assert isinstance(batch.writes[0][1]["updatedAt"], datetime)
    assert batch.writes[0][2] is True
    assert batch.writes[1] == ("users/uid-1/profile/main", profile, False)
    assert batch.writes[2] == (
        "users/uid-1/astrology/chinese_bazi",
        chart,
        False,
    )
    assert batch.writes[3] == (
        "users/uid-1/results/chinese_bazi",
        result,
        False,
    )
    assert batch.deletes == ["users/uid-1/results/astrology_fusion"]
