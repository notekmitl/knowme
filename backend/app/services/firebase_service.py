from firebase_admin import firestore

from app.services.firebase_admin_service import initialize_firebase_admin

initialize_firebase_admin()

db = firestore.client()
