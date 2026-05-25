import logging
import os
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

logger = logging.getLogger(__name__)

def init_firebase():
    if not firebase_admin._apps:
        # Cek apakah file firebase-credentials.json ada di root aplikasi
        local_cert = "firebase-credentials.json"
        cert_path = os.getenv("FIREBASE_CERT_PATH", local_cert)
        
        if os.path.exists(cert_path):
            logger.info("[Firebase] Using credentials from: %s", cert_path)
            cred = credentials.Certificate(cert_path)
            firebase_admin.initialize_app(cred)
        else:
            logger.warning("[Firebase] Credentials file not found, falling back to Default Credentials.")
            # Gunakan Application Default Credentials (otomatis di Cloud Run)
            try:
                firebase_admin.initialize_app()
            except Exception as e:
                logger.exception("Firebase init error: %s", e)

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
        logger.exception("Gagal sync ke Firebase: %s", e)


def add_global_chat_message(sender_id: int, sender_name: str, text: str) -> dict:
    try:
        db = get_firestore()
        messages_ref = (
            db.collection("global_chat").document("room").collection("messages")
        )
        payload = {
            "text": text,
            "sender_id": sender_id,
            "sender_name": sender_name,
            "created_at": firestore.SERVER_TIMESTAMP,
        }
        doc_ref = messages_ref.document()
        doc_ref.set(payload)
        logger.info("[Chat] Message stored: sender_id=%s doc_id=%s", sender_id, doc_ref.id)

        return {
            "id": doc_ref.id,
            "text": text,
            "sender_id": sender_id,
            "sender_name": sender_name,
            "created_at": None,
        }
    except Exception as e:
        logger.exception("[Chat] Failed to store message: %s", e)
        raise


def list_global_chat_messages(limit: int = 50) -> list[dict]:
    try:
        db = get_firestore()
        query = (
            db.collection("global_chat")
            .document("room")
            .collection("messages")
            .order_by("created_at", direction=firestore.Query.DESCENDING)
            .limit(limit)
        )
        results: list[dict] = []
        for doc in query.stream():
            data = doc.to_dict() or {}
            created_at = data.get("created_at")
            created_at_str = None
            if hasattr(created_at, "isoformat"):
                created_at_str = created_at.isoformat()
            elif isinstance(created_at, str):
                created_at_str = created_at

            results.append(
                {
                    "id": doc.id,
                    "text": data.get("text", ""),
                    "sender_id": data.get("sender_id"),
                    "sender_name": data.get("sender_name", "Pengguna"),
                    "created_at": created_at_str,
                }
            )

        logger.info("[Chat] Loaded %s messages", len(results))
        return results
    except Exception as e:
        logger.exception("[Chat] Failed to load messages: %s", e)
        raise