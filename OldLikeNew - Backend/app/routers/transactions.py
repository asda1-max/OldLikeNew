from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.models.transaction import Transaction
from app.models.user import User
from app.schemas.transaction import TransactionOut, TransactionUpdate
from app.utils.dependencies import get_db, get_current_user

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.get("/", response_model=list[TransactionOut])
def list_transactions(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role == "admin":
        return db.query(Transaction).all()
    if current_user.role == "seller":
        return db.query(Transaction).filter(Transaction.seller_id == current_user.id).all()
    return db.query(Transaction).filter(Transaction.buyer_id == current_user.id).all()


@router.put("/{transaction_id}/status", response_model=TransactionOut)
def update_transaction_status(
    transaction_id: int,
    payload: TransactionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    transaction = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")

    if current_user.role == "seller" and transaction.seller_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    if current_user.role == "buyer" and transaction.buyer_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    data = payload.model_dump(exclude_unset=True)
    if not data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No updates provided")

    if current_user.role == "seller" and "payment_status" in data:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Seller cannot update payment_status")
    if current_user.role == "buyer" and "shipping_status" in data:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Buyer cannot update shipping_status")

    for key, value in data.items():
        setattr(transaction, key, value)

    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction
