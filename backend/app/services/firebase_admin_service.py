"""Process-wide Firebase Admin initialization for the API runtime."""

import logging
import os

import firebase_admin
from firebase_admin import credentials

logger = logging.getLogger(__name__)


def initialize_firebase_admin():
    """Return the default Firebase app, creating it exactly once if needed."""
    try:
        return firebase_admin.get_app()
    except ValueError:
        pass

    cred_path = os.environ.get(
        "GOOGLE_APPLICATION_CREDENTIALS",
        "firebase/serviceAccountKey.json",
    )
    if os.path.isfile(cred_path):
        logger.info("Initializing Firebase Admin with service account file")
        cred = credentials.Certificate(cred_path)
        return firebase_admin.initialize_app(cred)

    logger.info("Initializing Firebase Admin with application default credentials")
    return firebase_admin.initialize_app()
