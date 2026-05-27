import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.models.user import User
from app.utils.dependencies import get_db
from app.schemas.chat import (
    ChatMessageIn,
    ChatMessageOut,
    ChatDirectMessageIn,
    ChatThreadOut,
)
from app.services.firebase_service import (
    add_global_chat_message,
    list_global_chat_messages,
    add_direct_chat_message,
    build_direct_thread_id,
    get_direct_chat_thread,
    list_direct_chat_messages,
    list_direct_chat_threads,
)
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


@router.get("/threads", response_model=list[ChatThreadOut])
def list_threads(
    limit: int = 50,
    current_user: User = Depends(get_current_user),
):
    logger.info("[Chat] Fetching threads for user_id=%s", current_user.id)
    return list_direct_chat_threads(user_id=current_user.id, limit=limit)


@router.get("/threads/{thread_id}/messages", response_model=list[ChatMessageOut])
def get_thread_messages(
    thread_id: str,
    limit: int = 50,
    current_user: User = Depends(get_current_user),
):
    logger.info("[Chat] Fetching messages for thread=%s", thread_id)
    thread = get_direct_chat_thread(thread_id)
    if thread is None:
        return []

    participants = thread.get("participants", [])
    if current_user.id not in participants:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not allowed")

    return list_direct_chat_messages(thread_id=thread_id, limit=limit)


@router.post("/threads/messages", response_model=ChatMessageOut)
def post_thread_message(
    payload: ChatDirectMessageIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    other_user = db.query(User).filter(User.id == payload.other_user_id).first()
    if not other_user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if current_user.role == "buyer":
        if other_user.role != "seller":
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Seller not found")
        buyer_id = current_user.id
        seller_id = other_user.id
        buyer_name = current_user.name
        seller_name = other_user.name
    elif current_user.role == "seller":
        if other_user.role != "buyer":
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Buyer not found")
        buyer_id = other_user.id
        seller_id = current_user.id
        buyer_name = other_user.name
        seller_name = current_user.name
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Role not allowed")

    thread_id = build_direct_thread_id(buyer_id, seller_id)
    logger.info("[Chat] Posting message for thread=%s user_id=%s", thread_id, current_user.id)

    return add_direct_chat_message(
        buyer_id=buyer_id,
        seller_id=seller_id,
        buyer_name=buyer_name,
        seller_name=seller_name,
        sender_id=current_user.id,
        sender_name=current_user.name,
        text=payload.text,
    )
