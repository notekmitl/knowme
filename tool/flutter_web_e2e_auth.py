"""Create Firebase Auth test user for Flutter Web E2E (requires firebase-admin auth)."""
import os
import sys
import time

BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend"))
os.chdir(BACKEND_DIR)
sys.path.insert(0, BACKEND_DIR)

from app.services import firebase_service  # noqa: E402, F401 — initializes app
from firebase_admin import auth  # noqa: E402

EMAIL = f"e2e.western.natal.{int(time.time())}@knowme.test"
PASSWORD = "E2eTestPass123!"
DISPLAY = "E2E Western Natal"


def main():
    try:
        user = auth.create_user(email=EMAIL, password=PASSWORD, display_name=DISPLAY)
        print(f"CREATED uid={user.uid}")
    except Exception as e:
        print(f"CREATE_FAILED {e}")
        sys.exit(1)
    print(f"EMAIL={EMAIL}")
    print(f"PASSWORD={PASSWORD}")


if __name__ == "__main__":
    main()
