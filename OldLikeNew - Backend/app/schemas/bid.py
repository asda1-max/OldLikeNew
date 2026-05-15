from datetime import datetime
from pydantic import BaseModel, Field
from app.schemas.user import UserOut


class BidCreate(BaseModel):
    amount: float = Field(..., gt=0)


class BidOut(BaseModel):
    id: int
    auction_id: int
    bidder: UserOut
    amount: float
    created_at: datetime

    class Config:
        from_attributes = True
