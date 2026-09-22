import json

import pytest

from app.services import runtime_warmup


class _Document:
    def __init__(self, calls, error=None):
        self.calls = calls
        self.error = error

    def get(self):
        self.calls.append(("get", "runtime_health/firestore_warmup"))
        if self.error is not None:
            raise self.error
        return object()


class _Collection:
    def __init__(self, calls, error=None):
        self.calls = calls
        self.error = error

    def document(self, name):
        self.calls.append(("document", name))
        return _Document(self.calls, self.error)


class _Db:
    def __init__(self, calls, error=None):
        self.calls = calls
        self.error = error

    def collection(self, name):
        self.calls.append(("collection", name))
        return _Collection(self.calls, self.error)


def test_firestore_warmup_is_read_only_and_logs_no_user_data(monkeypatch, caplog):
    calls = []
    ticks = iter((10.0, 10.125))
    monkeypatch.setattr(runtime_warmup.time, "perf_counter", lambda: next(ticks))
    monkeypatch.setenv("K_REVISION", "revision-test")

    with caplog.at_level("INFO"):
        elapsed = runtime_warmup.warm_firestore_connection(_Db(calls))

    assert elapsed == 125.0
    assert calls == [
        ("collection", "runtime_health"),
        ("document", "firestore_warmup"),
        ("get", "runtime_health/firestore_warmup"),
    ]
    payload = json.loads(caplog.records[-1].message)
    assert payload == {
        "duration_ms": 125.0,
        "event": "firestore_startup_warmup",
        "revision": "revision-test",
        "status": "ready",
    }
    assert "token" not in caplog.records[-1].message.lower()


def test_firestore_warmup_fails_startup_when_connectivity_is_not_ready(
    monkeypatch,
):
    ticks = iter((20.0, 20.5))
    monkeypatch.setattr(runtime_warmup.time, "perf_counter", lambda: next(ticks))

    with pytest.raises(RuntimeError, match="not ready"):
        runtime_warmup.warm_firestore_connection(
            _Db([], error=RuntimeError("not ready"))
        )
