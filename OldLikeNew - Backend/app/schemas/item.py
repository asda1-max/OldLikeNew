from datetime import datetime
from pydantic import BaseModel


class ItemOut(BaseModel):
    id: int
    seller_id: int
    title: str
    description: str | None = None
    category: str
    condition: str
    image_urls: list[str]
    is_verified: bool = False
    created_at: datetime

    class Config:
        from_attributes = True
