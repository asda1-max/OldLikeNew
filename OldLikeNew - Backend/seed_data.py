from datetime import datetime, timedelta
from app.database import SessionLocal, init_db
from app.models.item import Item
from app.models.auction import Auction
from app.models.bid import Bid
from app.services.auth_service import create_user


def run_seed():
    init_db()
    db = SessionLocal()
    try:
        admin = create_user(db, "Admin", "admin@lelangku.local", "admin123", "admin")
        seller = create_user(db, "Seller", "seller@lelangku.local", "seller123", "seller")
        buyer = create_user(db, "Buyer", "buyer@lelangku.local", "buyer123", "buyer")

        item1 = Item(
            seller_id=seller.id,
            title="Laptop Second",
            description="Laptop bekas kondisi 80%",
            category="electronics",
            condition="used",
            image_urls=[],
        )
        db.add(item1)
        db.commit()
        db.refresh(item1)

        auction1 = Auction(
            item_id=item1.id,
            seller_id=seller.id,
            start_price=5000000,
            current_price=5000000,
            buyout_price=7000000,
            start_time=datetime.utcnow(),
            end_time=datetime.utcnow() + timedelta(days=3),
            status="active",
        )
        db.add(auction1)
        db.commit()
        db.refresh(auction1)

        bid1 = Bid(auction_id=auction1.id, bidder_id=buyer.id, amount=5100000)
        db.add(bid1)
        auction1.current_price = 5100000
        db.add(auction1)
        db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    run_seed()
