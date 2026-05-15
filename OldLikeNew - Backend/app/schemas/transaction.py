from datetime import datetime
from pydantic import BaseModel


class TransactionOut(BaseModel):
    id: int
    auction_id: int
    buyer_id: int
    seller_id: int
    final_price: float
    payment_status: str
    shipping_status: str
    created_at: datetime

    class Config:
        from_attributes = True


class TransactionUpdate(BaseModel):
    payment_status: str | None = None
    shipping_status: str | None = None
