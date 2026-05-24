from datetime import datetime
from decimal import Decimal
from sqlalchemy.orm import Session
from app.models.auction import Auction
from app.models.bid import Bid
from app.models.transaction import Transaction
from app.services.firebase_service import sync_auction_to_firebase

MIN_INCREMENT = Decimal("1000")


def get_highest_bid(db: Session, auction_id: int) -> Bid | None:
    return (
        db.query(Bid)
        .filter(Bid.auction_id == auction_id)
        .order_by(Bid.amount.desc())
        .first()
    )


def create_transaction(db: Session, auction: Auction, winner_id: int, final_price: Decimal) -> Transaction:
    existing = db.query(Transaction).filter(Transaction.auction_id == auction.id).first()
    if existing:
        return existing
    transaction = Transaction(
        auction_id=auction.id,
        buyer_id=winner_id,
        seller_id=auction.seller_id,
        final_price=final_price,
    )
    db.add(transaction)
    return transaction


def close_auction(db: Session, auction: Auction) -> Auction:
    if auction.status in {"closed", "cancelled"}:
        return auction
    highest_bid = get_highest_bid(db, auction.id)
    if highest_bid:
        auction.winner_id = highest_bid.bidder_id
        auction.current_price = highest_bid.amount
        create_transaction(db, auction, highest_bid.bidder_id, highest_bid.amount)
    auction.status = "closed"
    db.add(auction)
    db.commit()
    db.refresh(auction)
    
    # Sync status penutupan ke Firebase
    sync_auction_to_firebase(auction)
    
    return auction


def close_expired_auctions(db: Session) -> int:
    now = datetime.utcnow()
    auctions = (
        db.query(Auction)
        .filter(Auction.status == "active", Auction.end_time <= now)
        .all()
    )
    count = 0
    for auction in auctions:
        close_auction(db, auction)
        count += 1
    return count


def apply_buyout_if_needed(db: Session, auction: Auction, bid_amount: Decimal, bidder_id: int) -> bool:
    if auction.buyout_price is None:
        return False
    if bid_amount >= Decimal(auction.buyout_price):
        auction.winner_id = bidder_id
        auction.current_price = bid_amount
        auction.status = "closed"
        create_transaction(db, auction, bidder_id, bid_amount)
        db.add(auction)
        db.commit()
        db.refresh(auction)
        return True
    return False
