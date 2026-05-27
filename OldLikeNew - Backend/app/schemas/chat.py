from pydantic import BaseModel, Field


class ChatMessageIn(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)


class ChatMessageOut(BaseModel):
    id: str
    text: str
    sender_id: int | None = None
    sender_name: str
    created_at: str | None = None


class ChatDirectMessageIn(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)
    other_user_id: int


class ChatThreadOut(BaseModel):
    id: str
    buyer_id: int
    seller_id: int
    buyer_name: str
    seller_name: str
    last_message: str | None = None
    last_message_at: str | None = None
