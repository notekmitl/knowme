import logging
import os

import firebase_admin
from firebase_admin import credentials, firestore

logger = logging.getLogger(__name__)

if not firebase_admin._apps:
    cred_path = os.environ.get(
        "GOOGLE_APPLICATION_CREDENTIALS",
        "firebase/serviceAccountKey.json",
    )
    if os.path.isfile(cred_path):
        logger.info("Initializing Firebase Admin with service account file")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    else:
        logger.info("Initializing Firebase Admin with application default credentials")
        firebase_admin.initialize_app()

db = firestore.client()
