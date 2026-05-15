from datetime import datetime
from pydantic import BaseModel, Field
from app.schemas.item import ItemOut
from app.schemas.user import UserOut
from app.schemas.bid import BidOut


class AuctionCreate(BaseModel):
    item_id: int
    start_price: float = Field(..., gt=0)
    buyout_price: float | None = Field(default=None, gt=0)
    start_time: datetime | None = None
    end_time: datetime


class AuctionUpdate(BaseModel):
    end_time: datetime | None = None
    status: str | None = None


class AuctionOut(BaseModel):
    id: int
    item: ItemOut
    seller: UserOut
    start_price: float
    current_price: float
    buyout_price: float | None = None
    start_time: datetime
    end_time: datetime
    status: str
    winner: UserOut | None = None
    created_at: datetime

    class Config:
        from_attributes = True


class AuctionDetail(AuctionOut):
    bids: list[BidOut] = []
