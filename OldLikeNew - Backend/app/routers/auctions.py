from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.models.auction import Auction
from app.models.bid import Bid
from app.models.item import Item
from app.models.user import User
from app.schemas.auction import AuctionCreate, AuctionDetail, AuctionOut, AuctionUpdate
from app.services.auction_service import close_auction
from app.services.firebase_service import sync_auction_to_firebase
from app.utils.dependencies import get_current_user, get_db, require_roles

router = APIRouter(prefix="/auctions", tags=["auctions"])


@router.post("/", response_model=AuctionOut)
def create_auction(
    payload: AuctionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("seller")),
):
    print(f"[Create Auction] Incoming request for item_id: {payload.item_id} by user_id: {current_user.id}")
    item = db.query(Item).filter(Item.id == payload.item_id).first()
    if not item:
        print(f"[Create Auction] Failed: Item {payload.item_id} not found.")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")

    if not item.is_verified:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Item not verified")
    
    print(f"[Create Auction] Item found. Verifying ownership...")
    if item.seller_id != current_user.id and current_user.role != "admin":
        print(f"[Create Auction] Failed: User {current_user.id} does not own item {payload.item_id}.")
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    start_time = payload.start_time or datetime.utcnow()
    if payload.end_time <= start_time:
        print("[Create Auction] Failed: Invalid end_time. Must be after start_time.")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid end_time")
    if payload.buyout_price is not None and payload.buyout_price < payload.start_price:
        print("[Create Auction] Failed: Buyout price cannot be lower than start price.")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid buyout_price")

    print(f"[Create Auction] Creating auction in DB (start_price: {payload.start_price}, end_time: {payload.end_time})")
    auction = Auction(
        item_id=item.id,
        seller_id=item.seller_id,
        start_price=payload.start_price,
        current_price=payload.start_price,
        buyout_price=payload.buyout_price,
        start_time=start_time,
        end_time=payload.end_time,
        status="active",
    )
    db.add(auction)
    db.commit()
    db.refresh(auction)
    
    print(f"[Create Auction] Auction saved in DB with ID: {auction.id}. Syncing to Firebase...")
    # Sync status awal ke Firebase
    sync_auction_to_firebase(auction)
    
    print(f"[Create Auction] Process complete for auction ID: {auction.id}")
    return auction


@router.get("/", response_model=list[AuctionOut])
def list_auctions(
    status_filter: str | None = Query(default=None, alias="status"),
    category: str | None = None,
    db: Session = Depends(get_db),
):
    query = db.query(Auction).join(Item)
    if status_filter:
        query = query.filter(Auction.status == status_filter)
    else:
        query = query.filter(Auction.status == "active")
    if category:
        query = query.filter(Item.category == category)
    return query.order_by(Auction.end_time.asc()).all()


@router.get("/{auction_id}", response_model=AuctionDetail)
def get_auction_detail(auction_id: int, db: Session = Depends(get_db)):
    auction = db.query(Auction).filter(Auction.id == auction_id).first()
    if not auction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Auction not found")
    bids = (
        db.query(Bid)
        .filter(Bid.auction_id == auction_id)
        .order_by(Bid.created_at.desc())
        .limit(20)
        .all()
    )
    auction.bids = list(reversed(bids))
    return auction


@router.put("/{auction_id}", response_model=AuctionOut)
def update_auction(
    auction_id: int,
    payload: AuctionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("seller")),
):
    auction = db.query(Auction).filter(Auction.id == auction_id).first()
    if not auction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Auction not found")
    if current_user.role != "admin" and auction.seller_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    if payload.status == "cancelled":
        has_bids = db.query(Bid).filter(Bid.auction_id == auction_id).first()
        if has_bids:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot cancel auction with bids",
            )
        auction.status = "cancelled"
    if payload.end_time:
        if payload.end_time <= auction.start_time:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid end_time")
        auction.end_time = payload.end_time

    if auction.status == "active" and auction.end_time <= datetime.utcnow():
        auction = close_auction(db, auction)
    else:
        db.add(auction)
        db.commit()
        db.refresh(auction)
        
    sync_auction_to_firebase(auction)
    return auction


@router.get("/my", response_model=list[AuctionOut])
def my_auctions(db: Session = Depends(get_db), current_user: User = Depends(require_roles("seller"))):
    return db.query(Auction).filter(Auction.seller_id == current_user.id).all()
