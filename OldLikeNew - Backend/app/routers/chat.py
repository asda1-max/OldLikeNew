import logging
from fastapi import APIRouter, Depends
from app.models.user import User
from app.schemas.chat import ChatMessageIn, ChatMessageOut
from app.services.firebase_service import add_global_chat_message, list_global_chat_messages
from app.utils.dependencies import get_current_user

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/chat", tags=["chat"])


@router.get("/global/messages", response_model=list[ChatMessageOut])
def get_global_messages(
    limit: int = 50,
    current_user: User = Depends(get_current_user),
):
    logger.info("[Chat] Fetching global messages for user_id=%s", current_user.id)
    return list_global_chat_messages(limit=limit)


@router.post("/global/messages", response_model=ChatMessageOut)
def post_global_message(
    payload: ChatMessageIn,
    current_user: User = Depends(get_current_user),
):
    logger.info("[Chat] Posting message for user_id=%s", current_user.id)
    return add_global_chat_message(
        sender_id=current_user.id,
        sender_name=current_user.name,
        text=payload.text,
    )
