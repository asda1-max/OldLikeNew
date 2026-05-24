from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import relationship
from app.database import Base


class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    seller_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=False)
    condition = Column(String(20), nullable=False)
    image_urls = Column(JSON, nullable=False, default=list)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    seller = relationship("User", back_populates="items")
    auctions = relationship("Auction", back_populates="item", cascade="all, delete-orphan")
