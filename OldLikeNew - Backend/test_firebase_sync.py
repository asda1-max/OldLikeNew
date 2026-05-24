import os
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

load_dotenv()

class DummyAuction:
    def __init__(self):
        self.id = 9999
        self.item_id = 8888
        self.status = "active"
        self.current_price = 150000.0
        self.end_time = datetime.now(timezone.utc) + timedelta(days=1)
        self.winner_id = None

from app.services.firebase_service import sync_auction_to_firebase

def test():
    print("Mencoba sync ke Firebase...")
    auction = DummyAuction()
    try:
        sync_auction_to_firebase(auction)
        print("[SUCCESS] Sync berhasil! Cek Firestore untuk dokumen ID '9999'.")
    except Exception as e:
        print(f"[FAILED] Sync gagal: {e}")

if __name__ == "__main__":
    test()
