from datetime import datetime
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.models.auction import Auction
from app.models.bid import Bid
from app.models.user import User
from app.schemas.bid import BidCreate, BidOut
from app.services.auction_service import MIN_INCREMENT, apply_buyout_if_needed
from app.services.firebase_service import sync_auction_to_firebase
from app.utils.dependencies import get_db, require_roles

router = APIRouter(prefix="/bids", tags=["bids"])


@router.get("/my", response_model=list[BidOut])
def my_bids(db: Session = Depends(get_db), current_user: User = Depends(require_roles("buyer"))):
    return (
        db.query(Bid)
        .filter(Bid.bidder_id == current_user.id)
        .order_by(Bid.created_at.desc())
        .all()
    )


@router.post("/{auction_id}", response_model=BidOut)
def place_bid(
    auction_id: int,
    payload: BidCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("buyer")),
):
    auction = db.query(Auction).filter(Auction.id == auction_id).first()
    if not auction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Auction not found")
    if auction.status != "active":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Auction not active")
    if auction.end_time <= datetime.utcnow():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Auction ended")
    if auction.seller_id == current_user.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Seller cannot bid")

    amount = Decimal(str(payload.amount))
    min_required = Decimal(str(auction.current_price)) + MIN_INCREMENT
    if amount <= min_required:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bid must be greater than {min_required}",
        )

    bid = Bid(auction_id=auction.id, bidder_id=current_user.id, amount=amount)
    auction.current_price = amount
    db.add(bid)
    db.add(auction)
    db.commit()
    db.refresh(bid)

    apply_buyout_if_needed(db, auction, amount, current_user.id)
    
    # Sync status terbaru ke Firebase Realtime/Firestore
    sync_auction_to_firebase(auction)
    
    return bid


@router.get("/{auction_id}", response_model=list[BidOut])
def list_bids(auction_id: int, db: Session = Depends(get_db)):
    return (
        db.query(Bid)
        .filter(Bid.auction_id == auction_id)
        .order_by(Bid.created_at.desc())
        .all()
    )
