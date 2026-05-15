from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, Integer, String
from sqlalchemy.orm import relationship
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(120), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), nullable=False, default="buyer")
    is_verified = Column(Boolean, default=False)
    phone = Column(String(50), nullable=True)
    address = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    items = relationship("Item", back_populates="seller", cascade="all, delete-orphan")
    auctions = relationship("Auction", back_populates="seller", cascade="all, delete-orphan")
    bids = relationship("Bid", back_populates="bidder", cascade="all, delete-orphan")

    buyer_transactions = relationship(
        "Transaction", foreign_keys="Transaction.buyer_id", back_populates="buyer"
    )
    seller_transactions = relationship(
        "Transaction", foreign_keys="Transaction.seller_id", back_populates="seller"
    )
