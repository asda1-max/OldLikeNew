from pydantic import BaseModel, Field


class ChatMessageIn(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)


class ChatMessageOut(BaseModel):
    id: str
    text: str
    sender_id: int | None = None
    sender_name: str
    created_at: str | None = None
