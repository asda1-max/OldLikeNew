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


def _ts_to_str(value) -> str | None:
    if hasattr(value, "isoformat"):
        return value.isoformat()
    if isinstance(value, str):
        return value
    return None


def build_direct_thread_id(buyer_id: int, seller_id: int) -> str:
    return f"buyer_{buyer_id}_seller_{seller_id}"


def get_direct_chat_thread(thread_id: str) -> dict | None:
    try:
        db = get_firestore()
        doc = db.collection("chats").document(thread_id).get()
        if not doc.exists:
            return None
        data = doc.to_dict() or {}
        data["id"] = doc.id
        return data
    except Exception as e:
        logger.exception("[Chat] Failed to load thread: %s", e)
        raise


def list_direct_chat_threads(user_id: int, limit: int = 50) -> list[dict]:
    try:
        db = get_firestore()
        query = (
            db.collection("chats")
            .where("participants", "array_contains", user_id)
            .limit(limit * 2) # increased limit to allow sorting top recent ones locally
        )
        results: list[dict] = []
        for doc in query.stream():
            data = doc.to_dict() or {}
            results.append(
                {
                    "id": doc.id,
                    "buyer_id": data.get("buyer_id"),
                    "seller_id": data.get("seller_id"),
                    "buyer_name": data.get("buyer_name", "Pembeli"),
                    "seller_name": data.get("seller_name", "Penjual"),
                    "last_message": data.get("last_message"),
                    "last_message_at": _ts_to_str(data.get("last_message_at")),
                }
            )

        # Sort the threads locally by last_message_at descending
        results.sort(
            key=lambda x: x["last_message_at"] if x["last_message_at"] else "",
            reverse=True
        )
        results = results[:limit]

        logger.info("[Chat] Loaded %s threads", len(results))
        return results
    except Exception as e:
        logger.exception("[Chat] Failed to load threads: %s", e)
        raise


def list_direct_chat_messages(thread_id: str, limit: int = 50) -> list[dict]:
    try:
        db = get_firestore()
        query = (
            db.collection("chats")
            .document(thread_id)
            .collection("messages")
            .order_by("created_at", direction=firestore.Query.DESCENDING)
            .limit(limit)
        )
        results: list[dict] = []
        for doc in query.stream():
            data = doc.to_dict() or {}
            results.append(
                {
                    "id": doc.id,
                    "text": data.get("text", ""),
                    "sender_id": data.get("sender_id"),
                    "sender_name": data.get("sender_name", "Pengguna"),
                    "created_at": _ts_to_str(data.get("created_at")),
                }
            )

        logger.info("[Chat] Loaded %s messages for thread=%s", len(results), thread_id)
        return results
    except Exception as e:
        logger.exception("[Chat] Failed to load messages: %s", e)
        raise


def add_direct_chat_message(
    buyer_id: int,
    seller_id: int,
    buyer_name: str,
    seller_name: str,
    sender_id: int,
    sender_name: str,
    text: str,
) -> dict:
    try:
        db = get_firestore()
        thread_id = build_direct_thread_id(buyer_id, seller_id)
        thread_ref = db.collection("chats").document(thread_id)
        message_ref = thread_ref.collection("messages").document()

        payload = {
            "text": text,
            "sender_id": sender_id,
            "sender_name": sender_name,
            "created_at": firestore.SERVER_TIMESTAMP,
        }

        thread_ref.set(
            {
                "buyer_id": buyer_id,
                "seller_id": seller_id,
                "buyer_name": buyer_name,
                "seller_name": seller_name,
                "participants": [buyer_id, seller_id],
                "last_message": text,
                "last_message_at": firestore.SERVER_TIMESTAMP,
                "last_sender_id": sender_id,
                "created_at": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )
        message_ref.set(payload)

        logger.info("[Chat] Direct message stored: thread=%s sender_id=%s", thread_id, sender_id)
        return {
            "id": message_ref.id,
            "text": text,
            "sender_id": sender_id,
            "sender_name": sender_name,
            "created_at": None,
        }
    except Exception as e:
        logger.exception("[Chat] Failed to store direct message: %s", e)
        raise