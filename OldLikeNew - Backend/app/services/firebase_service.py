import os
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

def init_firebase():
    if not firebase_admin._apps:
        # Gunakan file key JSON jika testing di lokal (via path ke set environment variable)
        cert_path = os.getenv("FIREBASE_CERT_PATH")
        if cert_path and os.path.exists(cert_path):
            cred = credentials.Certificate(cert_path)
            firebase_admin.initialize_app(cred)
        else:
            # Gunakan Application Default Credentials (otomatis di Cloud Run)
            try:
                firebase_admin.initialize_app()
            except Exception as e:
                print("Firebase init error:", e)

def get_firestore():
    init_firebase()
    return firestore.client()

def sync_auction_to_firebase(auction):
    """
    Sinkronisasi state auction di SQLite ke Firestore realtime
    """
    try:
        db = get_firestore()
        doc_ref = db.collection("auctions").document(str(auction.id))
        doc_ref.set({
            "id": auction.id,
            "item_id": auction.item_id,
            "status": auction.status,
            "current_price": float(auction.current_price),
            "end_time": auction.end_time.isoformat(),
            "winner_id": auction.winner_id,
        }, merge=True)
    except Exception as e:
        print("Gagal sync ke Firebase:", e)
