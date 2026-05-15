from datetime import datetime
from pydantic import BaseModel, EmailStr, Field


class UserBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    phone: str | None = None
    address: str | None = None


class UserCreate(UserBase):
    password: str = Field(..., min_length=6, max_length=128)
    role: str = Field(default="buyer")


class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    phone: str | None = None
    address: str | None = None
    is_verified: bool | None = None


class UserOut(UserBase):
    id: int
    role: str
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
